import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:lottie_flutter/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const assetNames = const [
  'assets/Indicators2.json',
  'assets/happy_gift.json',
  'assets/empty_box.json',
  'assets/muzli.json',
  'assets/hamburger_arrow.json',
  'assets/motorcycle.json',
  'assets/emoji_shock.json',
  'assets/checked_done_.json',
  'assets/favourite_app_icon.json',
  'assets/preloader.json',
  'assets/walkthrough.json',
];

void main() {
  runApp(new DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Lottie Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LottieDemo(),
    );
  }
}

class LottieDemo extends StatefulWidget {
  LottieDemo({Key key}) : super(key: key);

  @override
  _LottieDemoState createState() => new _LottieDemoState();
}

class _LottieDemoState extends State<LottieDemo>
    with SingleTickerProviderStateMixin {
  LottieComposition _composition;
  String _assetName;
  AnimationController _controller;
  bool _repeat;

  @override
  void initState() {
    super.initState();

    _repeat = false;
    //_loadButtonPressed(assetNames[6]);
    _controller = new AnimationController(
      duration: new Duration(milliseconds: 1),
      vsync: this,
    );
    _controller.addListener(() => setState(() {}));
  }

  void _loadButtonPressed(String assetName) {
    loadAsset(assetName).then((composition) {
      setState(() {
        _assetName = assetName;
        _composition = composition;
        _controller.reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Lottie Demo'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new DropdownButton(
              items: assetNames
                  .map((assetName) => new DropdownMenuItem(
                        child: new Text(assetName),
                        value: assetName,
                      ))
                  .toList(),
              hint: new Text('Choose an asset'),
              value: _assetName,
              onChanged: (val) => _loadButtonPressed(val),
            ),
            new Text(_composition?.bounds?.size?.toString() ?? ''),
            new Lottie(
              composition: _composition,
              size: const Size(300.0, 300.0),
              controller: _controller,
            ),
            new Slider(
              value: _controller.value,
              onChanged: (val) => setState(() => _controller.value = val),
            ),
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              new IconButton(
                icon: const Icon(Icons.repeat),
                color: _repeat ? Colors.black : Colors.black45,
                onPressed: () => setState(() {
                      _repeat = !_repeat;
                      if (_controller.isAnimating) {
                        if (_repeat) {
                          _controller
                              .forward()
                              .then((f) => _controller.repeat());
                        } else {
                          _controller.forward();
                        }
                      }
                    }),
              ),
              new IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: _controller.value > 0
                    ? () => setState(() => _controller.reset())
                    : null,
              ),
              new IconButton(
                icon: _controller.isAnimating
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                onPressed: _controller.isCompleted
                    ? null
                    : () {
                        setState(() {
                          if (_controller.isAnimating) {
                            _controller.stop();
                          } else {
                            if (_repeat) {
                              _controller.repeat();
                            } else {
                              _controller.forward();
                            }
                          }
                        });
                      },
              ),
              new IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  _controller.reset();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

Future<LottieComposition> loadAsset(String assetName) async {
  return await rootBundle
      .loadString(assetName)
      .then((data) => json.decode(data))
      .then((map) => new LottieComposition.fromMap(map));
}
