import 'dart:ui' as ui;

import 'dart:ui';
import 'package:lottie_flutter/src/images.dart';
import 'package:lottie_flutter/src/layers.dart';

double parseStartFrame(dynamic map) => map['ip']?.toDouble() ?? 0.0;

double parseEndFrame(dynamic map) => map['op']?.toDouble() ?? 0.0;

double parseFrameRate(dynamic map) => map['fr']?.toDouble() ?? 0.0;

Rect parseBounds(dynamic map) {
  double scale = ui.window.devicePixelRatio;
  int width = map['w'];
  int height = map['h'];

  if (width != null && height != null) {
    double scaledWidth = width * scale;
    double scaledHeight = height * scale;
    return new Rect.fromLTRB(0.0, 0.0, scaledWidth, scaledHeight);
  }

  return Rect.zero;
}

Map<String, LottieImageAsset> parseImages(dynamic map) {
  List rawAssets = map["assets"];

  if (rawAssets == null) {
    return const {};
  }

  return rawAssets
      .where((rawAsset) => rawAsset.containsKey('p'))
      .map((rawAsset) => new LottieImageAsset.fromMap(rawAsset))
      .fold({}, (assets, image) {
    assets[image.id] = image;
    return assets;
  });
}

Map<String, List<Layer>> parsePreComps(dynamic map, double width, double height,
    double scale, double durationFrames, double endFrame) {
  List rawAssets = map["assets"];

  if (rawAssets == null) {
    return const {};
  }

  return rawAssets.where((rawAsset) => rawAsset["layers"] != null).fold({},
      (preComps, rawAsset) {
    preComps[rawAsset['id']] = parseLayers(
        rawAsset["layers"], width, height, scale, durationFrames, endFrame);
    return preComps;
  });
}

List<Layer> parseLayers(List rawLayers, double width, double height,
    double scale, double durationFrames, double endFrame) {
  return rawLayers
      .map((rawLayer) => new Layer(
          rawLayer, width, height, scale, durationFrames ?? 0.0, endFrame))
      .toList();
}
