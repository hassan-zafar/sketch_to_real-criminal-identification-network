import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';


Future<Map<String, dynamic>?> sendAndRetrieveMessage(
    {required String token,
    required String message,
    required BuildContext context,
    String? imageUrl,
    required String title}) async {
  const String serverToken =
      "AAAAXuZwBH8:APA91bGSzf3N5XoywG9i2-BJ1oJtfbf2wCdNtRrp957aQ_109cJW1MNjURrrXTpLULhJOq6YbUhuSpnB0b7gCS4lSxfxD2oAR1pG1LQkU2FtwuCBKBe5ra8EyznbsM1SQW-KlKlKDona";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  await http
      .post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': title,
              imageUrl == null ? "" : "image": imageUrl
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      )
      .then((value) => print("Notification Sent"));
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body!)],
                ),
              ),
            );
          });
    }
  });
  return null;
}
