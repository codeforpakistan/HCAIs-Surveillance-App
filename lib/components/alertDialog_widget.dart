import 'dart:ui';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BlurryDialog extends StatelessWidget {
  String title;
  String content;
  List<Widget> actions;

  BlurryDialog(this.title, this.content, this.actions);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: new Text(
            title,
            style: textStyle,
          ),
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: actions.length > 0
              ? actions
              : <Widget>[
                  new MaterialButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ],
        ));
  }
}
