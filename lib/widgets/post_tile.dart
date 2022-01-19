import 'package:flutter/material.dart';
import 'package:sketch_to_real/screens/posts/post.dart';
import 'package:sketch_to_real/screens/posts/post_screen.dart';
import 'package:sketch_to_real/tools/custom_images.dart';

class PostTile extends StatelessWidget {
  final Post? post;
  const PostTile(this.post, {Key? key}) : super(key: key);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  userId: post!.ownerId,
                  postId: post!.postId,
                  post: post,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post!.mediaUrl!),
    );
  }
}
