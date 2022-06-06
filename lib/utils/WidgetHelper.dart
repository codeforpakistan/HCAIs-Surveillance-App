import 'package:flutter/material.dart';

class WidgetHelper {
  static Column buildColumn(String label, bool isRequired) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: <TextSpan>[
          TextSpan(
              text: label.toString(), style: TextStyle(color: Colors.black)),
          TextSpan(
              text: isRequired ? " *" : "",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ]),
      ),
      SizedBox(height: 4)
    ]);
  }
}
