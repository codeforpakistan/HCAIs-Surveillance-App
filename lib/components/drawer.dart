import 'package:flutter/material.dart';
import 'package:hcais/home.dart';
import 'package:hcais/login.dart';
import 'package:hcais/submitted_view.dart';
import 'package:hcais/utils/constants.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var user = Constants.prefs!.getString('user');
    return new SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, //20.0,
      child: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Abhishek Mishra"),
              accountEmail: Text("abhishekm977@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  "A",
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
              leading: Icon(Icons.settings),
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
