import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/groups.dart';
import 'package:lottie_flutter/src/elements/fills.dart';
import 'package:lottie_flutter/src/elements/paths.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/elements/strokes.dart';
import 'package:lottie_flutter/src/elements/transforms.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';

class ShapeGroup extends Shape {
  final List<Shape> _shapes;

  ShapeGroup.fromMap(dynamic map, double scale, double durationFrames)
      : _shapes = parseRawShapes(map['it'], scale, durationFrames),
        super.fromMap(map);

  List<Shape> get shapes => _shapes;
  
  @override
  AnimationDrawable toDrawable(Repaint repaint, BaseLayer layer) =>
      new DrawableGroup(
          name,
          repaint,
          shapesToAnimationDrawable(repaint, _shapes, layer),
          obtainTransformAnimation(_shapes),
          layer);

  static List<Shape> parseRawShapes(List<dynamic> rawShapes,
          double scale, double durationFrames) =>
      rawShapes
          .map((dynamic rawShape) =>
              shapeFromMap(rawShape, scale, durationFrames))
          .toList();
}

Shape shapeFromMap(
    Map<String, dynamic> rawShape, double scale, double durationFrames) {
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
    Repaint repaint, List<Shape> shapes, BaseLayer layer) {
  return shapes
      .map((Shape shape) => shape.toDrawable(repaint, layer))
      .where((AnimationDrawable drawable) => drawable != null)
      .toList();
}

TransformKeyframeAnimation obtainTransformAnimation(List<Shape> shapes) {
  final AnimatableTransform transform = shapes
      .firstWhere((Shape sh) => sh is AnimatableTransform, orElse: () => null);
  return transform?.createAnimation();
}
