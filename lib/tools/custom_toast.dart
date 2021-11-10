import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void successToast({
  required String message,
  int duration = 3,
}) {
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: duration,
    backgroundColor: Colors.green,
  );
}

void errorToast({
  required String message,
  int duration = 4,
}) {
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: duration,
    backgroundColor: Colors.red,
  );
}
