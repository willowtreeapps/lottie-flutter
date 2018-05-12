import 'dart:ui' show Color, Offset, Path;
import 'package:lottie_flutter/src/values.dart';
import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/keyframes.dart';
import 'package:lottie_flutter/src/parsers/parsers.dart';

abstract class AnimatableValue<A> {
  BaseKeyframeAnimation<dynamic, A> createAnimation();
  bool get hasAnimation;
}

abstract class BaseAnimatableValue<V, O> implements AnimatableValue<O> {
  final V initialValue;
  final Scene<V> scene;

  BaseAnimatableValue([this.initialValue, Scene<V> scene])
      : this.scene = scene ?? new Scene<V>.empty();

  BaseAnimatableValue.fromKeyframeGroup(KeyframeGroup<V> keyframeGroup)
      : initialValue = keyframeGroup.initialValue,
        scene = keyframeGroup.scene;

  @override
  bool get hasAnimation => scene.hasAnimation;
}

//
//  Integer
//
class AnimatableIntegerValue extends BaseAnimatableValue<int, int> {
  static final AnimatableValueParser<int> _parser =
      new AnimatableValueParser<int>();

  AnimatableIntegerValue([int initialValue = 100, Scene<int> scene])
      : super(initialValue, scene);

  AnimatableIntegerValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.intParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<int> createAnimation() {
    return hasAnimation
        ? new IntegerKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<int>(initialValue);
  }
}

//
//  Double
//
class AnimatableDoubleValue extends BaseAnimatableValue<double, double> {
  static final AnimatableValueParser<double> _parser =
      new AnimatableValueParser<double>();

  AnimatableDoubleValue() : super(0.0, new Scene<double>.empty());

  AnimatableDoubleValue.fromMap(
      dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.doubleParser, scale, durationFrames));

  @override
  KeyframeAnimation<double> createAnimation() {
    return hasAnimation
        ? new DoubleKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<double>(initialValue);
  }
}

//
//  Color
//
class AnimatableColorValue extends BaseAnimatableValue<Color, Color> {
  static final AnimatableValueParser<Color> _parser =
      new AnimatableValueParser<Color>();

  AnimatableColorValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.colorParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<Color> createAnimation() {
    return hasAnimation
        ? new ColorKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<Color>(initialValue);
  }
}

//
//  GradientColor
//
class AnimatableGradientColorValue
    extends BaseAnimatableValue<GradientColor, GradientColor> {
  static final AnimatableValueParser<GradientColor> _parser =
      new AnimatableValueParser<GradientColor>();

  AnimatableGradientColorValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(_parser.parse(
            map, new GradientColorParser(map['p']), 1.0, durationFrames));

  @override
  KeyframeAnimation<GradientColor> createAnimation() {
    return hasAnimation
        ? new GradientColorKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<GradientColor>(initialValue);
  }
}

//
//  Point
//
class AnimatablePointValue extends BaseAnimatableValue<Offset, Offset> {
  static final AnimatableValueParser<Offset> _parser =
      new AnimatableValueParser<Offset>();

  AnimatablePointValue.fromMap(dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.pointFParser, scale, durationFrames));

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new PointKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<Offset>(initialValue);
  }
}

//
//  Scale
//
class AnimatableScaleValue extends BaseAnimatableValue<Offset, Offset> {
  static final AnimatableValueParser<Offset> _parser =
      new AnimatableValueParser<Offset>();

  AnimatableScaleValue()
      : super(const Offset(1.0, 1.0), new Scene<Offset>.empty());

  AnimatableScaleValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.scaleParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new ScaleKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<Offset>(initialValue);
  }
}

//
//  Shape
//
class AnimatableShapeValue extends BaseAnimatableValue<ShapeData, Path> {
  static final AnimatableValueParser<ShapeData> _parser =
      new AnimatableValueParser<ShapeData>();

  AnimatableShapeValue.fromMap(dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.shapeDataParser, scale, durationFrames));

  @override
  BaseKeyframeAnimation<dynamic, Path> createAnimation() {
    return hasAnimation
        ? new ShapeKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<Path>(
            Parsers.pathParser.parseFromShape(initialValue));
  }
}

//
//  Path
//
class AnimatablePathValue extends BaseAnimatableValue<Offset, Offset> {
  factory AnimatablePathValue(
      [dynamic map, double scale, double durationFrames]) {
    if (map == null) {
      return new AnimatablePathValue._();
    }

    final List<dynamic> rawKeyframes = tryGetKeyframes(map);
    if (rawKeyframes != null) {
      final List<Keyframe<Offset>> keyframes = rawKeyframes
          .map<Keyframe<Offset>>((dynamic rawKeyframe) =>
              new PathKeyframe.fromMap(rawKeyframe, scale, durationFrames))
          .toList();

      final Scene<Offset> scene = new Scene<Offset>(keyframes);

      return new AnimatablePathValue._(null, scene);
    }

    return new AnimatablePathValue._(Parsers.pointFParser.parse(map, scale));
  }

  AnimatablePathValue._([Offset initialValue, Scene<Offset> scene])
      : super(initialValue == null ? const Offset(0.0, 0.0) : initialValue,
            scene);

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new PathKeyframeAnimation(scene)
        : new StaticKeyframeAnimation<Offset>(initialValue);
  }
}

//
//  Split Dimension
//
class AnimatableSplitDimensionValue implements AnimatableValue<Offset> {
  final AnimatableDoubleValue _animatableXDimension;
  final AnimatableDoubleValue _animatableYDimension;

  AnimatableSplitDimensionValue(
      this._animatableXDimension, this._animatableYDimension);

  @override
  BaseKeyframeAnimation<dynamic, Offset> createAnimation() {
    return new SplitDimensionPathKeyframeAnimation(
        _animatableXDimension.createAnimation(),
        _animatableYDimension.createAnimation());
  }

  @override
  bool get hasAnimation =>
      _animatableXDimension.hasAnimation || _animatableYDimension.hasAnimation;
}

class AnimatableValueParser<T> {
  KeyframeGroup<T> parse(
      dynamic map, Parser<T> parser, double scale, double durationFrames) {
    final Scene<T> scene = _parseKeyframes(map, parser, scale, durationFrames);
    final T initialValue =
        _parseInitialValue(map, scene.keyframes, parser, scale);
    return new KeyframeGroup<T>(initialValue, scene);
  }

  Scene<T> _parseKeyframes(
      dynamic map, Parser<T> parser, double scale, double durationFrames) {
    return new Scene<T>.fromMap(map, parser, scale, durationFrames);
  }

  T _parseInitialValue(dynamic map, List<Keyframe<T>> keyframes,
      Parser<T> parser, double scale) {
    if (keyframes.isNotEmpty) {
      return keyframes.first.startValue;
    }
    final dynamic rawInitialValue = map == null ? null : map['k'];
    return parser.parse(rawInitialValue, scale);
  }
}
