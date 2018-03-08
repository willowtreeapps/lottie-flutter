import 'package:flutter/rendering.dart'
    show Canvas, ColorFilter, Matrix4, Path, Rect, Size;

import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';
import 'package:flutter/widgets.dart' show Animation;

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

abstract class AnimationDrawable implements Drawable {
  final String _name;
  final Animation<double> _animation;
  //final List<BaseKeyframeAnimation<dynamic, dynamic>> _animations = [];
  final BaseLayer _layer;

  @override
  String get name => _name;

  //List<BaseKeyframeAnimation<dynamic, dynamic>> get animations => _animations;

  AnimationDrawable(this._name, this._animation, this._layer);

  void addAnimation(BaseKeyframeAnimation<dynamic, dynamic> animation) {
    if (animation != null) {
      _layer.addAnimation(animation);
      animation.addListener(onValueChanged);
    }
  }

  void invalidate() {
   // _animation();
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
