import 'dart:math';
import 'dart:ui' show Offset;
import 'package:flutter/foundation.dart';
import 'package:lottie_flutter/src/animatables.dart';
import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';

import 'package:lottie_flutter/src/parsers/element_parsers.dart';
import 'package:vector_math/vector_math_64.dart';

class AnimatableTransform extends Shape {
  final AnimatablePathValue _anchorPoint;
  final AnimatableValue<Offset> _position;
  final AnimatableScaleValue _scale;
  final AnimatableDoubleValue _rotation;
  final AnimatableIntegerValue _opacity;

  AnimatablePathValue get anchorPoint => _anchorPoint;

  AnimatableValue<Offset> get position => _position;

  AnimatableScaleValue get scale => _scale;

  AnimatableDoubleValue get rotation => _rotation;

  AnimatableIntegerValue get opacity => _opacity;

  AnimatableTransform._(this._anchorPoint, this._position, this._scale,
      this._rotation, this._opacity)
      : super.fromMap({});

  factory AnimatableTransform(
      [dynamic map, double scale, double durationFrames]) {
    if (map == null) {
      return new AnimatableTransform._(
          new AnimatablePathValue(),
          new AnimatablePathValue(),
          new AnimatableScaleValue(),
          new AnimatableDoubleValue(),
          new AnimatableIntegerValue());
    }

    AnimatablePathValue anchorPointTransform;
    AnimatableValue<Offset> positionTransform;
    AnimatableScaleValue scaleTransform;
    AnimatableDoubleValue rotationTransform;
    AnimatableIntegerValue opacityTransform;

    var rawAnchorPoint = map['a'];
    if (rawAnchorPoint != null) {
      anchorPointTransform =
          new AnimatablePathValue(rawAnchorPoint['k'], scale, durationFrames);
    } else {
      // Cameras don't have an anchor point property. Although we don't support
      // then, at least we won't crash
      print(
          "Layer has no transform property. You may be using an unsupported layer"
          "type such as a camera");
      anchorPointTransform = new AnimatablePathValue(null, scale);
    }

    positionTransform =
        parsePathOrSplitDimensionPath(map, scale, durationFrames);
    if (positionTransform == null) {
      _throwMissingTransform("position");
    }

    var rawScale = map['s'];
    scaleTransform = rawScale is Map
        ? new AnimatableScaleValue.fromMap(rawScale, durationFrames)
        // Somehow some community animations don't have scale in the transform
        : new AnimatableScaleValue();

    var rawRotation = map['r'] ?? map['rz'];
    if (rawRotation is Map) {
      rotationTransform =
          new AnimatableDoubleValue.fromMap(rawRotation, 1.0, durationFrames);
    } else {
      _throwMissingTransform("rotation");
    }

    var rawOpacity = map['o'];
    opacityTransform = rawOpacity is Map
        ? new AnimatableIntegerValue.fromMap(rawOpacity, durationFrames)
        : new AnimatableIntegerValue(100);

    return new AnimatableTransform._(anchorPointTransform, positionTransform,
        scaleTransform, rotationTransform, opacityTransform);
  }

  TransformKeyframeAnimation createAnimation() {
    return new TransformKeyframeAnimation(
        _anchorPoint.createAnimation(),
        _position.createAnimation(),
        _scale.createAnimation(),
        _rotation.createAnimation(),
        _opacity.createAnimation());
  }

  static void _throwMissingTransform(String missingProperty) {
    throw new ArgumentError("Missing trasnform $missingProperty");
  }
}

class TransformKeyframeAnimation {
  final BaseKeyframeAnimation<dynamic, Offset> _anchorPoint;
  final BaseKeyframeAnimation<dynamic, Offset> _position;
  final BaseKeyframeAnimation<dynamic, Offset> _scale;
  final BaseKeyframeAnimation<dynamic, double> _rotation;
  final BaseKeyframeAnimation<dynamic, int> _opacity;

  BaseKeyframeAnimation<dynamic, Offset> get anchorpoint => _anchorPoint;
  BaseKeyframeAnimation<dynamic, Offset> get position => _position;
  BaseKeyframeAnimation<dynamic, Offset> get scale => _scale;
  BaseKeyframeAnimation<dynamic, double> get rotation => _rotation;
  BaseKeyframeAnimation<dynamic, int> get opacity => _opacity;

  set progress(double val) {
    _anchorPoint.progress = val;
    _position.progress = val;
    _scale.progress = val;
    _rotation.progress = val;
    _opacity.progress = val;
  }

  void addAnimationsToLayer(BaseLayer layer) {
    layer.addAnimation(anchorpoint);
    layer.addAnimation(position);
    layer.addAnimation(scale);
    layer.addAnimation(rotation);
    layer.addAnimation(opacity);
    // TODO ??
    // if (startOpacity != null) {
    //   layer.addAnimation(startOpacity);
    // }
    // if (endOpacity != null) {
    //   layer.addAnimation(endOpacity);
    // }
  }

  Matrix4 get matrix {
    final _matrix = new Matrix4.identity();

    final position = _position.value;
    if (position.dx != 0.0 || position.dy != 0.0) {
      _matrix.translate(position.dx, position.dy);
    }
    final rotation = _rotation.value;
    if (rotation != 0) {
      _matrix.rotateZ(rotation * (PI / 180.0));
    }
    final scale = _scale.value;
    if (scale.dx != 1.0 || scale.dy != 1.0) {
      _matrix.scale(scale.dx, scale.dy);
    }

    final anchorPoint = _anchorPoint.value;
    if (anchorPoint.dx != 0.0 || anchorPoint.dy != 0.0) {
      _matrix.translate(-anchorPoint.dx, -anchorPoint.dy);
    }
    return _matrix;
  }

  TransformKeyframeAnimation(this._anchorPoint, this._position, this._scale,
      this._rotation, this._opacity);

  void addListener(ValueChanged<double> onValueChanged) {
    _anchorPoint.addListener(onValueChanged);
    _position.addListener(onValueChanged);
    _scale.addListener(onValueChanged);
    _rotation.addListener(onValueChanged);
    _opacity.addListener(onValueChanged);
  }
}
