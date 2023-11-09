import 'package:flutter/material.dart';
import 'package:hcais/components/alertDialog_widget.dart';

class WidgetHelper {
  static Column buildColumn(String label, bool isRequired, context,
      [String helperText = '']) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Flexible(
              child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: label.toString(),
                  style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: isRequired ? " *" : "",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  )),
            ]),
            softWrap: true,
            maxLines: 10,
          )),
          Visibility(
            visible: helperText != '',
            child: SizedBox(width: 8), // Add some space between Icon and Text
          ),
          GestureDetector(
            onTap: () {
              // Call your function here
              _showDialog(context, helperText);
            },
            child: Visibility(
              visible: helperText != '',
              child: Icon(
                Icons.info_outline, // Replace with the desired icon
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 4)
    ]);
  }

  static void _showDialog(BuildContext context, String helpLabelText) {
    List<Widget> buttons = [];
    buttons.add(new MaterialButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    ));
    BlurryDialog alert = BlurryDialog('Information', helpLabelText, buttons);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
