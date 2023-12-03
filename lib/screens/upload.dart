import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final AppUserModel? currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  TextEditingController locationController = TextEditingController();
  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();
  // Position position;

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text("Photo with Camera"),
                onPressed: handleImageFromCamera),
            SimpleDialogOption(
                child: const Text("Image from Gallery"),
                onPressed: handleImageFromGallery),
            SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).canvasColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                child: const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                // color: Colors.deepOrange,
                onPressed: () => selectImage(context)),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  // compressImage() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  //   final compressedImageFile = File('$path/img_$postId.jpg')
  //     ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
  //   setState(() {
  //     file = compressedImageFile;
  //   });
  // }

  handleImageFromCamera() async {
    Navigator.pop(context);
    var picker = await ImagePicker().getImage(source: ImageSource.camera);
    File? file;
    print(file!.toString());
    file = File(picker!.path);
    setState(() {
      this.file = file;
    });
  }

  handleImageFromGallery() async {
    Navigator.pop(context);
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File? file;
    print(file.toString());
    file = File(picker!.path);
    setState(() {
      this.file = file;
    });
  }

  Future<String> uploadImage(imageFile) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('posts/$postId.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    String? downloadUrl;
    await uploadTask.whenComplete(() async {
      downloadUrl = await firebaseStorageRef.getDownloadURL();
    });

    return downloadUrl!;
  }

  createPostInFirestore(
      {String? mediaUrl, String? location, String? description}) {
    postRef.doc(currentUser!.userId).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser!.userId,
      "username": widget.currentUser!.userName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
      "postTitle": titleController.text,
      "isSolved": false,
      "isApproved": false,
    });
    timelineRef.doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser!.userId,
      "username": widget.currentUser!.userName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "postTitle": titleController.text,
      "isSolved": false,
      "isApproved": false,
      "likes": {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    // file != null ? await compressImage() : null;
    String postMediaUrl = file != null
        ? await uploadImage(file).catchError((onError) {
            isUploading = false;
            // BotToast.showText(text: "Couldn't connect to servers!!");
          })
        : "";
    createPostInFirestore(
      mediaUrl: postMediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = const Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: const Text(
          "Add Description",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          ElevatedButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? const LinearProgressIndicator() : const Text(""),
          SizedBox(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file!),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.currentUser!.photoUrl != ""
                  ? CachedNetworkImageProvider(widget.currentUser!.photoUrl!)
                  : null,
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Write Post Title",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          SizedBox(
            width: 250.0,
            child: TextField(
              controller: captionController,
              decoration: const InputDecoration(
                hintText: "Write description...",
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Container(
          //   width: 200.0,
          //   height: 100.0,
          //   alignment: Alignment.center,
          //   child: RaisedButton.icon(
          //     label: Text(
          //       "Use Current Location",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(30.0),
          //     ),
          //     color: Colors.blue,
          //     onPressed:
          //     getUserLocation,
          //     icon: Icon(
          //       Icons.my_location,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // getUserLocation() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   Position _position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   setState(() {
  //     position = _position;
  //   });
  //   List<Placemark> placeMarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);
  //   Placemark placemark = placeMarks[0];
  //   String completeAddress =
  //       '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
  //   print(completeAddress);
  //   locationController.text = completeAddress;
  // }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
