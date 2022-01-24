import 'package:flutter/material.dart';
import 'package:hcais/ssi_form.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  @override
  Widget build(BuildContext context) {
    final hospitalIcon = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 60.0,
          backgroundColor: Colors.transparent,
          // backgroundImage: AssetImage('assets/hospital-icon.png'),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/hospital-icon.png',
                  width: 64,
                  height: 64,
                ),
              )
            ],
          ),
        ),
      ),
    );

    final hospitalName = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'PIMS',
        style: TextStyle(
          fontSize: 38.0,
          color: Colors.white,
        ),
      ),
    );
    final surgicalSiteInfections = OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(SsiFormPage.tag);
        },
        style: OutlinedButton.styleFrom(
          minimumSize: Size(100, 40),
          side: BorderSide(
            width: 1.0,
            color: Colors.white,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
          child: Text("Surgical Site Infections (SSIs)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                height: 1.5,
              )),
        ));
    final ventilatorAssociatedInfections = OutlinedButton(
      onPressed: () {
        // Respond to button press
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 40),
        side: BorderSide(
          width: 1.0,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
        child: Text("Ventilator-Associated Infections (VAIs)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              height: 1.5,
            )),
      ),
    );
    final catheterAssociatedUrinaryTractInfections = OutlinedButton(
      onPressed: () {
        // Respond to button press
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 40),
        side: BorderSide(
          width: 1.0,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
        child: Text("Catheter-Associated Urinary Tract Infections (CAUTIs)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              height: 1.5,
            )),
      ),
    );
    final centralLineAssociatedBloodstreamInfections = OutlinedButton(
      onPressed: () {
        // Respond to button press
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 40),
        side: BorderSide(
          width: 1.0,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
        child: Text("Central Line-Associated Bloodstream Infections (CLABIs)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              height: 1.5,
            )),
      ),
    );
    final hcaiButtons = Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            surgicalSiteInfections,
            SizedBox(height: 18.0),
            ventilatorAssociatedInfections,
            SizedBox(height: 18.0),
            catheterAssociatedUrinaryTractInfections,
            SizedBox(height: 18.0),
            centralLineAssociatedBloodstreamInfections,
            SizedBox(height: 18.0),
          ],
        ));

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
          hospitalIcon,
          hospitalName,
          hcaiButtons,
        ],
      ),
    );

    return Scaffold(
      body: body,
    );
  }
}
