import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/alertDialog_widget.dart';
import 'package:hcais/home.dart';
import 'package:http/http.dart' as http;
import 'package:hcais/utils/constants.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = new TextEditingController();
  final emailController = new TextEditingController();
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.lightGreenAccent,
    padding: EdgeInsets.all(10),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 90.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    // to be removed
    emailController.text = 'doctor@example.com';
    passwordController.text = 'testpass';

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        style: raisedButtonStyle,
        onPressed: () {
          if (emailController.text != '' && passwordController.text != '') {
            this.tryLogin(emailController.text, passwordController.text);
          } else {
            _showDialog('Missing fields!', 'Please type in email and password');
          }
        },
        child: Text(
          "Log In",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

    final forgotLabel = TextButton(
      onPressed: () {
        _showDialog('Forgot Password?',
            'PLease contact your hospital administrator to reset your password.');
      },
      child: Text(
        "Forgot password?",
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            forgotLabel,
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
        child: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/world-bank.png",
                height: 100,
                width: 100,
              ),
              Image.asset(
                "assets/MoNHSRC.png",
                height: 60,
                width: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  _showDialog(String alertTitle, String alertMsg) {
    BlurryDialog alert = BlurryDialog(alertTitle, alertMsg);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  tryLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse(Constants.BASE_URL + "/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      print(response.body);
      var jsonData = json.decode(response.body);
      if (Constants.prefs != null) {
        setState(() {
          Constants.prefs?.setString('access_token', jsonData['access_token']);
          Constants.prefs?.setBool("loggedIn", true);
          Constants.prefs?.setString("user", jsonData['user']);
        });
      }

      Navigator.of(context).pushNamed(HomePage.tag);
    } else {
      _showDialog('Try Again', 'Wrong Email or password');
      return false;
    }
  }
}
