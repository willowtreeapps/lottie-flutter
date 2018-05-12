import 'package:flutter/rendering.dart'
    show Canvas, ColorFilter, Matrix4, Path, Rect, Size;

import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';

abstract class Content {
  String get name;

  void setContents(List<Content> contentsBefore, List<Content> contentsAfter);
}

abstract class Drawable implements Content {
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha);

  Rect getBounds(Matrix4 parentMatrix);

  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter);
}

typedef void Repaint();

abstract class AnimationDrawable implements Drawable {
  final String _name;
  final Repaint _repaint;
  final BaseLayer _layer;

  AnimationDrawable(this._name, this._repaint, this._layer);

  @override
  String get name => _name;

  void addAnimation(BaseKeyframeAnimation<dynamic, dynamic> animation) {
    if (animation != null) {
      _layer.addAnimation(animation);
      animation.addListener(onValueChanged);
    }
  }

  void invalidate() {
    _repaint();
  }

  void onValueChanged(double progress) {
    invalidate();
  }

  @override
  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter) {}

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {}

  @override
  Rect getBounds(Matrix4 parentMatrix) => Rect.zero;

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {}
}

abstract class PathContent implements Content {
  Path get path;
}
