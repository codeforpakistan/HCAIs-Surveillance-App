import 'package:flutter/material.dart';
import 'package:hcais/home.dart';
import 'package:hcais/login.dart';
import 'package:hcais/hcai_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    HcaiFormPage.tag: (context) => HcaiFormPage(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCAI Surveillance App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}
