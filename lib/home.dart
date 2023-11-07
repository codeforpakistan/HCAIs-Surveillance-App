import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/drawer.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/utils/WidgetHelper.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/my_shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'args/Arguments.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  static String tag = 'home-page';
  @override
  _HomePagePageState createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePage> {
  String selectedHospital = '';

  void initState() {
    super.initState();
  }

  Future<List> getHcais() async {
    try {
      var data = [];
      final Map user = json
          .decode(await MySharedPreferences.instance.getStringValue('user'));
      var url = Constants.BASE_URL + "/get-hcai-titles";
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'api-key': Constants.API_KEY
        },
        body: jsonEncode({'roles': user['roles'] ?? []}),
      );
      data = json.decode(utf8.decode(response.bodyBytes));
      data[0]['user'] = user;
      return data.toList();
    } on Exception catch (e, s) {
      print(s);
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(193, 30, 47, 1),
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'HCAIs',
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            )),
        drawer: SideDrawer(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(28.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // hospitalIcon,
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
                          if (!snapshot.hasData || snapshot.data!.length == 0) {
                            return Container();
                          }
                          if (snapshot.hasData) {
                            if (snapshot.data![0]!['user']!['hospitals']!
                                        .length >
                                    1 &&
                                this.selectedHospital == '') {
                              return Flexible(
                                  child: _buildDropDown(
                                      hasHelpLabel: true,
                                      helpLabelText: 'Select Hospital',
                                      index: 0,
                                      isRequired: true,
                                      labelText: 'Select Hospital',
                                      options: snapshot
                                          .data![0]!['user']!['hospitals'],
                                      key: 'hospital',
                                      data: snapshot.data,
                                      context: context));
                            }
                          }
                          return new ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 12.0),
                                    child: ElevatedButton(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 10, 5, 10),
                                          child: Text(
                                              snapshot.data?[index]['title']
                                                  ?.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.0,
                                                height: 1.5,
                                              )),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromRGBO(144, 79, 159, 1),
                                          minimumSize: Size(100, 40),
                                          side: BorderSide(
                                            width: 1.0,
                                            color: new Color(0x5279B4),
                                          ),
                                        ),
                                        onPressed: () async {
                                          return route(
                                              context, snapshot.data, index);
                                        }));
                              });
                        default:
                          return Center(child: CircularProgressIndicator());
                      }
                    }),
              ]),
        ));
  }

  route(context, data, index) {
    try {
      var values = new Map.from(data![index] ?? {});
      if (values['_id'] != null) {
        values.remove('_id');
      }
      if (this.selectedHospital == '' &&
          data![0]!['user']!['hospitals']!.length == 1) {
        this.selectedHospital = data![0]!['user']!['hospitals'][0]['_id'];
      }
      return Navigator.of(context).pushNamed(
        HcaiFormPage.tag,
        arguments: new Arguments(
            hcaiId: data?[index]['_id'],
            hospitalId: this.selectedHospital,
            hcaiTitle: data?[index]['category'] ?? data?[index]['title'],
            userId: data![0]!['user']['_id'] ?? '',
            goodToGo: true,
            values: values,
            reviewed: false,
            isEditedView: false,
            submissionEndPoint: data![index]!['submissionEndPoint'] ?? ''),
      );
    } on Exception catch (e, s) {
      print(s);
      print(e);
    }
  }

  Widget _buildDropDown(
      {required String key,
      required String labelText,
      required List<dynamic> options,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index,
      required bool isRequired,
      data,
      context}) {
    try {
      Column childs =
          WidgetHelper.buildColumn(labelText.toString(), isRequired, context);
      childs.children.add(DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(242, 242, 242, 1),
          contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
          // labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            // width: 0.0 produces a thin "hairline" border
            borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          ),
        ), // hint: Text('Select ' + labelText),
        onChanged: (String? newValue) => {
          setState(() {
            this.selectedHospital = newValue.toString();
          }),
          MySharedPreferences.instance
              .setStringValue('hospitalId', newValue!.toString())
        },
        items: options.map((option) {
          return DropdownMenuItem(
            value: option['_id'] != null
                ? option['_id'].toString()
                : option['name'] != null
                    ? option['name'].toString()
                    : option['title'].toString(),
            child: Text(option['name'] != null
                ? option['name'].toString()
                : option['title'].toString()),
          );
        }).toList(),
      ));
      return childs;
    } catch (err) {
      print(err);
      return Container();
    }
  }
}
