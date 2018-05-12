import 'dart:ui' show Color;

import 'package:lottie_flutter/src/elements/groups.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/elements/transforms.dart';
import 'package:lottie_flutter/src/keyframes.dart';
import 'package:lottie_flutter/src/painting.dart';
import 'package:lottie_flutter/src/parsers/parsers.dart';
import 'package:lottie_flutter/src/utils.dart';

enum LayerType { PreComp, Solid, Image, Null, Shape, Text, Unknown }
enum MatteType { None, Add, Invert, Unknown }

class Layer {
  final int id;
  final int parentId;
  final double solidWidth;
  final double solidHeight;
  final double timeStretch;
  final double startProgress;
  final double preCompWidth;
  final double preCompHeight;
  final String name;
  final String refId;
  final Color solidColor;
  final List<Shape> shapes;
  final List<Mask> masks;
  final Scene<double> inOutKeyframes;
  final LayerType type;
  final MatteType matteType;
  final AnimatableTransform transform;

  factory Layer(
      [dynamic map,
      double preCompWidth,
      double preCompHeight,
      double scale,
      double durationFrames,
      double endFrame]) {
    if (map == null) {
      return new Layer.empty(preCompWidth, preCompHeight);
    }

    final int rawType = map['ty'] ?? LayerType.Unknown.index;
    final LayerType type = rawType < LayerType.Unknown.index
        ? LayerType.values[rawType]
        : LayerType.Unknown;

    double preCompositionWidth = 0.0;
    double preCompositionHeight = 0.0;
    if (type == LayerType.PreComp) {
      preCompositionWidth = parseMapToDouble(map['w']) * scale;
      preCompositionHeight = parseMapToDouble(map['h']) * scale;
    }

    double solidWidth = 0.0;
    double solidHeight = 0.0;
    Color solidColor = const Color(0x0);
    if (type == LayerType.Solid) {
      solidWidth = parseMapToDouble(map['sw']) * scale;
      solidHeight = parseMapToDouble(map['sh']) * scale;
      solidColor = parseColor(map['sc']);
    }

    final AnimatableTransform transform =
        new AnimatableTransform(map['ks'], scale, durationFrames);

    final MatteType matteType = MatteType.values[map['tt'] ?? 0];

    final List<Mask> masks = parseJsonArray(map['masksProperties'],
        (dynamic rawMask) => new Mask.fromMap(rawMask, scale, durationFrames));

    final List<Shape> shapes = parseJsonArray(map['shapes'],
        (dynamic rawShape) => shapeFromMap(rawShape, scale, durationFrames));

    final List<Keyframe<double>> inOutKeyframes = <Keyframe<double>>[];

    final double timeStretch =
        map['sr'] == null ? 1.0 : parseMapToDouble(map['sr']);
    final double inFrame = (map['ip']?.toDouble() ?? 0) / timeStretch;
    if (inFrame > 0) {
      inOutKeyframes
          .add(new Keyframe<double>(0.0, inFrame, durationFrames, 0.0, 0.0));
    }

    final double outFrame =
        (map['op'] > 0 ? map['op'].toDouble() + 1 : endFrame + 1) / timeStretch;

    inOutKeyframes
        .add(new Keyframe<double>(inFrame, outFrame, durationFrames, 1.0, 1.0));

    if (outFrame <= durationFrames) {
      final Keyframe<double> outKeyframe =
          new Keyframe<double>(outFrame, endFrame, durationFrames, 0.0, 0.0);
      inOutKeyframes.add(outKeyframe);
    }

    final double startProgress = parseMapToDouble(map['st']) / durationFrames;

    return new Layer._(
        map['ind'],
        map['parent'],
        solidWidth,
        solidHeight,
        timeStretch,
        startProgress,
        preCompositionWidth,
        preCompositionHeight,
        map['nm'],
        map['refId'],
        solidColor,
        shapes,
        masks,
        new Scene<double>(inOutKeyframes, false),
        type,
        matteType,
        transform);
  }

  Layer.empty(this.preCompWidth, this.preCompHeight)
      : id = -1,
        parentId = -1,
        solidWidth = 0.0,
        solidHeight = 0.0,
        timeStretch = 0.0,
        startProgress = 0.0,
        name = null,
        refId = null,
        solidColor = const Color(0x0),
        shapes = const <Shape>[],
        masks = const <Mask>[],
        inOutKeyframes = new Scene<double>.empty(),
        type = LayerType.PreComp,
        matteType = MatteType.None,
        transform = new AnimatableTransform();

  Layer._(
      this.id,
      this.parentId,
      this.solidWidth,
      this.solidHeight,
      this.timeStretch,
      this.startProgress,
      this.preCompWidth,
      this.preCompHeight,
      this.name,
      this.refId,
      this.solidColor,
      this.shapes,
      this.masks,
      this.inOutKeyframes,
      this.type,
      this.matteType,
      this.transform);

  static List<T> parseJsonArray<T>(
      List<dynamic> jsonArray, T mapItem(dynamic rawItem)) {
    if (jsonArray != null) {
      return jsonArray.map(mapItem).toList();
    }

    return <T>[];
  }

  @override
  String toString() {
    return '{"id: $id, "parentId": $parentId, "solidWidth": $solidWidth, '
        '"solidHeight": $solidHeight, "timeStretch": $timeStretch, '
        '"startProgress": $startProgress, "preCompWidth": $preCompWidth, '
        '"preCompHeight": $preCompHeight, "name": $name, "refId": $refId, '
        '"solidColor": $solidColor, "shapes": $shapes, "masks": $masks, '
        '"inOutKeyframes": $inOutKeyframes, "type": $type, '
        '"matteType": $matteType, "transform": $transform}';
  }
}
