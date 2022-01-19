import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sketch_to_real/models/user_model.dart';

final userRef = FirebaseFirestore.instance.collection("users");
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final postRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
final Reference storageRef = FirebaseStorage.instance.ref();
bool isAdmin = false;
AppUserModel? currentUser;
final chatRoomRef = FirebaseFirestore.instance.collection('chatRoom');
final chatListRef = FirebaseFirestore.instance.collection('chatLists');
