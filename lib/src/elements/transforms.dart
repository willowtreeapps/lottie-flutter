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
  final AnimatablePathValue anchorPoint;
  final AnimatableValue<Offset> position;
  final AnimatableScaleValue scale;
  final AnimatableDoubleValue rotation;
  final AnimatableIntegerValue opacity;

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

    final Map<String, dynamic> rawAnchorPoint = map['a'];
    if (rawAnchorPoint != null) {
      anchorPointTransform =
          new AnimatablePathValue(rawAnchorPoint['k'], scale, durationFrames);
    } else {
      // Cameras don't have an anchor point property. Although we don't support
      // then, at least we won't crash
      print(
          'Layer has no transform property. You may be using an unsupported layer'
          'type such as a camera');
      anchorPointTransform = new AnimatablePathValue(null, scale);
    }

    positionTransform =
        parsePathOrSplitDimensionPath(map, scale, durationFrames);
    if (positionTransform == null) {
      _throwMissingTransform('position');
    }

    final dynamic rawScale = map['s'];
    scaleTransform = rawScale is Map<String, dynamic>
        ? new AnimatableScaleValue.fromMap(rawScale, durationFrames)
        // Somehow some community animations don't have scale in the transform
        : new AnimatableScaleValue();

    final dynamic rawRotation = map['r'] ?? map['rz'];
    if (rawRotation is Map<String, dynamic>) {
      rotationTransform =
          new AnimatableDoubleValue.fromMap(rawRotation, 1.0, durationFrames);
    } else {
      _throwMissingTransform('rotation');
    }

    final dynamic rawOpacity = map['o'];
    opacityTransform = rawOpacity is Map<String, dynamic>
        ? new AnimatableIntegerValue.fromMap(rawOpacity, durationFrames)
        : new AnimatableIntegerValue(100);

    return new AnimatableTransform._(anchorPointTransform, positionTransform,
        scaleTransform, rotationTransform, opacityTransform);
  }

  AnimatableTransform._(
      this.anchorPoint, this.position, this.scale, this.rotation, this.opacity)
      : super.fromMap(<String, dynamic>{});

  TransformKeyframeAnimation createAnimation() {
    return new TransformKeyframeAnimation(
        anchorPoint.createAnimation(),
        position.createAnimation(),
        scale.createAnimation(),
        rotation.createAnimation(),
        opacity.createAnimation());
  }

  static void _throwMissingTransform(String missingProperty) {
    throw new ArgumentError('Missing trasnform $missingProperty');
  }
}

class TransformKeyframeAnimation {
  final BaseKeyframeAnimation<dynamic, Offset> anchorPoint;
  final BaseKeyframeAnimation<dynamic, Offset> position;
  final BaseKeyframeAnimation<dynamic, Offset> scale;
  final BaseKeyframeAnimation<dynamic, double> rotation;
  final BaseKeyframeAnimation<dynamic, int> opacity;

  TransformKeyframeAnimation(
      this.anchorPoint, this.position, this.scale, this.rotation, this.opacity);

  set progress(double val) {
    anchorPoint.progress = val;
    position.progress = val;
    scale.progress = val;
    rotation.progress = val;
    opacity.progress = val;
  }

  void addAnimationsToLayer(BaseLayer layer) {
    layer.addAnimation(anchorPoint);
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
    final Matrix4 _matrix = new Matrix4.identity();

    final Offset positionValue = position.value;
    if (positionValue.dx != 0.0 || positionValue.dy != 0.0) {
      _matrix.translate(positionValue.dx, positionValue.dy);
    }
    final double rotationValue = rotation.value;
    if (rotationValue != 0) {
      _matrix.rotateZ(rotationValue * pi / 180.0);
    }
    final Offset scaleValue = scale.value;
    if (scaleValue.dx != 1.0 || scaleValue.dy != 1.0) {
      _matrix.scale(scaleValue.dx, scaleValue.dy);
    }

    final Offset anchorPointValue = anchorPoint.value;
    if (anchorPointValue.dx != 0.0 || anchorPointValue.dy != 0.0) {
      _matrix.translate(-anchorPointValue.dx, -anchorPointValue.dy);
    }
    return _matrix;
  }

  void addListener(ValueChanged<double> onValueChanged) {
    anchorPoint.addListener(onValueChanged);
    position.addListener(onValueChanged);
    scale.addListener(onValueChanged);
    rotation.addListener(onValueChanged);
    opacity.addListener(onValueChanged);
  }
}
