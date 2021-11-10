import 'package:flutter/material.dart';

class LocationErrorWidget extends StatelessWidget {
  final String ?error;
  final Function? callback;

   LocationErrorWidget({this.error, this.callback})
      ;


  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);

    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.location_off,
              size: 150,
              color: errorColor,
            ),
            box,
            Text(
              error!,
              style: const TextStyle(
                  color: errorColor, fontWeight: FontWeight.bold),
            ),
            box,
            RaisedButton(
              child: const Text("Retry"),
              onPressed: () {
                if (callback != null) callback!();
              },
            )
          ],
        ),
      ),
    );
  }
}