import 'package:flutter/material.dart';

class SsiFormPage extends StatelessWidget {
  static String tag = 'ssi-form-page';

  @override
  Widget build(BuildContext context) {
    final formName = Padding(
      padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 15.0),
      child: Text(
        'Surgical Site Inspections (SSIs) Form',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28.0,
          color: Colors.white,
        ),
      ),
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          formName,
        ],
      ),
    );

    return Scaffold(
      body: body,
    );
  }
}
