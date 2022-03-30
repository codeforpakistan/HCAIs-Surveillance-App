import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'args/Arguments.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  Future<List> getHcais() async {
    var data = [];
    var url = Constants.BASE_URL + "/get-hcai-titles";
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    data = json.decode(utf8.decode(response.bodyBytes));
    return data.toList();
  }

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

    return Scaffold(
        body: Container(
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
      child: Column(children: <Widget>[
        hospitalIcon,
        hospitalName,
        FutureBuilder(
            future: getHcais(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: Colors.white),
                    ));
                  }
                  return new ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 12.0),
                            child: OutlinedButton(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                  child: Text(
                                      snapshot.data?[index]['title']
                                          ?.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        height: 1.5,
                                      )),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(100, 40),
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    HcaiFormPage.tag,
                                    arguments: new Arguments(
                                        hcaiId: snapshot.data?[index]['_id'],
                                        hospitalId: '62205d48109d1e5a55e215b2',
                                        hcaiTitle: snapshot.data?[index]
                                            ['title'],
                                        userId: '621ddb0059e8330e432cdb22',
                                        goodToGo: true),
                                  );
                                }));
                      });
                default:
                  return Center(child: CircularProgressIndicator());
              }
            }),
      ]),
    ));
  }
}
