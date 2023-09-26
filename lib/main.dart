import 'package:flutter/material.dart';
import 'package:hcais/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('access_token') ?? '';

  runApp(MyApp(accessToken: accessToken));
}
