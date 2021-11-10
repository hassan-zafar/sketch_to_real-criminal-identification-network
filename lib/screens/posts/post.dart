import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/screens/comments.dart';
import 'package:sketch_to_real/screens/posts/post_details.dart';
import 'package:sketch_to_real/screens/profile.dart';
import 'package:sketch_to_real/tools/customImages.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:animator/animator.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

//actually a model like user model class but written in the same file with post widget so that we can add methods to it to pass them to our state class
class Post extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? location;
  final String? postTitle;
  final String? description;
  final String? mediaUrl;
  // final String? uploaderToken;

  final dynamic likes;
  final bool? isApproved;
  final bool? isSolved;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.isApproved,
    this.isSolved,
    this.postTitle,
    // this.uploaderToken,
  });
  factory Post.fromDocument(doc) {
    return Post(
      postId: doc.data()["postId"],
      ownerId: doc.data()["ownerId"],
      username: doc.data()["username"],
      description: doc.data()["description"],
      location: doc.data()["location"],
      mediaUrl: doc.data()["mediaUrl"],
      likes: doc.data()["likes"],
      isApproved: doc.data()["isApproved"],
      isSolved: doc.data()["isSolved"],
      postTitle: doc.data()["postTitle"],
      // uploaderToken: doc.data()["uploaderToken"],
    );
  }
  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val) {
        count += 1;
      }
    });
    return count;
  }

  @override
  // ignore: no_logic_in_create_state
  _PostState createState() => _PostState(
        postId: postId!,
        ownerId: ownerId!,
        username: username!,
        location: location!,
        description: description!,
        mediaUrl: mediaUrl!,
        likes: likes!,
        likeCount: getLikeCount(likes),
        isApproved: isApproved!,
        isSolved: isSolved!,
        postTitle: postTitle!,
        // uploaderToken: uploaderToken!,
      );
}

class _PostState extends State<Post> {
  bool? isLiked;
  bool? showUpvote = false;
  final String? currentUserId = currentUser!.userId!;
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? location;
  final String? description;
  final String? mediaUrl;
  final String? postTitle;
  final bool? isSolved;
  final bool? isApproved;
  // final String? uploaderToken;

  ///AnimationController _controller;
  int? likeCount;
  Map? likes;
  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
    this.isApproved,
    this.isSolved,
    this.postTitle,
    // this.uploaderToken,
  });
//  @override
//  void dispose() {
//    _controller.dispose();
//    super.dispose();
//  }
  showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: profileId,
                )));
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => PostDetails(
                      postId: postId,
                      mediaUrl: mediaUrl,
                      postTitle: postTitle,
                      postDescription: description,
                      isApproved: isApproved,
                      location: location,
                      // uploaderToken: uploaderToken,
                    ));
              },
              child: Text(
                postTitle!,
                style: titleTextStyle(fontSize: 20),
              ),
            ),
            !snapshot.hasData
                ? LoadingIndicator()
                : Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.photoUrl != ""
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        backgroundColor: Colors.grey,
                      ),
                      isPostOwner
                          ? IconButton(
                              onPressed: () => handleOptionPost(context),
                              icon: const Icon(Icons.more_vert),
                            )
                          : Container(),
                    ],
                  ),
          ],
        );

        // ListTile(
        //   leading: ,
        //   title: GestureDetector(
        //     onTap: () => showProfile(context, profileId: user.userId),
        //     child: Text(
        //       user.userName,
        //       style: TextStyle(
        //         color: Colors.black,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        //   subtitle: Text(location),
        //   trailing: isPostOwner
        //       ? IconButton(
        //           onPressed: () => handleOptionPost(context),
        //           icon: Icon(Icons.more_vert),
        //         )
        //       : Text(''),
        // );
      },
    );
  }

  handleOptionPost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              )
            ],
          );
        });
  }

//Note:to delete Post,ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    postRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {}
      doc.reference.delete();
    });
    //delete post from storage
    storageRef.child("post_$postId.jpg").delete();
    //then delete all activityFeed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //then delete all comments
    QuerySnapshot commentSnapshot =
        await commentsRef.doc(postId).collection('comments').get();

    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePosts() {
    bool _isLiked = likes![currentUserId] == true;
    if (_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount = likeCount! - 1;
        isLiked = false;
        likes![currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount = likeCount! + 1;
        isLiked = true;
        showUpvote = true;
        likes![currentUserId] = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showUpvote = false;
        });
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser!.userName,
        "userId": currentUser!.userId,
        "userProfileImg": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  GestureDetector buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePosts,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl!),
          showUpvote!
              ? Animator<double>(
                  duration: const Duration(milliseconds: 500),
                  cycles: 0,
                  curve: Curves.elasticOut,
                  tween: Tween<double>(begin: 0.8, end: 1.6),
                  builder: (context, anim, child) {
                    return Transform.scale(
                      scale: anim.value,
                      child: Icon(
                        isLiked! ? Icons.upgrade : Icons.download_rounded,
                        color: Colors.white,
                        size: 80.0,
                      ),
                    );
                  },
                )
              : const Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePosts,
              child: Icon(
                Icons.upgrade,
                size: 28.0,
                color: isLiked! ? Colors.black : Colors.grey,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                mediaUrl: mediaUrl!,
                postId: postId!,
                ownerId: ownerId!,
              ),
              child: const Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount upvotes",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$username :",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description!),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes![currentUserId] == true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GlassContainer(
        opacity: 0.2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildPostHeader(),
              buildPostImage(),
              buildPostFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

Padding postsTile({
  required Post post,
  required String businessName,
  required String location,
  required String imageLink,
  required String businessDescription,
  required String website,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 40.0, right: 40, top: 10, bottom: 10),
    child: GestureDetector(
      onTap: () => Get.to(
        () => Post(),
      ),
      child: GlassContainer(
        opacity: 0.5,
        height: 215,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: imageLink,
              child: Container(
                height: 120,
                width: 350,
                child: CachedNetworkImage(
                  height: 100,
                  imageUrl: imageLink,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                    tag: businessName,
                    child: Text(
                      businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    "Location: $location",
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

showComments(
  BuildContext context, {
  String? postId,
  String? ownerId,
  String? mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId!,
      postOwnerId: ownerId!,
      postMediaUrl: mediaUrl!,
//      userName: userName,
    );
  }));
}
