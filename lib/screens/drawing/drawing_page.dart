// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/drawing/drawing_area.dart';
import 'package:http/http.dart' as http;

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  // const DrawingPage({ Key key }) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingArea> points = [];
  Widget? imageOutput;

  void saveImage(List<DrawingArea> points) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(200.0, 200.0)));
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 256, 256), paint2);
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i].points!, points[i + 1].points!, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final listBytes = Uint8List.view(pngBytes!.buffer);
    String base64 = base64Encode(listBytes);
    fetchResponse(base64);
  }

  void fetchResponse(var base64Image) async {
    var data = {'image': base64Image};
    var url = 'http://192.168.51.112:5000/predict';
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'Keep-Alive'
    };
    var body = json.encode(data);
    try {
      var response =
          await http.post(Uri.parse(url), body: body, headers: headers);
      final Map<String, dynamic> responseData = json.decode(response.body);
      String outputBytes = responseData['image'];
      print(outputBytes.substring(2, outputBytes.length - 1));
      displayResponseImage(outputBytes);
    } catch (e) {
      print("Error Has Occured");
      return null;
    }
  }

  void displayResponseImage(String bytes) async {
    Uint8List convertedBytes = base64Decode(bytes);
    setState(() {
      imageOutput = Container(
        width: 256,
        height: 256,
        child: Image.memory(
          convertedBytes,
          fit: BoxFit.cover,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Draw the person's face ",
              style: titleTextStyle(),
            ),
          ),
          Center(
            child: SizedBox(
              width: 256,
              height: 256,
              child: GestureDetector(
                onPanEnd: (details) {
                  saveImage(points);
                  setState(() {});
                },
                onPanDown: (details) {
                  setState(() {
                    points.add(DrawingArea(
                        points: details.localPosition,
                        areaPaint: Paint()
                          ..color = Colors.white
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias = true
                          ..strokeWidth = 2.0));
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    points.add(DrawingArea(
                        points: details.localPosition,
                        areaPaint: Paint()
                          ..color = Colors.white
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias = true
                          ..strokeWidth = 2.0));
                  });
                },
                child: SizedBox.expand(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: MyCustomPainter(points: points),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              points.clear();
            }),
            icon: const Icon(Icons.clear),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 256,
              height: 256,
              child: imageOutput,
            ),
          ),
        ],
      ),
    );
  }
}
