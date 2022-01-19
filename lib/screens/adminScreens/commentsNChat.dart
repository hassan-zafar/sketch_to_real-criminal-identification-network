import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import 'package:volt_arena/consts/collections.dart';
import 'package:volt_arena/consts/colors.dart';
import 'package:volt_arena/consts/universal_variables.dart';
import 'package:volt_arena/models/users.dart';
import 'package:volt_arena/services/notificationHandler.dart';

class CommentsNChat extends StatefulWidget {
  // final String? postId;
  // final String? postOwnerId;
  final String? chatId;
  final String? heroMsg;
  // final bool? isParent;
  final String? chatNotificationToken;
//  final String userName;
  CommentsNChat({
    // this.postId,
    // this.postMediaUrl,
    // this.postOwnerId,
    required this.chatId,
    // required this.isParent,
    this.heroMsg,
    // @required this.isPostComment,
    required this.chatNotificationToken,
    // @required this.isProductComment
  });
  @override
  CommentsNChatState createState() => CommentsNChatState();
}

TextEditingController _commentNMessagesController = TextEditingController();

class CommentsNChatState extends State<CommentsNChat> {
  // final String? postId;
  // final String? postOwnerId;
  // final bool? isComment;
//  final String userName;
  // CommentsNChatState({
  // required this.postId,
  // required this.postOwnerId,
  // required this.isComment,

  // });
  List<AppUserModel> allAdmins = [];
  String? chatHeadId;
  List<CommentsNMessages> commentsListGlobal = [];

  getAdmins() async {
    QuerySnapshot snapshots =
        await userRef.where('isAdmin', isEqualTo: true).get();
    snapshots.docs.forEach((e) {
      allAdmins.add(AppUserModel.fromDocument(e));
    });
  }

  @override
  initState() {
    super.initState();
    if (mounted) {
      setState(() {
        chatHeadId =
            currentUser!.isAdmin != null && currentUser!.isAdmin == true
                ? widget.chatId
                : currentUser!.id;
      });
    }
    getAdmins();
  }

  buildChat() {
    print(widget.chatId);
    return StreamBuilder<QuerySnapshot>(
      stream:
          // currentUser!.isAdmin!
          // ? chatRoomRef
          //     .doc(currentUser!.isAdmin != null && currentUser!.isAdmin == true
          //         ? widget.chatId
          //         : currentUser!.id)
          //     .collection("chats")
          //     .snapshots()
          // :
          chatRoomRef
              .doc(currentUser!.isAdmin != null && currentUser!.isAdmin == true
                  ? widget.chatId
                  : currentUser!.id)
              .collection("chats")
              .orderBy("timestamp", descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }

        List<CommentsNMessages> chatMessages = [];
        snapshot.data!.docs.forEach((DocumentSnapshot doc) {
          chatMessages.add(CommentsNMessages.fromDocument(doc));
        });
        print(chatMessages);
        return ListView(
          children: chatMessages,
        );
      },
    );
  }

  addChatMessage() {
    String commentId = Uuid().v1();
    if (_commentNMessagesController.text.trim().length > 1) {
      chatRoomRef
          .doc(currentUser!.isAdmin != null && currentUser!.isAdmin == true
              ? widget.chatId
              : currentUser!.id)
          .collection("chats")
          .doc(commentId)
          .set({
        "userName": currentUser!.name,
        "userId": currentUser!.id,
        "androidNotificationToken": currentUser!.androidNotificationToken,
        "comment": _commentNMessagesController.text,
        "timestamp": DateTime.now(),
        "avatarUrl": currentUser!.imageUrl,
        "commentId": commentId,
      });
      currentUser!.isAdmin!
          ? null
          : chatListRef
              .doc(currentUser!.isAdmin! ? widget.chatId : currentUser!.id)
              .set({
              "userName": currentUser!.name,
              "userId": currentUser!.id,
              "comment": _commentNMessagesController.text,
              "timestamp": DateTime.now(),
              "androidNotificationToken": widget.chatNotificationToken ??
                  currentUser!.androidNotificationToken,
            });
      // sendNotificationToAdmin(
      //     type: "adminChats", title: "Admin Chats", isAdminChat: true);
      // if (isAdmin) {
      //   activityFeedRef.doc(widget.chatId).collection('feedItems').add({
      //     "type": "adminChats",
      //     "commentData": _commentNMessagesController.text,
      //     "userName": currentUser.userName,
      //     "userId": currentUser.id,
      //     "userProfileImg": currentUser.photoUrl,
      //     "postId": widget.chatId,
      //     "mediaUrl": postMediaUrl,
      //     "timestamp": timestamp,
      //   });
      sendAndRetrieveMessage(
          token: widget.chatNotificationToken!,
          message: _commentNMessagesController.text,
          title: "Admin Chats",
          context: context);
      // }

    } else {
      BotToast.showText(text: "Message field shouldn't be left Empty");
    }
    _commentNMessagesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColorBoxDecoration(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            currentUser!.isAdmin! ? "Manage Queries" : "Contact Admin",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildChat(),
              ),
              Divider(),
              ListTile(
                title: TextFormField(
                  controller: _commentNMessagesController,
                  decoration: InputDecoration(
                    hintText: "Write a message...",
                  ),
                ),
                trailing: IconButton(
                  onPressed: addChatMessage,
                  icon: Icon(
                    Icons.send,
                    size: 40.0,
                  ),
                ),
              ),
              // SizedBox(
              //   height: 50,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentsNMessages extends StatefulWidget {
  final String? userName;
  final String? userId;
  final String? avatarUrl;
  final String? comment;
  final Timestamp? timestamp;
  final String? commentId;
  final String? androidNotificationToken;
  CommentsNMessages({
    this.userName,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.commentId,
    this.androidNotificationToken,
  });
  factory CommentsNMessages.fromDocument(doc) {
    return CommentsNMessages(
      // avatarUrl: doc['avatarUrl'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
      userId: doc.data()['userId'],
      userName: doc.data()['userName'],
      commentId: doc.data()["commentId"],
      androidNotificationToken: doc["androidNotificationToken"],
    );
  }

  @override
  _CommentsNMessagesState createState() => _CommentsNMessagesState();
}

class _CommentsNMessagesState extends State<CommentsNMessages> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, right: 12, left: 12),
      child: buildMessageBubble(context),
    );
  }

  buildMessageBubble(BuildContext context) {
    bool isMe = currentUser!.id == widget.userId;
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: isMe ? Colors.orange : Colors.brown,
          borderRadius: isMe
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )
              : BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.avatarUrl != null && widget.avatarUrl != ''
                      ? CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(widget.avatarUrl!),
                        )
                      : CircleAvatar(backgroundImage: AssetImage(logo)),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${widget.userName} : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.white)),
                            Flexible(
                              child: Text(
                                "${widget.comment}",
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        // Text(
                        //   timeago.format(widget.timestamp!.toDate()),
                        //   style: TextStyle(color: Colors.black54, fontSize: 12),
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
