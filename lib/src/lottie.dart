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

  Lottie({Key key, @required LottieComposition composition, Size size})
      : _composition = composition,
        _size = size ?? composition.bounds.size,
        super(key: key);

  @override
  _LottieState createState() => new _LottieState();
}

class _LottieState extends State<Lottie> with SingleTickerProviderStateMixin {
  CompositionLayer _compositionLayer;
  AnimationController _animation;
  double _scale;

  @override
  void initState() {
    super.initState();

    setScaleAndCompositionLayer();

    _animation = new AnimationController(
      duration: new Duration(milliseconds: widget._composition.duration),
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
    )..forward();

    _animation.addListener(_handleChange);
  }

  // TODO: should be possible to have a scale > 1.0?
  static double _calcScale(Size size, LottieComposition composition) =>
      math.min(
          math.min(size.width / composition.bounds.size.width,
              size.height / composition.bounds.size.height),
          1.0);

  @override
  void didUpdateWidget(Lottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    setScaleAndCompositionLayer();
    _animation
      ..reset()
      ..forward();
  }

  void setScaleAndCompositionLayer() {
    _scale = _calcScale(widget._size, widget._composition);
    //_scale = .05;
    print('scaling to $_scale');
    _compositionLayer = new CompositionLayer(
        widget._composition,
        new Layer.empty(widget._size.width, widget._size.height),
        () => {},
        _scale);
  }

  void _handleChange() {
    setState(() {
      _compositionLayer.progress = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //_compositionLayer.progress = 0.0;
    return new CustomPaint(
        painter: new LottiePainter(_compositionLayer, scale: _scale),
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
