import 'dart:ui';
import 'package:lottie_flutter/src/parsers/parsers.dart';
import 'package:flutter/animation.dart' show Curve, Curves, Cubic;

class Keyframe<T> {
  static const double MAX_CP_VALUE = 100.0;

  double _startFrame;
  double _endFrame;
  double _durationFrames;
  T _startValue;
  T _endValue;
  Curve _curve;

  Keyframe(
      [this._startFrame,
      this._endFrame,
      this._durationFrames,
      this._startValue,
      this._endValue]);

  Keyframe.fromMap(Map<String, dynamic> map, Parser<T> parser, double scale,
      this._durationFrames) {
    if (!map.containsKey('t')) {
      _startValue = parser.parse(map, scale);
      _endValue = _startValue;
      return;
    }
    _startFrame = map['t']?.toDouble() ?? 0.0;
    _startValue = map.containsKey('s') ? parser.parse(map['s'], scale) : null;
    _endValue = map.containsKey('e') ? parser.parse(map['e'], scale) : null;

    if (map['h'] == 1) {
      _endValue = _startValue;
      _curve = Curves.linear;
    } else if (map.containsKey('o')) {
      final double x1 = _clamp(map['o']['x'], -scale, scale) / scale;
      final double y1 =
          _clamp(map['o']['y'], -MAX_CP_VALUE, MAX_CP_VALUE) / scale;
      final double x2 = _clamp(map['i']['x'], -scale, scale) / scale;
      final double y2 =
          _clamp(map['i']['y'], -MAX_CP_VALUE, MAX_CP_VALUE) / scale;
      _curve = new Cubic(x1, y1, x2, y2);
    } else {
      _curve = Curves.linear;
    }
  }

  double get startProgress {
    return _startFrame / _durationFrames;
  }

  double get endProgress => _endFrame == null
      ? 1
      : ((_endFrame - _startFrame) / _durationFrames) + startProgress;

  bool get isStatic => _curve == null;

  double get startFrame => _startFrame;

  double get endFrame => _endFrame;

  T get startValue => _startValue;

  T get endValue => _endValue;

  Curve get curve => _curve;

  bool containsProgress(double progress) =>
      progress >= startProgress && progress <= endProgress;

  double _clamp(dynamic value, double min, double max) =>
      parseMapToDouble(value).clamp(min, max);

  @override
  String toString() {
    return 'Keyframe{ _durationFrames: $_durationFrames,'
        ' _startFrame: $_startFrame, _endFrame: $_endFrame,'
        ' _startValue: $_startValue, _endValue: $_endValue,'
        ' _curve: $_curve}';
  }
}

class PathKeyframe extends Keyframe<Offset> {
  PathKeyframe(double startFrame, double endFrame, double durationFrames,
      Offset startValue, Offset endValue)
      : super(startFrame, endFrame, durationFrames, startValue, endValue);

  PathKeyframe.fromMap(dynamic map, double scale, double durationFrames)
      : super.fromMap(map, Parsers.pointFParser, scale, durationFrames) {
    final Offset cp1 = Parsers.pointFParser.parse(map['ti'], scale);
    final Offset cp2 = Parsers.pointFParser.parse(map['to'], scale);

    final bool equals =
        _endValue != null && _startValue != null && _startValue == _endValue;

    if (_endValue != null && !equals) {
      _path = createPath(_startValue, _endValue, cp1, cp2);
    }
  }

  Path _path;

  Path get path => _path;

  Path createPath(Offset start, Offset end, Offset cp1, Offset cp2) {
    final Path path = new Path();
    path.moveTo(start.dx, start.dy);

    if (cp1 != null &&
        cp2 != null &&
        (cp1.distance != 0 || cp2.distance != 0)) {
      path.cubicTo(start.dx + cp1.dx, start.dy + cp1.dy, end.dx + cp2.dx,
          end.dy + cp2.dy, end.dx, end.dy);
    } else {
      path.lineTo(end.dx, end.dy);
    }
    return path;
  }
}

class Scene<T> {
  final List<Keyframe<T>> _keyframes;

  Scene(this._keyframes, [bool join = true]) {
    if (join) {
      _joinKeyframes();
    }
  }

  Scene.empty() : this._keyframes = <Keyframe<T>>[];

  Scene.fromMap(
      dynamic map, Parser<T> parser, double scale, double durationFrames)
      : _keyframes = parseKeyframes(map, parser, scale, durationFrames) {
    if (_keyframes.isNotEmpty) {
      _joinKeyframes();
    }
  }

  List<Keyframe<T>> get keyframes => _keyframes;

  Keyframe<T> get firstKeyframe => _keyframes.first;

  Keyframe<T> get lastKeyframe => _keyframes.last;

  bool get isEmpty => _keyframes.isEmpty;

  bool get hasAnimation => _keyframes.isNotEmpty;

  static List<Keyframe<T>> parseKeyframes<T>(
      dynamic map, Parser<T> parser, double scale, double durationFrames) {
    if (map == null) {
      return <Keyframe<T>>[];
    }

    final List<dynamic> rawKeyframes = tryGetKeyframes(map['k']);

    return rawKeyframes
            ?.map<Keyframe<T>>((dynamic rawKeyframe) => new Keyframe<T>.fromMap(
                rawKeyframe, parser, scale, durationFrames))
            ?.toList() ??
        <Keyframe<T>>[];
  }

  //
  //  The json doesn't include end frames. The data can be taken from the start frame of the next
  //  keyframe though.
  //
  void _joinKeyframes() {
    final int length = _keyframes.length;

    for (int i = 0; i < length - 1; i++) {
      // In the json, the keyframes only contain their starting frame.
      _keyframes[i]._endFrame = _keyframes[i + 1]._startFrame;
    }

    if (_keyframes.last.startValue == null) {
      _keyframes.removeLast();
    }
  }

  @override
  String toString() {
    return 'Scene{keyframes: $_keyframes}';
  }
}

class KeyframeGroup<T> {
  final Scene<T> scene;
  final T initialValue;

  KeyframeGroup(this.initialValue, this.scene);
}

// this should involve fewer casts/repeated code
/// Returns a list of raw keyframes from json if json is list of keyframes.
///
/// Otherwise, returns null
List<dynamic> tryGetKeyframes(dynamic json) {
  return (json is List<dynamic> &&
          json?.first is Map<String, dynamic> &&
          json?.first?.containsKey('t') == true)
      ? json
      : null;
}
