import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/drawer.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'package:http/http.dart' as http;

import 'args/Arguments.dart';

class Submitted extends StatelessWidget {
  static String tag = 'Submitted-page';

  Future<List> getSubmissions() async {
    var data = [];
    var url = Constants.BASE_URL + "/submissions";
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    data = json.decode(utf8.decode(response.bodyBytes));
    final today = DateTime.now();
    var diff;
    data.forEach((each) => {
          each['difference'] = '',
          each['color'] = '',
          if (each['recommendedSurveillancePeriod'] != null)
            {
              diff = Helper.daysBetweenDate(each['createdAt'], today, 'days'),
              diff = (int.parse(each['recommendedSurveillancePeriod']) - diff),
              if (diff == 0)
                {each['color'] = 'green'}
              else if (diff < 0)
                {each['color'] = 'red'},
              each['difference'] = diff.toString()
            }
        });

    data.sort((a, b) => a['difference'].compareTo(b['difference']));
    return data.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(193, 30, 47, 1),
            title: Text(
              'PIMS',
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            )),
        drawer: SideDrawer(),
        body: SafeArea(
            child: Container(
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
              future: getSubmissions(),
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
                    if (snapshot.hasData) {
                      return new ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.all(2),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(((snapshot.data![index]
                                                  ['patientName'] !=
                                              null
                                          ? snapshot.data![index]['patientName']
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '') ??
                                      'N/A')),
                                  backgroundColor: Colors.purple,
                                ),
                                title: Text((snapshot.data![index]
                                            ['patientName'] ??
                                        'N/A') +
                                    ' - ' +
                                    (snapshot.data![index]['pcnOrMrNumber'] ??
                                        'N/A')),
                                subtitle: Text(
                                    'Days left : ' +
                                        (snapshot.data![index]['difference'] !=
                                                ''
                                            ? snapshot.data![index]
                                                ['difference']
                                            : 'N/A'),
                                    style: TextStyle(
                                        color:
                                            snapshot.data![index]!['color'] !=
                                                    ''
                                                ? (snapshot.data![index]![
                                                            'color'] ==
                                                        'red'
                                                    ? Colors.red
                                                    : Colors.green)
                                                : Colors.black)),
                                trailing: Text(snapshot.data![index]
                                        ['createdAt']!
                                    .substring(0, 10)),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    HcaiFormPage.tag,
                                    arguments: new Arguments(
                                        hcaiId: snapshot.data?[index]
                                                ['hcaiId'] ??
                                            '623c4127d8512af7bd13735b',
                                        hospitalId: snapshot
                                            .data?[index]!['hospitalId'],
                                        hcaiTitle: snapshot.data?[index]
                                                ['patientName'] ??
                                            'HCAI Form',
                                        userId: snapshot.data?[index]['userId'],
                                        goodToGo: true,
                                        values: snapshot.data?[index]),
                                  );
                                },
                                // trailing: Icon(Icons.add_a_photo),
                              ),
                            );
                          });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  default:
                    return Center(child: CircularProgressIndicator());
                }
              }),
        )));
  }
}
