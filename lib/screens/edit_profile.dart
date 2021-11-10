import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatefulWidget {
  final String currentUserID;
   EditProfile({required this.currentUserID});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();
  UserModel? user;
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayNameValid = true;
  bool _isUpdating = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File? file;
  String newPhotoUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentUserID).get();
    user = UserModel.fromDocument(doc);
    displayNameController.text = user!.userName!;
    // bioTextController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Name Too Short",
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioTextController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio Too Long",
          ),
        ),
      ],
    );
  }

  // logout() async {
  //   await googleSignIn.signOut();
  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return Home();
  //   }));
  // }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioTextController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      _isUpdating = true;
    });
    if (_displayNameValid) {
      // file != null ? await compressImage() : null;
      String postMediaUrl = file != null
          ? await uploadImage(file).catchError((onError) {
              // isUploading = false;
              // BotToast.showText(text: "Couldn't connect to servers!!");
            })
          : "";
      print(postMediaUrl);
      userRef.doc(currentUser!.userId).update({
        "userName": displayNameController.text,
        "bio": bioTextController.text,
        "photoUrl": postMediaUrl,
      }).then((value) {
        setState(() {
          _isUpdating = false;
        });
        SnackBar snackbar = SnackBar(content: Text("Profile Updated"));
        _scaffoldKey.currentState!.showSnackBar(snackbar);
        Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(file);
    return Container(
      decoration: backgroundColorBoxDecoration(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Edit Profile"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _isUpdating ? null : () => updateProfileData(),
            ),
          ],
        ),
        body: _isUpdating
            ? LinearProgressIndicator()
            : ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Stack(
                            children: [
                              // user!.photoUrl != ""
                              //     ? CircleAvatar(
                              //         backgroundImage: 
                              //         file == null
                              //             ?
                              //         CachedNetworkImageProvider(
                              //                 user!.photoUrl!)
                              //             : 
                              //              FileImage(file!),
                              //         radius: 60.0,
                              //       )
                              //     : CircleAvatar(
                              //         backgroundImage:
                              //             file == null ? null : FileImage(file),
                              //         radius: 60.0,
                              //       ),
                              GestureDetector(
                                onTap: handleImageFromGallery,
                                child: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 20.0,
                                    child: Center(
                                        child: Icon(
                                      Icons.add,
                                      size: 20.0,
                                      color: Colors.white,
                                    ))),
                              ),
                            ],
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              buildDisplayField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(25.0),
                          child: FlatButton.icon(
                            onPressed: () {
                              // logout()
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 40,
                            ),
                            label: Text(
                              "Log Out",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  handleImageFromGallery() async {
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File? file;
    // ignore: avoid_print
    print(file.toString());
    file = File(picker!.path);
    setState(() {
      this.file = file;
    });
  }

  // compressImage() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  //   final compressedImageFile = File('$path/img_${currentUser.userId}.jpg')
  //     ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
  //   setState(() {
  //     file = compressedImageFile;
  //   });
  // }

  Future<String> uploadImage(imageFile) async {
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('user_img_${currentUser!.userId}.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    String? downloadUrl;
    await uploadTask.whenComplete(() async {
      downloadUrl = await firebaseStorageRef.getDownloadURL();
    });

    return downloadUrl!;
  }
}
