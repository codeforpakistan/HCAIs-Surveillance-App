import 'package:flutter/material.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/home.dart';
import 'package:hcais/login.dart';
import 'package:jwt_decode/jwt_decode.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.accessToken}) : super(key: key);

  final String accessToken;
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
      home: _isExpired(this.accessToken) ? LoginPage() : HomePage(),
      routes: routes,
    );
  }

  bool _isExpired(String token) {
    try {
      return token != '' ? Jwt.isExpired(token) : true;
    } catch (err) {
      print(err);
      print('invalid token');
      return true;
    }
  }
}
