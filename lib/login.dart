import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/alertDialog_widget.dart';
import 'package:hcais/home.dart';
import 'package:hcais/utils/my_shared_prefs.dart';
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
    primary: Color.fromRGBO(140, 198, 62, 1),
    // padding: EdgeInsets.all(10),
    minimumSize: Size(20, 40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
    final email =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Username *'),
      SizedBox(height: 4),
      TextFormField(
          controller: emailController,
          decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(242, 242, 242, 1),
              contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              )))
    ]);

    final password =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Password *'),
      SizedBox(height: 4),
      TextFormField(
          obscureText: true,
          autocorrect: false,
          controller: passwordController,
          decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(242, 242, 242, 1),
              contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
              // labelText: labelText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                // width: 0.0 produces a thin "hairline" border
                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              )))
    ]);

    // to be removed
    // emailController.text = 'doctor@example.com';
    // passwordController.text = 'testpass';

    final loginButton = ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () {
        if (emailController.text != '' && passwordController.text != '') {
          this.tryLogin(emailController.text, passwordController.text);
        } else {
          _showDialog('Missing fields!', 'Please type in email and password');
        }
      },
      child: Text(
        'Login',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
    );

    final forgotLabel = TextButton(
      onPressed: () {
        _showDialog('Forgot Password?',
            'Please contact your hospital administrator to reset your password.');
      },
      child: Text(
        "Forgot password?",
        style: TextStyle(
          fontSize: 14,
          color: Color.fromRGBO(82, 121, 180, 1),
          decoration: TextDecoration.underline,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(left: 14.0, right: 14.0, top: 5.0, bottom: 90.0),
          children: <Widget>[
            logo,
            SizedBox(height: 8.0),
            email,
            SizedBox(height: 16.0),
            password,
            SizedBox(height: 20.0),
            loginButton,
            forgotLabel,
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  child: BottomAppBar(
                    color: Colors.white,
                    shape: CircularNotchedRectangle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/WHO.png",
                          height: 70,
                          width: 70,
                        ),
                        Image.asset(
                          "assets/MoNHSRC.png",
                          height: 70,
                          width: 70,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(top: 10),
                    decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(240, 240, 240, 1),
                        Color.fromRGBO(240, 240, 240, 1),
                      ],
                    )),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text('Powered By',
                              style: TextStyle(
                                  color: Color.fromRGBO(130, 131, 133, 1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text('Code for Pakistan',
                              style: TextStyle(
                                  color: Color.fromRGBO(141, 199, 63, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    )),
              ])),
    );
  }

  // ignore: non_constant_identifier_names
  _showDialog(String alertTitle, String alertMsg) {
    BlurryDialog alert = BlurryDialog(alertTitle, alertMsg, []);
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
      var jsonData = json.decode(response.body);
      if (jsonData!['user']!['tokens'] != null) {
        setState(() {
          MySharedPreferences.instance.setStringValue("access_token",
              jsonData!['user']!['tokens']![0]!['accessToken'].toString());
          MySharedPreferences.instance.setBool("loggedIn", true);
          MySharedPreferences.instance
              .setStringValue("user", json.encode(jsonData!['user']));
        });
      }
      Navigator.of(context).pushNamed(HomePage.tag);
    } else {
      _showDialog('Try Again', 'Wrong Email or password');
      return false;
    }
  }
}
