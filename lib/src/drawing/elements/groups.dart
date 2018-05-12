import 'dart:math';
import 'dart:ui';

import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/paths.dart';
import 'package:lottie_flutter/src/elements/transforms.dart';
import 'package:lottie_flutter/src/utils.dart';

import 'package:vector_math/vector_math_64.dart';

import 'package:lottie_flutter/src/drawing/drawing_layers.dart';

class DrawableGroup extends AnimationDrawable implements PathContent {
  final List<AnimationDrawable> _contents;
  final List<PathContent> _pathContents = <PathContent>[];
  final TransformKeyframeAnimation _transformAnimation;

  DrawableGroup(String name, Repaint repaint, this._contents,
      this._transformAnimation, BaseLayer layer)
      : super(name, repaint, layer) {
    final List<Content> contentsToRemove = <Content>[];
    MergePathsDrawable currentMergePathsContent;
    for (int i = _contents.length - 1; i >= 0; i--) {
      final Content content = _contents[i];
      if (content is MergePathsDrawable) {
        currentMergePathsContent = content;
      }
      if (currentMergePathsContent != null &&
          content != currentMergePathsContent) {
        currentMergePathsContent.addContentIfNeeded(content);
        contentsToRemove.add(content);
      }
    }

    _transformAnimation?.addAnimationsToLayer(layer);
    _contents.removeWhere(
        (AnimationDrawable content) => contentsToRemove.contains(content));
  }

  @override
  Path get path {
    final Path path = new Path();
    for (int i = _contents.length - 1; i >= 0; i--) {
      final Content content = _contents[i];
      if (content is PathContent) {
        addPathToPath(path, content.path, transformation);
      }
    }

    return path;
  }

  List<PathContent> get paths {
    if (_pathContents.isNotEmpty) {
      return _pathContents;
    }

    for (Content content in _contents) {
      if (content is PathContent) {
        _pathContents.add(content);
      }
    }

    return _pathContents;
  }

  Matrix4 get transformation {
    return _transformAnimation?.matrix ?? new Matrix4.identity();
  }

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    // Do nothing with contents after.
    final List<Content> myContentsBefore = <Content>[];
    contentsBefore.forEach(myContentsBefore.add);

    for (int i = _contents.length - 1; i >= 0; i--) {
      final Content content = _contents[i];
      content.setContents(myContentsBefore, _contents.sublist(0, i));
      myContentsBefore.add(content);
    }
  }

  @override
  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter) {
    for (AnimationDrawable content in _contents) {
      if (contentName == null || contentName == content.name) {
        content.addColorFilter(layerName, null, colorFilter);
      } else {
        content.addColorFilter(layerName, contentName, colorFilter);
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    final Matrix4 matrix = parentMatrix.clone();

    int alpha = parentAlpha;
    if (_transformAnimation != null) {
      matrix.multiply(_transformAnimation.matrix);
      final int transformOpacity = _transformAnimation.opacity.value;
      alpha =
          ((transformOpacity / 100.0 * parentAlpha / 255.0) * 255.0).toInt();
    }

    for (int i = _contents.length - 1; i >= 0; i--) {
      _contents[i].draw(canvas, size, matrix, alpha);
    }
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {
    final Matrix4 matrix = parentMatrix.clone();

    if (_transformAnimation != null) {
      matrix.multiply(_transformAnimation.matrix);
    }

    Rect bounds = Rect.zero;
    for (int i = _contents.length - 1; i >= 0; i--) {
      final AnimationDrawable content = _contents[i];
      final Rect rect = content.getBounds(matrix);
      if (bounds.isEmpty) {
        bounds =
            new Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);
      } else {
        bounds = new Rect.fromLTRB(
            min(bounds.left, rect.left),
            min(bounds.top, rect.top),
            max(bounds.right, rect.right),
            max(bounds.bottom, rect.bottom));
      }
    }
    return bounds;
  }
}
