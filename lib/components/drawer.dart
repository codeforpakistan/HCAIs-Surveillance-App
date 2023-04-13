import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hcais/home.dart';
import 'package:hcais/login.dart';
import 'package:hcais/submitted_view.dart';
import 'package:hcais/utils/my_shared_prefs.dart';

class SideDrawer extends StatefulWidget {
  SideDrawer({Key? key}) : super(key: key);
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  var user;
  @override
  void initState() {
    MySharedPreferences.readPrefStr("user").then((value) => {
          this.setState(() {
            user = json.decode(value) ?? '';
          }),
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (this.user == null) {
      return Container();
    }
    return new SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, //20.0,
      child: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(193, 30, 47, 1)),
              accountName: Text((this.user!['name'] ?? ''),
                  style: new TextStyle(color: Colors.white)),
              accountEmail: Text(this.user!['email'],
                  style: new TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  this.user!['name'] != null
                      ? this.user!['name']!.substring(0, 1)!.toUpperCase()
                      : '',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => new HomePage()))
              },
            ),
            ListTile(
              leading: Icon(Icons.drive_file_move_rounded),
              title: Text("Submitted"),
              onTap: () => {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new Submitted()))
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text("Logout"),
              onTap: () => {
                MySharedPreferences.instance.removeAll(),
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new LoginPage()))
              },
            ),
          ],
        ),
      ),
    );
  }
}
