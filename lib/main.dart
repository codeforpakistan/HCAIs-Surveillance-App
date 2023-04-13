import 'package:flutter/material.dart';
import 'package:hcais/home.dart';
import 'package:hcais/login.dart';
import 'package:hcais/hcai_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('access_token') ?? '';
  runApp(MyApp(accessToken: accessToken));
}

class MyApp extends StatelessWidget {
  final String accessToken;
  MyApp({required this.accessToken});
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
      home: isExpired(this.accessToken) ? LoginPage() : HomePage(),
      routes: routes,
    );
  }

  static isExpired(String token) {
    try {
      return token != '' ? Jwt.isExpired(token) : true;
    } catch (err) {
      print(err);
      print('invalid token');
      return true;
    }
  }
}
