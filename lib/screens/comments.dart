import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:sketch_to_real/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
//  final String userName;
  Comments(
      {required this.postId,
      required this.postMediaUrl,
      required this.postOwnerId});
  @override
  // ignore: no_logic_in_create_state
  CommentsState createState() => CommentsState(
        postId: postId,
        postMediaUrl: postMediaUrl,
        postOwnerId: postOwnerId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
//  final String userName;
  CommentsState({
    this.postId,
    this.postMediaUrl,
    this.postOwnerId,
  });
  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentsRef
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }
        List<Comment> comments = [];
        snapshot.data!.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.doc(postId).collection("comments").add({
      "username": currentUser!.userName,
      "userId": currentUser!.userName,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser!.photoUrl,
    });
    bool isNotPostOwner = postOwnerId != currentUser!.userId;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "username": currentUser!.userName,
        "userId": currentUser!.userName,
        "userProfileImg": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "timestamp": timestamp,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColorBoxDecoration(),
      child: Scaffold(
        appBar: header(context, titleText: "Comments"),
        body: Column(
          children: <Widget>[
            Expanded(
              child: buildComments(),
            ),
            const Divider(),
            ListTile(
              title: TextFormField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Write a Comment...",
                ),
              ),
              trailing: IconButton(
                onPressed: addComment,
                icon: const Icon(
                  Icons.send,
                  size: 40.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? avatarUrl;
  final String? comment;
  final Timestamp? timestamp;
  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
      username: doc['username'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage:
                avatarUrl != "" ? CachedNetworkImageProvider(avatarUrl!) : null,
          ),
          title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " $comment",
                    ),
                  ])),
          //Text("$username: $comment"),
          subtitle: Text(timeago.format(timestamp!.toDate())),
        ),
      ],
    );
  }
}
