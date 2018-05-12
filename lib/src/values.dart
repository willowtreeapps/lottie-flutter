import 'dart:ui' show lerpDouble, Color;

import 'package:lottie_flutter/src/utils.dart';
import 'package:collection/collection.dart' show IterableEquality;
import 'package:flutter/painting.dart' as paint show Offset, Color;
import 'package:flutter/painting.dart' show hashValues, hashList;

enum GradientType { Linear, Radial }
enum ShapeTrimPathType { Simultaneously, Individually }
enum MergePathsMode { Merge, Add, Subtract, Intersect, ExcludeIntersections }
enum PolystarShapeType { Star, Polygon }

class CubicCurveData {
  final paint.Offset _controlPoint1;
  final paint.Offset _controlPoint2;
  final paint.Offset _vertex;

  const CubicCurveData(this._controlPoint1, this._controlPoint2, this._vertex);

  paint.Offset get controlPoint1 => _controlPoint1;

  paint.Offset get controlPoint2 => _controlPoint2;

  paint.Offset get vertex => _vertex;

  @override
  bool operator ==(dynamic other) {
    if (other is! CubicCurveData) {
      return false;
    }
    final CubicCurveData typedOther = other;
    return _controlPoint1 == typedOther.controlPoint1 &&
        _controlPoint2 == typedOther.controlPoint2 &&
        _vertex == typedOther.vertex;
  }

  @override
  int get hashCode => hashValues(_controlPoint1, _controlPoint2, _vertex);

  @override
  String toString() {
    return 'CubicCurveData{controlPoint1: $_controlPoint1, '
        'controlPoint2: $_controlPoint2, vertex: $_vertex}';
  }
}

class ShapeData {
  List<CubicCurveData> _curves;
  bool _isClosed;
  paint.Offset _initialPoint;
  ShapeData(this._curves, this._initialPoint, this._isClosed);

  ShapeData.fromInterpolateBetween(
      ShapeData shapeData1, ShapeData shapeData2, double percentage) {
    _curves ??= <CubicCurveData>[];

    if (_curves.isNotEmpty &&
        curves.length != shapeData1.length &&
        _curves.length != shapeData2.length) {
      throw new StateError('Curves must have the same number of control point.'
          'This: $length, Shape1: ${shapeData1.length}, Shape2: ${shapeData1
          .length}');
    } else if (curves.isEmpty) {
      _curves = new List<CubicCurveData>(shapeData1.length);
    }

    _isClosed = shapeData1.isClosed || shapeData2.isClosed;
    final double x = lerpDouble(
        shapeData1.initialPoint.dx, shapeData2.initialPoint.dx, percentage);
    final double y = lerpDouble(
        shapeData1.initialPoint.dy, shapeData2.initialPoint.dy, percentage);
    _initialPoint = new paint.Offset(x, y);

    for (int i = shapeData1.length - 1; i >= 0; i--) {
      final CubicCurveData curve1 = shapeData1.curves[i];
      final CubicCurveData curve2 = shapeData2.curves[i];

      final double x1 = lerpDouble(
          curve1.controlPoint1.dx, curve2.controlPoint1.dx, percentage);
      final double y1 = lerpDouble(
          curve1.controlPoint1.dy, curve2.controlPoint1.dy, percentage);

      final double x2 = lerpDouble(
          curve1.controlPoint2.dx, curve2.controlPoint2.dx, percentage);
      final double y2 = lerpDouble(
          curve1.controlPoint2.dy, curve2.controlPoint2.dy, percentage);

      final double vertexX =
          lerpDouble(curve1.vertex.dx, curve2.vertex.dx, percentage);
      final double vertexY =
          lerpDouble(curve1.vertex.dy, curve2.vertex.dy, percentage);

      _curves[i] = new CubicCurveData(new paint.Offset(x1, y1),
          new paint.Offset(x2, y2), new paint.Offset(vertexX, vertexY));
    }
  }

  bool get isClosed => _isClosed;

  paint.Offset get initialPoint => _initialPoint;

  int get length => _curves.length;

  List<CubicCurveData> get curves => _curves;

  @override
  bool operator ==(dynamic other) {
    if (other is! ShapeData) {
      return false;
    }
    final ShapeData typedOther = other;

    return _initialPoint == typedOther.initialPoint &&
        _isClosed == typedOther.isClosed &&
        const IterableEquality<CubicCurveData>()
            .equals(_curves, typedOther._curves);
  }

  @override
  int get hashCode => hashValues(length, isClosed, initialPoint);

  @override
  String toString() {
    return 'ShapeData{_isClosed: $_isClosed, _initialPoint: $_initialPoint,'
        'curves: $_curves}';
  }
}

class GradientColor {
  final List<double> _positions;
  final List<paint.Color> _colors;

  GradientColor(this._positions, this._colors);

  List<double> get positions => _positions;

  List<paint.Color> get colors => _colors;

  int get length => _colors.length;

  void lerpGradients(GradientColor gc1, GradientColor gc2, double progress) {
    if (gc1.length != gc2.length) {
      throw new ArgumentError(
          'Cannot interpolate between gradients. Lengths vary (${gc1
              .length} vs ${gc2.length})');
    }

    for (int i = 0; i < gc1.colors.length; i++) {
      positions[i] = lerpDouble(gc1.positions[i], gc2.positions[i], progress);
      colors[i] =
          GammaEvaluator.evaluate(progress, gc1.colors[i], gc2.colors[i]);
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! GradientColor) {
      return false;
    }
    final GradientColor typedOther = other;

    return const IterableEquality<Color>().equals(_colors, typedOther.colors) &&
        const IterableEquality<double>()
            .equals(_positions, typedOther.positions);
  }

  @override
  int get hashCode => hashValues(hashList(_colors), hashList(_positions));

  @override
  String toString() {
    return 'GradientColor{_positions: $_positions, _colors: $_colors}';
  }
}
