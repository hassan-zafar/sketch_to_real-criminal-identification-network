import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/Database/local_database.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/screens/credentials/loginRelated/login_page.dart';
import 'package:sketch_to_real/screens/homepage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'constants.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notifications",
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    UserLocalData().setNotLoggedIn();
    String currentUserString = UserLocalData().getUserModel();
    if (currentUserString.isNotEmpty) {
      currentUser = UserModel.fromMap(json.decode(currentUserString));
    }
    return GetMaterialApp(
      title: 'Sketch to Real',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: const Color(0xff96B7BF),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(color: Color(0xff96B7BF)),
        canvasColor: Colors.transparent,
      ),
      home: AnimatedSplashScreen(
        splashIconSize: 160,
        splash: Hero(
            tag: "logo",
            child: Image.asset(
              logo,
              height: 160,
            )),
        animationDuration: const Duration(seconds: 1),
        centered: true,
        backgroundColor: Colors.white,
        //Color(0xff387A53),

        nextScreen: currentUser != null
            ? HomePage()
            : LoginPage(
                currentUserString: currentUserString,
              ),
        duration: 1,
        splashTransition: SplashTransition.fadeTransition,
      ),
      // ),
    );
  }
}
