import 'package:flutter/material.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/screens/profile.dart';
import 'package:sketch_to_real/screens/timeline.dart';
import 'package:sketch_to_real/screens/upload.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../constants.dart';
import 'adminScreens/all_users.dart';
import 'drawing/drawing_page.dart';

bool isAdmin = false;
String? userUid;
String? email;
String? userName;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController? pageController;
  int pageIndex = 0;

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController!.jumpToPage(
      pageIndex,
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    print(userUid);
    print(userName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: backgroundColorBoxDecoration(),
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                controller: pageController,
                onPageChanged: onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Timeline(currentUser: currentUser),
                  DrawingPage(),
                  Upload(currentUser: currentUser),
                  // Search(),
                  Profile(profileId: currentUser!.userId!),
                  const UserNSearch(),
                ],
              ),
            ],
          ),
          bottomNavigationBar: GlassContainer(
            opacity: 0.2,
            blur: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0x00ffffff),
              currentIndex: pageIndex,
              onTap: onTap,
              elevation: 0,
              showUnselectedLabels: false,
              unselectedItemColor: Colors.black,
              selectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.track_changes_outlined),
                    label: "Timeline"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.format_paint_outlined), label: "Draw"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.upload_outlined), label: "Upload"),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.search), label: "Search"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard), label: "All Users")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
