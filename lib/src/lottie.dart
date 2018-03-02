import 'dart:ui' as ui;

import 'package:lottie_flutter/src/composition.dart';
import 'package:lottie_flutter/src/drawing/drawing_layers.dart';
import 'package:lottie_flutter/src/layers.dart';
import 'package:lottie_flutter/src/mathutils.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Lottie extends StatefulWidget {
  final LottieComposition _composition;

  Lottie({Key key, @required LottieComposition composition})
      : _composition = composition,
        super(key: key);

  @override
  _LottieState createState() => new _LottieState();
}

class _LottieState extends State<Lottie> with SingleTickerProviderStateMixin {
  CompositionLayer _compositionLayer;
  AnimationController _animation;
  Size _size;

  @override
  void initState() {
    super.initState();

    _size = widget._composition.bounds.size;

    _compositionLayer = new CompositionLayer(widget._composition,
        new Layer.empty(_size.width, _size.height), () => {}, 1.0);

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
      _compositionLayer.progress = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //_compositionLayer.progress = 0.0;
    return new LayoutBuilder(builder: (ctx, constraints) => new CustomPaint(
        painter: new LottiePainter(_compositionLayer),
        size: constraints.constrain(widget._composition.bounds.size)),
    );
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
