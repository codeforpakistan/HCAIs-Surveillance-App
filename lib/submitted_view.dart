import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/drawer.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'package:http/http.dart' as http;
import 'args/Arguments.dart';

class Submitted extends StatefulWidget {
  Submitted({Key? key, this.title}) : super(key: key);
  final String? title;
  static String tag = 'Submitted-page';
  @override
  _SubmittedState createState() => _SubmittedState();
}

class _SubmittedState extends State<Submitted> {
  String searchString = "";

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
    try {
      final today = DateTime.now();
      int diff = -9999;
      data.forEach((each) => {
            each['difference'] = '0',
            each['color'] = '',
            each['reviewed'] = each['reviewed'] != true ? false : true,
            if (each['recommendedSurveillancePeriod'] != null)
              {
                if (each['dateOfProcedure'] != null &&
                    each['dateOfProcedure'] != "")
                  {
                    diff = Helper.daysBetweenDate(
                        each['dateOfProcedure'], today, 'days'),
                    diff = (int.parse(each['recommendedSurveillancePeriod']) -
                        diff),
                    if (diff == 0 || each['reviewed'] == true)
                      {each['color'] = 'green', diff = 0}
                    else if (diff < 0)
                      {each['color'] = 'red'},
                  },
                each['difference'] = (diff == -9999) ? '0' : diff.toString()
              }
          });

      data.sort((a, b) =>
          int.parse(a['createdAt']).compareTo(int.parse(b['createdAt'])));
    } catch (err) {
      print('error in getSubmissions');
      print(err);
    }
    return data.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(193, 30, 47, 1),
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'PIMS',
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            )),
        drawer: SideDrawer(),
        body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchString = value.toString().toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search By Patient Name/PCN',
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
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
                                            return ((snapshot.data![index]![
                                                                'patientName'] !=
                                                            null &&
                                                        (snapshot.data![index]![
                                                                'patientName']!
                                                            .toLowerCase()!
                                                            .contains(
                                                                searchString)) ||
                                                    (snapshot.data![index]![
                                                                'pcnOrMrNumber'] !=
                                                            null) &&
                                                        snapshot.data![index]![
                                                                'pcnOrMrNumber']!
                                                            .toLowerCase()!
                                                            .contains(
                                                                searchString)))
                                                ? Card(
                                                    elevation: 3,
                                                    margin: EdgeInsets.all(2),
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        child: Text(((snapshot.data![
                                                                            index]![
                                                                        'patientName'] !=
                                                                    null
                                                                ? snapshot
                                                                    .data![
                                                                        index][
                                                                        'patientName']
                                                                    .substring(
                                                                        0, 1)
                                                                    .toUpperCase()
                                                                : '') ??
                                                            'N/A')),
                                                        backgroundColor:
                                                            Colors.purple,
                                                      ),
                                                      title: Text((snapshot
                                                                          .data![
                                                                      index]![
                                                                  'patientName'] ??
                                                              'N/A') +
                                                          ' - ' +
                                                          ('(' +
                                                              (snapshot.data![
                                                                          index]
                                                                      [
                                                                      'pcnOrMrNumber'] ??
                                                                  'N/A') +
                                                              ')')),
                                                      subtitle: Text(
                                                          'Days left : ' +
                                                              (snapshot.data![index]['difference'] != ''
                                                                  ? snapshot.data![index][
                                                                      'difference']
                                                                  : 'N/A') +
                                                              ('\nReviewed: ' +
                                                                  (snapshot.data![index]['reviewed'] ==
                                                                          true
                                                                      ? 'Yes'
                                                                      : 'No')),
                                                          style: TextStyle(
                                                              color: snapshot.data![index]!['color'] !=
                                                                      ''
                                                                  ? (snapshot.data![index]!['color'] ==
                                                                          'red'
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green)
                                                                  : Colors
                                                                      .black)),
                                                      trailing: Text(snapshot
                                                          .data![index]
                                                              ?['createdAt']!
                                                          .substring(0, 10)),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          HcaiFormPage.tag,
                                                          arguments: new Arguments(
                                                              hcaiId: snapshot.data?[index][
                                                                      'hcaiId'] ??
                                                                  '623c4127d8512af7bd13735b',
                                                              hospitalId: snapshot
                                                                      .data?[index]![
                                                                  'hospitalId'],
                                                              hcaiTitle:
                                                                  snapshot.data?[index]['patientName'] ??
                                                                      'HCAI Form',
                                                              userId: snapshot
                                                                      .data?[index]
                                                                  ['userId'],
                                                              goodToGo: true,
                                                              values: snapshot
                                                                  .data?[index],
                                                              reviewed: true,
                                                              isEditedView:
                                                                  true,
                                                              submissionEndPoint: snapshot
                                                                  .data?[index]
                                                                  .submissionEndPoint),
                                                        );
                                                      },
                                                      // trailing: Icon(Icons.add_a_photo),
                                                    ),
                                                  )
                                                : Container();
                                          });
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  default:
                                    return Center(
                                        child: CircularProgressIndicator());
                                }
                              })),
                    ]))));
  }
}
