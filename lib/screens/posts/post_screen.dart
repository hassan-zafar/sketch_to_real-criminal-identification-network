import 'package:flutter/material.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/posts/post.dart';

class PostScreen extends StatelessWidget {
  final String ?userId;
  final String ?postId;
  final Post? post;
   PostScreen({
    required this.userId,
    required this.postId,
    this.post,
  });
  @override
  Widget build(BuildContext context) {
    return
        // FutureBuilder(
        //     future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return LoadingIndicator();
        //       }
        //       print(snapshot.data);

        //       Post post = Post.fromDocument(snapshot.data);
        //       return
        Container(
      decoration: backgroundColorBoxDecoration(),
      child: Center(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(post!.description!),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                child: post,
              )
            ],
          ),
        ),
      ),
    );
    // });
  }
}
