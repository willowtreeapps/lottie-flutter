import 'dart:async';
import 'dart:convert';
import 'package:lottie_flutter/src/composition.dart';
import 'package:lottie_flutter/src/lottie.dart';
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

class _LottieDemoState extends State<LottieDemo> {
  LottieComposition _composition;
  String _assetName;

  @override
  void initState() {
    super.initState();
    _loadButtonPressed(assetNames[4]);
  }

  void _loadButtonPressed(String assetName) {
    loadAsset(assetName).then((composition) {
      setState(() {
        _assetName = assetName;
        _composition = composition;
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
        //child: new SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _composition == null
                ? new LimitedBox()
                : new Lottie(
                    composition: _composition, size: const Size(400.0, 500.0)),
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
