import 'package:flutter/material.dart';

AppBar header(context,
    {bool? isAppTitle = false,
    String? titleText,
    bool? removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton! ? false : true,
    title: Text(
      isAppTitle! ? "Sketch To Real" : titleText!,
      style: TextStyle(
        fontFamily: "Signatra",
        color: Colors.white,
        fontSize: isAppTitle ? 30.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
