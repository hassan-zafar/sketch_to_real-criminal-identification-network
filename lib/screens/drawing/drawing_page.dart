//@dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/drawing/drawing_area.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import "package:file_picker/file_picker.dart";
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';

class DrawingPage extends StatefulWidget {
  // const DrawingPage({Key? key}) : super(key: key);

  // const DrawingPage({ Key key }) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingArea> points = [];
  Widget imageOutput;
  Image img1;
  TextEditingController ipAddressController = TextEditingController();

  void pickFile() async {
    FilePickerResult filePickerResult = await FilePicker.platform.pickFiles();
    File file = File(filePickerResult.files.single.path);
    loadImage(file);
    final zxc = await file.readAsBytes();
    base64Encode(zxc);
    final asd = Uint8List.view(zxc.buffer);
    // List<int> asd = await file.readAsBytesSync();
    img1;
    print("file:$file");

    String base64Img = base64Encode(asd);
    base64Img = base64Img.substring(1, base64Img.length);
    print("base64Img:$base64Img");

    // XFile picker = await ImagePicker().pickImage(source: ImageSource.gallery);
    // picker.readAsBytes;
    //TODO:Important COde
    // final mimeTypeData =
    //     lookupMimeType(file.path, headerBytes: [0xFF, 0xD8]).split('/');
    // var url = 'http://$ipAddress:5000/predict';

    // final imageUploadRequest = await http.MultipartRequest(
    //   "POST",
    //   Uri.parse(url),
    // );
    // final fileXd = await http.MultipartFile.fromPath('image', file.path,
    //     contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    // imageUploadRequest.fields['ext'] = mimeTypeData[1];
    // imageUploadRequest.files.add(fileXd);

    fetchResponse(
        base64Image: base64Img,
        ipAddress: ipAddressController.text,
        isUploaded: true);
  }

  void loadImage(File image) {
    setState(() {
      img1 = Image.file(
        image,
        height: 256,
        width: 256,
      );
    });
  }

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
        canvas.drawLine(points[i].points, points[i + 1].points, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final listBytes = Uint8List.view(pngBytes.buffer);
    String base64 = base64Encode(listBytes);
    print(base64);
    fetchResponse(
        ipAddress: ipAddressController.text,
        base64Image: base64,
        isUploaded: false);
  }

  void fetchResponse(
      {var base64Image,
      String ipAddress = "172.20.10.4",
      bool isUploaded}) async {
    var data = {'image': base64Image, 'uploaded': isUploaded};
    var url = 'http://$ipAddress:5000/predict';
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
      for (int i = 0; i < 3; i++) {
        // List<String> outputBytes = [];
        String outputBytes;
        print(responseData[i]);
        // outputBytes.add(responseData['image$i']);
        outputBytes = responseData['image0'];
        print(outputBytes.substring(2, outputBytes.length - 1));
        displayResponseImage(
            outputBytes.substring(2, outputBytes.length - 1), i);
      }
    } catch (e) {
      print(e);
      print("Error Has Occured");
      return null;
    }
  }

  void displayResponseImage(String bytes, int index) async {
    Uint8List convertedBytes = base64Decode(bytes);
    setState(() {
      imageOutput = SizedBox(
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: ipAddressController,
              ),
            ),
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
                    setState(() {
                      points.add(null);
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
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    points.clear();
                  }),
                  icon: const Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: () => pickFile(),
                  icon: const Icon(
                    Icons.camera,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: 256,
                height: 256,
                child: imageOutput,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: SizedBox(
            //     width: 256,
            //     height: 256,
            //     child: imageOutput,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
