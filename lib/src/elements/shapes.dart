import 'dart:ui';
import 'package:lottie_flutter/src/animatables.dart';
import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/shapes.dart';
import 'package:lottie_flutter/src/parsers/element_parsers.dart';
import 'package:lottie_flutter/src/values.dart';

import 'package:lottie_flutter/src/drawing/drawing_layers.dart';
import 'package:flutter/widgets.dart' show Animation;
abstract class Shape {
  final String _name;

  String get name => _name;

  Shape.fromMap(dynamic map) : _name = parseName(map);

  AnimationDrawable toDrawable(Animation<double> animation, BaseLayer layer) => null;
}

class CircleShape extends Shape {
  final AnimatableValue<Offset> _position;
  final AnimatablePointValue _size;
  final bool _reversed;

  CircleShape.fromMap(dynamic map, double scale, double durationFrames)
      : _position = parsePathOrSplitDimensionPath(map, scale, durationFrames),
        _size = parseSize(map, scale, durationFrames),
        _reversed = parseReversed(map),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Animation<double> animation, BaseLayer layer) =>
      new EllipseDrawable(name, animation, _size.createAnimation(),
          _position.createAnimation(), _reversed, layer);
}

class RectangleShape extends Shape {
  final AnimatableValue<Offset> _position;
  final AnimatablePointValue _size;
  final AnimatableDoubleValue _cornerRadius;

  RectangleShape.fromMap(dynamic map, double scale, double durationFrames)
      : _position = parsePathOrSplitDimensionPath(map, scale, durationFrames),
        _size = parseSize(map, scale, durationFrames),
        _cornerRadius =
            new AnimatableDoubleValue.fromMap(map['r'], scale, durationFrames),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Animation<double> animation, BaseLayer layer) =>
      new RectangleDrawable(name, animation, _position.createAnimation(),
          _size.createAnimation(), _cornerRadius.createAnimation(), layer);
}

class PolystarShape extends Shape {
  final PolystarShapeType _type;
  final AnimatableDoubleValue _points;
  final AnimatableValue<Offset> _position;
  final AnimatableDoubleValue _rotation;
  final AnimatableDoubleValue _innerRadius;
  final AnimatableDoubleValue _outerRadius;
  final AnimatableDoubleValue _innerRoundness;
  final AnimatableDoubleValue _outerRoundness;

  PolystarShape.fromMap(dynamic map, double scale, double durationFrames)
      : _type = parserPolystarShapeType(map),
        _position = parsePathOrSplitDimensionPath(map, scale, durationFrames),
        _points =
            new AnimatableDoubleValue.fromMap(map['pt'], 1.0, durationFrames),
        _rotation =
            new AnimatableDoubleValue.fromMap(map['r'], 1.0, durationFrames),
        _outerRadius =
            new AnimatableDoubleValue.fromMap(map['or'], scale, durationFrames),
        _outerRoundness =
            new AnimatableDoubleValue.fromMap(map['os'], 1.0, durationFrames),
        _innerRadius = parseinnerRadius(map, scale, durationFrames),
        _innerRoundness = parseInnerRoundness(map, durationFrames),
        super.fromMap(map);
}

class UnknownShape extends Shape {
  UnknownShape() : super.fromMap({});
}
