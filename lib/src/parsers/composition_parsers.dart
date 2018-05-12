import 'dart:ui' as ui;

import 'dart:ui';
import 'package:lottie_flutter/src/images.dart';
import 'package:lottie_flutter/src/layers.dart';

double parseStartFrame(dynamic map) => map['ip']?.toDouble() ?? 0.0;

double parseEndFrame(dynamic map) => map['op']?.toDouble() ?? 0.0;

double parseFrameRate(dynamic map) => map['fr']?.toDouble() ?? 0.0;

Rect parseBounds(Map<String, dynamic> map) {
  final double scale = ui.window.devicePixelRatio;
  final int width = map['w'];
  final int height = map['h'];

  if (width != null && height != null) {
    final double scaledWidth = width * scale;
    final double scaledHeight = height * scale;
    return new Rect.fromLTRB(0.0, 0.0, scaledWidth, scaledHeight);
  }

  return Rect.zero;
}

Map<String, LottieImageAsset> parseImages(dynamic map) {
  final List<dynamic> rawAssets = map['assets'];

  if (rawAssets == null) {
    return const <String, LottieImageAsset>{};
  }

  return rawAssets
      .where((dynamic rawAsset) => rawAsset.containsKey('p'))
      .map((dynamic rawAsset) => new LottieImageAsset.fromMap(rawAsset))
      .fold(<String, LottieImageAsset>{},
          (Map<String, LottieImageAsset> assets, LottieImageAsset image) {
    assets[image.id] = image;
    return assets;
  });
}

Map<String, List<Layer>> parsePreComps(dynamic map, double width, double height,
    double scale, double durationFrames, double endFrame) {
  final List<dynamic> rawAssets = map['assets'];

  if (rawAssets == null) {
    return const <String, List<Layer>>{};
  }

  return rawAssets
      .where((dynamic rawAsset) => rawAsset['layers'] != null)
      .fold(<String, List<Layer>>{},
          (Map<String, List<Layer>> preComps, dynamic rawAsset) {
    preComps[rawAsset['id']] = parseLayers(
        rawAsset['layers'], width, height, scale, durationFrames, endFrame);
    return preComps;
  });
}

List<Layer> parseLayers(List<dynamic> rawLayers, double width, double height,
    double scale, double durationFrames, double endFrame) {
  return rawLayers
      .map((dynamic rawLayer) => new Layer(
          rawLayer, width, height, scale, durationFrames ?? 0.0, endFrame))
      .toList();
}
