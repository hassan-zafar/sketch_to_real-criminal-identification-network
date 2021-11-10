import 'package:flutter/material.dart';

String logo = "assets/images/logo.jpg";
// String logoBackground = "assets/images/logoBackground.jpeg";
String loginIcon = "assets/images/logIn.svg";
String signUp = "assets/images/signUp.svg";
// String googleLogo = "assets/images/google.png";
// String facebookLogo = "assets/images/facebook.png";
// String emailIcon = "assets/images/email.png";
String forgetPassPageIcon = "assets/images/MaskGroup1.png";
// String videoLottie = "assets/lottie/video-design.json";

TextStyle titleTextStyle({double fontSize = 25, Color color = Colors.black}) {
  return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.8);
}

TextStyle averageTextStyle({double fontSize = 18, Color color = Colors.black}) {
  return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
      letterSpacing: 1.8);
}

Color containerColor = const Color(0xff96B7BF);
// Color(0xff96B7BF);

// Colors.white;
//  Color(0xffFED5E3);
BoxDecoration backgroundColorBoxDecorationLogo() {
  return BoxDecoration(
    image: DecorationImage(
        image: AssetImage(logo),
        colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcATop),
        alignment: Alignment.center,
        scale: 0.3),
    gradient: const LinearGradient(
      colors: [
        // Color(0xff387A53),
        // Color(0xff8BE78B),

        Colors.white,
        Color(0xff96B7BF),

        // Colors.green[100],
        // Colors.blue[200],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
    ),
  );
}

BoxDecoration backgroundColorBoxDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        // Color(0xff387A53),
        // Color(0xff8BE78B),

        Colors.white,
        Color(0xff96B7BF) // Color(0xffFED5E3),
        // Color(0xff96B7BF),

        // Colors.green[100],
        // Colors.blue[200],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
    ),
  );
}

BoxDecoration drawerColorBoxDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        // Color(0xff8BE78B),
        Colors.black,
        Colors.green.shade100,
      ],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ),
  );
}
