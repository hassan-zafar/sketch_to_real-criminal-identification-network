import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sketch_to_real/Database/database.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/screens/credentials/loginRelated/login_page.dart';
import 'package:sketch_to_real/screens/edit_profile.dart';
import 'package:sketch_to_real/screens/posts/post.dart';
import 'package:sketch_to_real/services/authentication_service.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:sketch_to_real/widgets/post_tile.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? currentUserID = currentUser!.userId;
  String? postOrientation = "grid";
  bool? isLoading = false;
  bool? isFollowing = false;
  int? postCount = 0;
  int? followersCount = 0;
  int? followingCount = 0;
  List<Post>? posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePost();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getUser() async {
    DatabaseMethods().fetchUserInfoFromFirebase(uid: currentUser!.userId!);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserID)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    print(currentUser!.userId);
    QuerySnapshot snapshot = await postRef
        .doc(currentUser!.userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      print(postCount);
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading!) {
      return LoadingIndicator();
    } else if (posts!.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260.0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts!.forEach((posts) {
        gridTiles.add(GridTile(child: PostTile(posts)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts!,
      );
    }
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Get.to(() => EditProfile(
              currentUserID: currentUserID!,
            ))!
        .then((value) {
      getUser();

      setState(() {});
    });
  }

  Container buildButton({
    String? text,
    required VoidCallback function,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          alignment: Alignment.center,
          width: 210,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: isFollowing! ? Colors.grey : Colors.blue,
            border:
                Border.all(color: isFollowing! ? Colors.white : Colors.blue),
          ),
          child: Text(
            text!,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFollowing! ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    //Will show different screen for LoggedIn user vs Visiting User
    bool isProfileOwner = currentUserID == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing!) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing!) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserID)
        .set({});

    followingRef
        .doc(currentUserID)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserID)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser!.userName,
      'userId': currentUserID,
      'userProfileImg': currentUser!.photoUrl,
      'timestamp': timestamp,
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove Follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
//remove Following
    followingRef
        .doc(currentUserID)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
//delete activityFeedItem for them
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  FutureBuilder buildProfileHeader() {
    return FutureBuilder(
      future: userRef.doc(currentUser!.userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }
        AppUserModel user = AppUserModel.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 42.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: user.photoUrl == ""
                        ? null
                        : CachedNetworkImageProvider(user.photoUrl!),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        // Row(
                        //   mainAxisSize: MainAxisSize.max,
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: <Widget>[
                        //     buildCountColumn("posts", postCount),
                        //     buildCountColumn("followers", followersCount),
                        //     buildCountColumn("following", followingCount),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 12.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.userName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.userName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(top: 2.0),
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     user.bio,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.grid_on),
            color: postOrientation == 'grid' ? Colors.black : Colors.grey,
            onPressed: () => setPostOrientation("grid")),
        IconButton(
            icon: const Icon(Icons.list),
            color: postOrientation == 'list' ? Colors.black : Colors.grey,
            onPressed: () => setPostOrientation("list")),
      ],
    );
  }

  logOut() {
    return ElevatedButton(
      onPressed: () {
        AuthenticationService().signOut();
        GetStorage().erase();
        Get.off(() => LoginPage());
      },
      child: const Text("Log Out"),
    );
  }

  // bool get wantKeepAlive => true;
  @override
  build(BuildContext context) {
    // super.build(context);
    return Container(
      decoration: backgroundColorBoxDecoration(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
          ),
          body: ListView(
            children: <Widget>[
              buildProfileHeader(),
              const Divider(),
              buildTogglePostOrientation(),
              const Divider(
                height: 0.0,
              ),
              buildProfilePosts(),
              logOut()
            ],
          )),
    );
  }
}
