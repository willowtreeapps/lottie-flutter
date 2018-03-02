import 'dart:math' as math;

import 'package:lottie_flutter/src/composition.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';
import 'package:lottie_flutter/src/layers.dart';
import 'package:lottie_flutter/src/mathutils.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Lottie extends StatefulWidget {
  final LottieComposition _composition;
  final Size _size;
  final CompositionLayer _compositionLayer;
  final double _scale;

  Lottie({Key key, @required LottieComposition composition, Size size})
      : _composition = composition,
        _size = size ?? composition.bounds.size,
        _scale = _calcScale(size, composition),
        _compositionLayer = new CompositionLayer(
            composition,
            new Layer.empty(size.width, size.height),
            () => {},
            _calcScale(size, composition)),
        super(key: key);

  // TODO: should be possible to have a scale > 1.0?
  static double _calcScale(Size size, LottieComposition composition) =>
      math.min(
          math.min(size.width / composition.bounds.size.width,
              size.height / composition.bounds.size.height),
          1.0);

  @override
  _LottieState createState() => new _LottieState();
}

class _LottieState extends State<Lottie> with SingleTickerProviderStateMixin {
  //CompositionLayer _compositionLayer;
  AnimationController _animation;
  //double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    _animation = new AnimationController(
      duration: new Duration(milliseconds: widget._composition.duration),
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
    )..repeat();

    _animation.addListener(_handleChange);
  }

  void _handleChange() {
    setState(() {
      widget._compositionLayer.progress = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //_compositionLayer.progress = 0.0;
    return new CustomPaint(
        painter:
            new LottiePainter(widget._compositionLayer, scale: widget._scale),
        size: widget._size);
  }

  @override
  void dispose() {
    _animation.removeListener(_handleChange);
    _animation.dispose();
    super.dispose();
  }
}

class LottiePainter extends CustomPainter {
  final CompositionLayer _compositionLayer;
  final double _scale;
  final int _alpha;

  LottiePainter(this._compositionLayer, {double scale: 1.0, int alpha: 255})
      : _scale = scale,
        _alpha = alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = new Matrix4.identity();
    preScale(matrix, _scale, _scale);

    _compositionLayer.draw(canvas, size, matrix, _alpha);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
