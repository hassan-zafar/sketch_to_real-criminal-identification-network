import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/Database/database.dart';
import 'package:sketch_to_real/common_ui_functions.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/posts/post.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:sketch_to_real/tools/notification_handler.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:uuid/uuid.dart';

class PostDetails extends StatefulWidget {
  final String ?postId;
  final String?postTitle;
  final bool? isApproved;
  final String ?mediaUrl;
  final String ?location;

  final String? postDescription;

  PostDetails({
    this.postId,
    this.mediaUrl,
    this.postTitle,
    this.postDescription,
    this.isApproved,
    this.location,
  });
  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  bool isApproved = false;

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    isApproved = widget.isApproved!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColorBoxDecoration(),
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          widget.mediaUrl!,
                        ),
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter)),
              ),
              ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(
                    height: 320,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassContainer(
                      opacity: 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Hero(
                                    tag: widget.postTitle!,
                                    child: Text(
                                      widget.postTitle!,
                                      style: titleTextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Information",
                                      style: cardHeadingTextStyle()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(widget.postDescription!),
                                ),
                              ],
                            ),
                            // Positioned(
                            //   top: 4,
                            //   right: 7,
                            //   child: smallPositionedColored(text: "Open"),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassContainer(
                      opacity: 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Business location",
                              style: cardHeadingTextStyle(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.location!),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.green,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: 16,
                                          right: 16),
                                      child: Icon(Icons.undo),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  isApproved
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            postRef.doc(widget.postId).delete().then((value) {
                              Navigator.pop(context);
                              BotToast.showText(text: "Post Deleted");
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      "Delete Post Permanently",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Positioned(
                right: 60,
                top: 15,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isLoading = true;
                    });
                    bool tempApprove = !isApproved;
                    postRef
                        .doc(widget.postId)
                        .update({"approve": tempApprove}).then((value) {
                      // sendAndRetrieveMessage(
                      //     token: widget.uploaderToken,
                      //     message: tempApprove
                      //         ? "Your POST has been Approved by the Admin"
                      //         : "Your POST has been Rejected by the Admin",
                      //     imageUrl: widget.mediaUrl,
                      //     context: context,
                      //     title: "Business Alert");
                      String postId = const Uuid().v4();
                      DatabaseMethods().addNotification(
                          postId: postId,
                          notificationTitle: "Post Approval Alert",
                          description:
                              "Your Post has been Approved by the Admin", eachUserId: '', eachUserToken: '', imageUrl: '');
                      setState(() {
                        isApproved = tempApprove;
                        _isLoading = false;
                      });
                      BotToast.showText(
                          text: isApproved
                              ? "Post Approved"
                              : "Post Disapproved");
                    });
                  },
                  child: _isLoading
                      ? LoadingIndicator()
                      : smallPositionedColored(
                          text: isApproved ? "Approved" : "Disapproved",
                          color: isApproved ? Colors.lime[600] : Colors.red,
                        ),
                ),
              ),
              Positioned(
                top: 15,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.reply_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

cardHeadingTextStyle() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
}
