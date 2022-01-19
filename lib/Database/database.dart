import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sketch_to_real/Database/local_database.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/tools/custom_toast.dart';
import 'package:uuid/uuid.dart';

class DatabaseMethods {
  // Future<Stream<QuerySnapshot>> getproductData() async {
  //   return FirebaseFirestore.instance.collection(productCollection).snapshots();
  // }

  Future addUserInfoToFirebase(
      {required AppUserModel userModel,
      required String userId,
      required email}) async {
    final Map<String, dynamic> userInfoMap = userModel.toMap();
    return userRef.doc(userId).set(userInfoMap).then((value) {
      String userModelString = json.encode(userInfoMap);
      UserLocalData().setUserModel(userModelString);
    }).catchError(
      (Object obj) {
        errorToast(message: obj.toString());
      },
    );
  }

  addNotification(
      {required String postId,
      required String notificationTitle,
      required String imageUrl,
      required String eachUserId,
      required String eachUserToken,
      required String description}) async {
    String notificationsId = const Uuid().v4();
    FirebaseFirestore.instance
        .collection("notifications")
        .doc(eachUserId)
        .collection("userNotifications")
        .doc(postId)
        .set({
      "notificationsId": notificationsId,
      "notificationTitle": notificationTitle,
      "description": description,
      "postId": postId,
      "timestamp": DateTime.now(),
      "token": eachUserToken,
      "imageUrl": imageUrl,
      "userId": currentUser!.userId
    });
  }

  Future fetchUserInfoFromFirebase({required String uid}) async {
    final DocumentSnapshot _user = await userRef.doc(uid).get();
    currentUser = AppUserModel.fromDocument(_user);
    Map userInfoMap = currentUser!.toMap();
    String userModelString = json.encode(userInfoMap);
    UserLocalData().setUserModel(userModelString);
    isAdmin = currentUser!.isAdmin!;
  }
}
