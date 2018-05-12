import 'dart:ui';

import 'package:lottie_flutter/src/values.dart';

class Parsers {
  static const ColorParser colorParser = const ColorParser();
  static const IntParser intParser = const IntParser();
  static const DoubleParser doubleParser = const DoubleParser();
  static const PointFParser pointFParser = const PointFParser();
  static const ScaleParser scaleParser = const ScaleParser();
  static const ShapeDataParser shapeDataParser = const ShapeDataParser();
  static const PathParser pathParser = const PathParser();
}

abstract class Parser<V> {
  V parse(dynamic map, double scale);
}

double parseMapToDouble(dynamic map) {
  double value = 0.0;

  if (map is List && map.isNotEmpty) {
    value = map[0] is int ? map[0].toDouble() : map[0];
  } else if (map is int) {
    value = map.toDouble();
  } else if (map is double) {
    value = map;
  }

  return value;
}

class IntParser implements Parser<int> {
  const IntParser();

  @override
  int parse(dynamic map, double scale) =>
      (parseMapToDouble(map) * scale).toInt();
}

class DoubleParser implements Parser<double> {
  const DoubleParser();

  @override
  double parse(dynamic map, double scale) => parseMapToDouble(map) * scale;
}

class PointFParser implements Parser<Offset> {
  const PointFParser();

  @override
  Offset parse(dynamic json, double scale) {
    if (json == null) {
      return null;
    }

    if (json is List && json.length >= 2) {
      return new Offset(json[0] * scale, json[1] * scale);
    }

    if (json is Map) {
      return new Offset(parseMapToDouble(json['x']) * scale,
          parseMapToDouble(json['y']) * scale);
    }

    throw new ArgumentError.value(json, 'json', 'Unable to parse point');
  }
}

class ScaleParser implements Parser<Offset> {
  const ScaleParser();

  @override
  Offset parse(dynamic list, double scale) =>
      new Offset(list[0] / 100.0 * scale, list[1] / 100.0 * scale);
}

class ColorParser implements Parser<Color> {
  const ColorParser();

  @override
  Color parse(dynamic map, double scale) {
    if (map == null || map.length != 4) {
      return const Color(0x0);
    }

    double r = map[0].toDouble();
    double g = map[1].toDouble();
    double b = map[2].toDouble();
    double a = map[3].toDouble();

    if (r <= 1 && g <= 1 && b <= 1 && a <= 1) {
      r *= 255;
      g *= 255;
      b *= 255;
      a *= 255;
    }
    return new Color.fromARGB(a.toInt(), r.toInt(), g.toInt(), b.toInt());
  }
}

class ShapeDataParser implements Parser<ShapeData> {
  const ShapeDataParser();

  @override
  ShapeData parse(dynamic json, double scale) {
    Map<String, dynamic> pointsData;

    if (json is List<dynamic>) {
      if (json[0] is Map<String, dynamic> && json[0].containsKey('v')) {
        pointsData = json[0];
      }
    } else if (json is Map<String, dynamic> && json.containsKey('v')) {
      pointsData = json;
    }

    if (pointsData == null) {
      return null;
    }

    final List<dynamic> points = pointsData['v'];
    final List<dynamic> inTangents = pointsData['i'];
    final List<dynamic> outTangents = pointsData['o'];
    final bool closed = pointsData['c'] ?? false;

    if (points == null ||
        points.length != inTangents?.length ||
        points.length != outTangents?.length) {
      throw new StateError(
          'Unable to process points array or tangets. $pointsData');
    } else if (points.isEmpty) {
      return new ShapeData(const <CubicCurveData>[], Offset.zero, false);
    }

    final Offset initialPoint = _vertexAtIndex(0, points, scale);
    final List<CubicCurveData> curves =
        new List<CubicCurveData>(closed ? points.length : points.length - 1);

    for (int i = 1; i < points.length; i++) {
      final Offset vertex = _vertexAtIndex(i, points, scale);
      final Offset previousVertex = _vertexAtIndex(i - 1, points, scale);
      final Offset cp1 = _vertexAtIndex(i - 1, outTangents, scale);
      final Offset cp2 = _vertexAtIndex(i, inTangents, scale);
      final Offset shapeCp1 = previousVertex + cp1;
      final Offset shapeCp2 = vertex + cp2;
      final Offset scaleVertex = vertex;

      curves[i - 1] = new CubicCurveData(shapeCp1, shapeCp2, scaleVertex);
    }

    if (closed) {
      final Offset vertex = _vertexAtIndex(0, points, scale);
      final Offset previousVertex =
          _vertexAtIndex(points.length - 1, points, scale);
      final Offset cp1 = _vertexAtIndex(points.length - 1, outTangents, scale);
      final Offset cp2 = _vertexAtIndex(0, inTangents, scale);

      final Offset shape1 = previousVertex + cp1;
      final Offset shape2 = vertex + cp2;
      final Offset scaleVertex = vertex;
      curves[curves.length - 1] =
          new CubicCurveData(shape1, shape2, scaleVertex);
    }

    return new ShapeData(curves, initialPoint, closed);
  }

  Offset _vertexAtIndex(int index, List<dynamic> points, double scale) {
    return new Offset(parseMapToDouble(points[index][0] * scale),
        parseMapToDouble(points[index][1] * scale));
  }
}

class GradientColorParser extends Parser<GradientColor> {
  final int _colorPoints;

  GradientColorParser(this._colorPoints);

  // Both the color stops and opacity stops are in the same array.
  // There are [colorPoints] colors sequentially as:
  // [ ..., position, red, green, blue, ... ]
  //
  //  The remainder of the array is the opacity stops sequentially as:
  //
  // [ ..., position, opacity, ... ]
  @override
  GradientColor parse(dynamic map, double scale) {
    final List<dynamic> rawGradientColor = map; // as List<dynamic>;
    final List<double> positions = new List<double>(_colorPoints);
    final List<Color> colors = new List<Color>(_colorPoints);
    final GradientColor gradientColor = new GradientColor(positions, colors);

    if (rawGradientColor.length != _colorPoints * 4) {
      print('Unexpected gradient length: ${rawGradientColor.length}'
          '. Expected ${_colorPoints * 4} . This may affect the appearance of the gradient. '
          'Make sure to save your After Effects file before exporting an animation with '
          'gradients.');
    }

    for (int i = 0; i < rawGradientColor.length; i += 4) {
      final int colorIndex = i ~/ 4;
      positions[colorIndex] = _getDouble(rawGradientColor[i]);
      colors[colorIndex] = new Color.fromARGB(
          255,
          (parseMapToDouble(rawGradientColor[i + 1]) * 255).toInt(),
          (parseMapToDouble(rawGradientColor[i + 2] * 255)).toInt(),
          (parseMapToDouble(rawGradientColor[i + 3] * 255)).toInt());
    }

    _addOpacityStopsToGradientIfNeeded(gradientColor, rawGradientColor);
    return gradientColor;
  }

  double _getDouble(dynamic i) {
    if (i is double) {
      return i;
    } else if (i is int) {
      return i.toDouble();
    } else if (i is num) {
      return i.toDouble();
    } else if (i is String) {
      return double.tryParse(i);
    } else {
      throw new StateError('Could not parse $i (${i.runtimeType})  double.');
    }
  }

  // This cheats a little bit.
  // Opacity stops can be at arbitrary intervals independent of color stops.
  // This uses the existing color stops and modifies the opacity at each existing color stop
  // based on what the opacity would be.
  //
  // This should be a good approximation is nearly all cases. However, if there are many more
  // opacity stops than color stops, information will be lost.
  void _addOpacityStopsToGradientIfNeeded(
      GradientColor gradientColor, List<dynamic> rawGradientColor) {
    final int startIndex = _colorPoints * 4;
    if (rawGradientColor.length <= startIndex) {
      return;
    }

    final int opacityStops = (rawGradientColor.length - startIndex) ~/ 2;
    final List<double> positions = new List<double>(opacityStops);
    final List<double> opacities = new List<double>(opacityStops);

    for (int i = startIndex, j = 0; i < rawGradientColor.length; i += 2, j++) {
      positions[j] = rawGradientColor[i];
      opacities[j] = rawGradientColor[i + 1];
    }

    for (int i = 0; i < gradientColor.length; i++) {
      final Color color = gradientColor.colors[i];
      final Color colorWithAlpha = color.withAlpha(_getOpacityAtPosition(
          gradientColor.positions[i], positions, opacities));
      gradientColor.colors[i] = colorWithAlpha;
    }
  }

  int _getOpacityAtPosition(
      double position, List<double> positions, List<double> opacities) {
    for (int i = 1; i < positions.length; i++) {
      final double lastPosition = positions[i - 1];
      final double thisPosition = positions[i];
      if (positions[i] >= position) {
        final double progress =
            (position - lastPosition) / (thisPosition - lastPosition);
        return (255 * lerpDouble(opacities[i - 1], opacities[i], progress))
            .toInt();
      }
    }

    return (255 * opacities[opacities.length - 1]).toInt();
  }
}

class PathParser implements Parser<Path> {
  const PathParser();

  @override
  Path parse(dynamic map, double scale) {
    return new Path();
  }

  Path parseFromShape(ShapeData shapeData) {
    final Path path = new Path();
    final Offset initialPoint = shapeData.initialPoint;
    Offset currentPoint = new Offset(initialPoint.dx, initialPoint.dy);
    path.moveTo(initialPoint.dx, initialPoint.dy);

    for (CubicCurveData curve in shapeData.curves) {
      if (curve.controlPoint1 == currentPoint &&
          curve.controlPoint2 == curve.vertex) {
        path.lineTo(curve.vertex.dx, curve.vertex.dy);
      } else {
        path.cubicTo(
            curve.controlPoint1.dx,
            curve.controlPoint1.dy,
            curve.controlPoint2.dx,
            curve.controlPoint2.dy,
            curve.vertex.dx,
            curve.vertex.dy);
      }
      currentPoint = new Offset(curve.vertex.dx, curve.vertex.dy);
    }

    if (shapeData.isClosed) {
      path.close();
    }

    return path;
  }
}
