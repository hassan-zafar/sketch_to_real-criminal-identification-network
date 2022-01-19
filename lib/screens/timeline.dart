import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/screens/posts/post.dart';
import 'package:sketch_to_real/screens/search.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:sketch_to_real/widgets/header.dart';

class Timeline extends StatefulWidget {
  final AppUserModel ?currentUser;
  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post>? posts;
  List<String> ?followingList = [];
  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    getTimeline();
    // getFollowing();
  }

  // getFollowing() async {
  //   QuerySnapshot snapshot = await followingRef
  //       .doc(currentUser.userId)
  //       .collection('userFollowing')
  //       .get();
  //   setState(() {
  //     followingList = snapshot.docs.map((doc) => doc.data().documentID).toList();
  //   });
  // }

  getTimeline() async {
    print(currentUser!.userId);
    QuerySnapshot snapshot = await timelineRef
        // .doc(widget.currentUser.userId)
        // .collection('timelinePosts')
        // .orderBy(
        //   'timestamp',
        //   descending: true,
        // )
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
    // _refreshController.refreshCompleted();
  }

  buildTimeline() {
    if (posts == null) {
      return LoadingIndicator();
    }
    return ListView(
      children: posts!,
    );
  }

  buildUsersToFollow() {
    return StreamBuilder<QuerySnapshot>(
        stream: userRef
            .orderBy('timestamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          List<UserResult> userResults = [];
          snapshot.data!.docs.forEach((doc) {
            AppUserModel user = AppUserModel.fromDocument(doc);
            final bool isAuthUser = user.userId == currentUser!.userId;
            final bool isFollowingUser = followingList!.contains(user.userId);
            //remove auth user from recommended list
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          });
          return Container(
            color: Theme.of(context).accentColor,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Users To Follow",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 30.0),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: userResults,
                ),
              ],
            ),
          );
        });
  }

  @override
  Scaffold build(context) {
    return Scaffold(
      appBar: header(context,
          isAppTitle: true,
          removeBackButton: true,
          titleText: "Sketch To Real"),
      body: buildTimeline(),
      //  SmartRefresher(
      //   header: WaterDropMaterialHeader(
      //     distance: 40.0,
      //   ),
      //   child: buildTimeline(),
      //   onRefresh: () => getTimeline(),
      //   controller: _refreshController,
      // ),
    );
  }
}
