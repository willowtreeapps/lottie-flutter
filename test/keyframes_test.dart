import 'dart:convert';
import 'package:lottie_flutter/src/keyframes.dart';
import 'package:lottie_flutter/src/parsers/parsers.dart';
import 'package:lottie_flutter/src/values.dart';
import 'package:flutter/animation.dart' show Curves, Cubic;
import 'package:flutter/painting.dart' show Color, Offset;
import 'package:test/test.dart';

void main() {
  ///
  /// Integer keyframe
  ///

  test('keyframe of integer with h test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "h":1, "s":[352,280,0],"e":[400,299,0]}');
    _expect(map, Parsers.intParser, 352, 352, equals(Curves.linear));
  });

  test('keyframe of integer test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352,280,0],"e":[400,299,0]}');
    _expect(map, Parsers.intParser, 352, 400, equals(Curves.linear));
  });

  test('keyframe of integer with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352,280,0], "e":[400,299,0],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expect(map, Parsers.intParser, 352, 400, const isInstanceOf<Cubic>());
  });

  ///
  /// Double keyframe
  ///

  test('keyframe of double with h test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expect(map, Parsers.doubleParser, 352.5, 352.5, equals(Curves.linear));
  });

  test('keyframe of double test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.3,280,0],"e":[400.5,299,0]}');
    _expect(map, Parsers.doubleParser, 352.3, 400.5, equals(Curves.linear));
  });

  test('keyframe of double with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expect(
        map, Parsers.doubleParser, 352.3, 400.0, const isInstanceOf<Cubic>());
  });

  ///
  /// Point keyframe
  ///

  test('keyframe of point as list with h test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe<Offset>(map, 352.5, 280.0);
  });

  test('keyframe of point as map with h test', () {
    final Map<String, dynamic> map = json.decode(
        '{"t":16, "h":1, "s":{"x":352.5,"y":280},"e":{"x":400.3,"y":299}}');
    _expectPointKeyframe<Offset>(map, 352.5, 280.0);
  });

  test('keyframe of point as list test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe<Offset>(map, 352.5, 280.0, x2: 400.3, y2: 299.0);
  });

  test('keyframe of point as map test', () {
    final Map<String, dynamic> map = json
        .decode('{"t":16, "s":{"x":352.5,"y":280},"e":{"x":400.3,"y":299}}');
    _expectPointKeyframe<Offset>(map, 352.5, 280.0, x2: 400.3, y2: 299.0);
  });

  test('keyframe of point as list with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe<Offset>(map, 352.3, 280.0,
        x2: 400.0, y2: 299.0, curveMatcher: const isInstanceOf<Cubic>());
  });

  test('keyframe of point as map with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe<Offset>(map, 352.3, 280.0,
        x2: 400.0, y2: 299.0, curveMatcher: const isInstanceOf<Cubic>());
  });

  ///
  /// Scale keyframe
  ///

  test('Scale keyframe with h test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe(map, 3.525, 2.8, parser: Parsers.scaleParser);
  });

  test('Scale keyframe test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.31,280,0],"e":[400.5,299,0]}');
    _expectPointKeyframe(map, 3.5231, 2.8,
        x2: 4.005, y2: 2.99, parser: Parsers.scaleParser);
  });

  test('Scale keyframe with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe(map, 3.523, 2.8,
        x2: 4.0,
        y2: 2.99,
        curveMatcher: const isInstanceOf<Cubic>(),
        parser: Parsers.scaleParser);
  });

  ///
  /// Color keyframe
  ///

  test('Color keyframe with h test', () {
    final Map<String, dynamic> map = json.decode(
        '{"t":16, "h":1, "s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1] }');
    const Color expected = const Color.fromARGB(255, 30, 170, 137);
    _expect(
        map, Parsers.colorParser, expected, expected, equals(Curves.linear));
  });

  test('Color keyframe test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1] }');
    const Color startValueExpected = const Color.fromARGB(255, 30, 170, 137);
    const Color endValueExpected = const Color.fromARGB(1, 213, 20, 110);
    _expect(map, Parsers.colorParser, startValueExpected, endValueExpected,
        equals(Curves.linear));
  });

  test('Color keyframe with curve test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16,"s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    const Color startValueExpected = const Color.fromARGB(255, 30, 170, 137);
    const Color endValueExpected = const Color.fromARGB(1, 213, 20, 110);
    _expect(map, Parsers.colorParser, startValueExpected, endValueExpected,
        const isInstanceOf<Cubic>());
  });

  ///
  /// GradientColor keyframe
  ///

  test('GradientColor keyframe with h test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "h":1, "s":[0,0.67,0.54,1,0.12,0.67,0,1.0],'
            '"e":[0.12,0.67,0.54,1] }');
    const List<Color> colors = <Color>[
      const Color.fromARGB(255, 170, 137, 255),
      const Color.fromARGB(255, 170, 0, 255)
    ];
    final GradientColor expected =
        new GradientColor(const <double>[0.0, 0.12], colors);
    _expect(map, new GradientColorParser(2), expected, expected,
        equals(Curves.linear));
  });

  test('GradientColor keyframe test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[0,0.67,0.54,1,0.12,0.67,0,1.0],'
            '"e":[2,0,0,1,1,1,1,1] }');
    _expectGradientKeyframe(map, equals(Curves.linear));
  });

  test('GradientColor keyframe test', () {
    final Map<String, dynamic> map =
        json.decode('{"t":16, "s":[0,0.67,0.54,1,0.12,0.67,0,1.0],'
            '"e":[2,0,0,1,1,1,1,1],'
            '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
            '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectGradientKeyframe(map, const isInstanceOf<Cubic>());
  });

  ///
  /// ShapeData keyframe
  ///

  test('ShapeData keyframe with h test', () {
    final Map<String, dynamic> map = json.decode('{"t":16, "h":1,'
        '"s":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":false},'
        '"e":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":false}}');
    const List<CubicCurveData> cubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-5.0, -20.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0))
    ];
    final ShapeData expected =
        new ShapeData(cubicData, const Offset(0.0, -10.0), false);
    _expect(map, Parsers.shapeDataParser, expected, expected,
        equals(Curves.linear));
  });

  test('ShapeData keyframe with h and closed curve test', () {
    final Map<String, dynamic> map = json.decode('{"t":16, "h":1,'
        '"s":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":true},'
        '"e":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":true}}');
    const List<CubicCurveData> cubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-5.0, -20.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0)),
      const CubicCurveData(const Offset(-40.0, -41.0),
          const Offset(10.0, -20.0), const Offset(0.0, -10.0))
    ];
    final ShapeData expected = new ShapeData(cubicData, const Offset(0.0, -10.0), true);
    _expect(map, Parsers.shapeDataParser, expected, expected,
        equals(Curves.linear));
  });

  test('ShapeData keyframe test', () {
    final Map<String, dynamic> map = json.decode(
        '{"t":16, "s":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":false},'
        '"e":{"i":[[20.0,-20.0],[5.5,1.0]],"o":[[-10.0,-15.0],[-15,-1.0]],'
        '"v":[[0,-11],[-30,-40]],"c":false}}');
    const List<CubicCurveData> startCubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-5.0, -20.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0))
    ];

    const List<CubicCurveData> endCubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-10.0, -26.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0))
    ];
    final ShapeData startValueExpected =
        new ShapeData(startCubicData, const Offset(0.0, -10.0), false);
    final ShapeData endValueExpected =
        new ShapeData(endCubicData, const Offset(0.0, -11.0), false);
    _expect(map, Parsers.shapeDataParser, startValueExpected, endValueExpected,
        equals(Curves.linear));
  });

  test('ShapeData keyframe test', () {
    final Map<String, dynamic> map = json.decode(
        '{"t":16, "s":{"i":[[10.0,-10.0],[5.5,1.0]],"o":[[-5.0,-10.0],[-10,-1.0]],'
        '"v":[[0,-10],[-30,-40]],"c":false},'
        '"e":{"i":[[20.0,-20.0],[5.5,1.0]],"o":[[-10.0,-15.0],[-15,-1.0]],'
        '"v":[[0,-11],[-30,-40]],"c":false}}');
    const List<CubicCurveData> startCubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-5.0, -20.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0))
    ];

    const List<CubicCurveData> endCubicData = const <CubicCurveData>[
      const CubicCurveData(const Offset(-10.0, -26.0),
          const Offset(-24.5, -39.0), const Offset(-30.0, -40.0))
    ];
    final ShapeData startValueExpected =
        new ShapeData(startCubicData, const Offset(0.0, -10.0), false);
    final ShapeData endValueExpected =
        new ShapeData(endCubicData, const Offset(0.0, -11.0), false);
    _expect(map, Parsers.shapeDataParser, startValueExpected, endValueExpected,
        equals(Curves.linear));
  });
}

void _expectPointKeyframe<T>(dynamic map, double x1, double y1,
    {double x2, double y2, Matcher curveMatcher, Parser<T> parser}) {
  final Offset startValueExpected = new Offset(x1, y1);
  final Offset endValueExpected = new Offset(x2 ?? x1, y2 ?? y1);
  _expect(map, parser ?? Parsers.pointFParser, startValueExpected,
      endValueExpected, curveMatcher ?? equals(Curves.linear));
}

void _expectGradientKeyframe(dynamic map, Matcher curveMatcher) {
  const List<Color> startColors = <Color>[
    const Color.fromARGB(255, 170, 137, 255),
    const Color.fromARGB(255, 170, 0, 255)
  ];

  const List<Color> endColors = <Color>[
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 255, 255, 255)
  ];

  final GradientColor startValueExpected =
      new GradientColor(const <double>[0.0, 0.12], startColors);
  final GradientColor endValueExpected =
      new GradientColor(const <double>[2.0, 1.0], endColors);
  _expect<GradientColor>(map, new GradientColorParser(2), startValueExpected,
      endValueExpected, curveMatcher);
}

void _expect<T>(dynamic map, Parser<T> parser, T startValue, T endValue,
    Matcher curveMatcher) {
  final Keyframe<T> keyframe = new Keyframe<T>.fromMap(map, parser, 1.0, 0.0);
  expect(keyframe.startValue, startValue);
  expect(keyframe.endValue, endValue);
  expect(keyframe.curve, curveMatcher);
}
