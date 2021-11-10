import 'package:flutter/material.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/drawing/drawing_area.dart';

class DrawingPage extends StatefulWidget {
  // const DrawingPage({ Key key }) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingArea> points = [];
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
                  setState(() {
                    // points.add();
                  });
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
            onPressed: () => this.setState(() {
              points.clear();
            }),
            icon: Icon(Icons.clear),
          )
        ],
      ),
    );
  }
}
