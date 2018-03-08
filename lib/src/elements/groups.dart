import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/groups.dart';
import 'package:lottie_flutter/src/elements/fills.dart';
import 'package:lottie_flutter/src/elements/paths.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/elements/strokes.dart';
import 'package:lottie_flutter/src/elements/transforms.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';
import 'package:flutter/widgets.dart' show Animation;
class ShapeGroup extends Shape {
  final List<Shape> _shapes;

  List<Shape> get shapes => _shapes;

  ShapeGroup.fromMap(dynamic map, double scale, double durationFrames)
      : _shapes = parseRawShapes(map['it'], scale, durationFrames),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Animation<double> animation, BaseLayer layer) =>
      new DrawableGroup(
          name,
          animation,
          shapesToAnimationDrawable(animation, _shapes, layer),
          obtainTransformAnimation(_shapes, animation),
          layer);

  static List<Shape> parseRawShapes(
          List rawShapes, double scale, double durationFrames) =>
      rawShapes
          .map((rawShape) => shapeFromMap(rawShape, scale, durationFrames))
          .toList();
}

Shape shapeFromMap(dynamic rawShape, double scale, double durationFrames) {
  switch (rawShape['ty']) {
    case 'gr':
      return new ShapeGroup.fromMap(rawShape, scale, durationFrames);
    case 'st':
      return new ShapeStroke.fromMap(rawShape, scale, durationFrames);
    case 'gs':
      return new GradientStroke.fromMap(rawShape, scale, durationFrames);
    case 'fl':
      return new ShapeFill.fromMap(rawShape, scale, durationFrames);
    case 'gf':
      return new GradientFill.fromMap(rawShape, scale, durationFrames);
    case 'tr':
      return new AnimatableTransform(rawShape, scale, durationFrames);
    case 'sh':
      return new ShapePath.fromMap(rawShape, scale, durationFrames);
    case 'el':
      return new CircleShape.fromMap(rawShape, scale, durationFrames);
    case 'rc':
      return new RectangleShape.fromMap(rawShape, scale, durationFrames);
    case 'tm':
      return new ShapeTrimPath.fromMap(rawShape, scale, durationFrames);
    case 'sr':
      return new PolystarShape.fromMap(rawShape, scale, durationFrames);
    case 'mm':
      return new MergePaths.fromMap(rawShape, scale);
    // TODO: Implement RepeaterParser
    // case 'rp':
    //   return new RepeaterParser.fromMap(rawShape);
    default:
      print('Unknown shape ${rawShape['ty']}');
      return new UnknownShape();
  }
}

List<AnimationDrawable> shapesToAnimationDrawable(
    Animation<double> animation, List<Shape> shapes, BaseLayer layer) {
  return shapes
      .map((shape) => shape.toDrawable(animation, layer))
      .where((drawable) => drawable != null)
      .toList();
}

TransformKeyframeAnimation obtainTransformAnimation(List<Shape> shapes, Animation<double> animation) {
  return (shapes.firstWhere((sh) => sh is AnimatableTransform,
          orElse: () => null) as AnimatableTransform)
      ?.createAnimation(animation);
}
