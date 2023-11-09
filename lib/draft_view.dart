import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcais/components/drawer.dart';
import 'package:hcais/hcai_form.dart';
import 'package:hcais/services/data_service.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/my_shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'args/Arguments.dart';

class DraftView extends StatefulWidget {
  DraftView({Key? key, this.title}) : super(key: key);
  final String? title;
  static String tag = 'draft-page';
  @override
  _DraftState createState() => _DraftState();
}

class _DraftState extends State<DraftView> {
  String searchString = "";
  final dataService = new Service();
  Future<List> getDrafts() async {
    final Map user =
        json.decode(await MySharedPreferences.instance.getStringValue('user'));
    var data = [];
    var url = Constants.BASE_URL + "/draft-by-userId/" + user['_id'];
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
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(193, 30, 47, 1),
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Drafts',
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
                            labelText: 'Search By Draft Name',
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          child: FutureBuilder(
                              future: getDrafts(),
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
                                            return ((snapshot
                                                    .data![index]!['draftName']!
                                                    .toLowerCase()!
                                                    .contains(searchString)))
                                                ? Card(
                                                    elevation: 3,
                                                    margin: EdgeInsets.all(2),
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        child: Text(((snapshot.data![
                                                                            index]![
                                                                        'draftName'] !=
                                                                    null
                                                                ? snapshot
                                                                    .data![
                                                                        index][
                                                                        'draftName']
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
                                                              'draftName'] ??
                                                          'N/A')),
                                                      subtitle: Text(snapshot
                                                          .data![index]
                                                              ?['createdAt']!
                                                          .substring(0, 10)),
                                                      trailing: null,
// new IconButton(
//                                                         icon: new Icon(
//                                                             Icons.delete),
//                                                         onPressed: () async {
//                                                           this
//                                                               .dataService
//                                                               .deleteDraft(
//                                                                   snapshot.data![
//                                                                           index]
//                                                                       ['_id']);
//                                                           await this
//                                                               .getDrafts();
//                                                         },
//                                                       ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          HcaiFormPage.tag,
                                                          arguments: new Arguments(
                                                              hcaiId: snapshot.data?[index]['hcaiId'] ??
                                                                  '623c4127d8512af7bd13735b',
                                                              hospitalId: snapshot
                                                                      .data?[index]![
                                                                  'hospitalId'],
                                                              hcaiTitle:
                                                                  snapshot.data?[index]['patientName'] ??
                                                                      'HCAI Form',
                                                              userId: snapshot
                                                                      .data?[index]![
                                                                  'userId'],
                                                              goodToGo: true,
                                                              values: snapshot
                                                                  .data?[index],
                                                              reviewed: true,
                                                              isEditedView:
                                                                  true,
                                                              submissionEndPoint:
                                                                  snapshot.data?[index]![
                                                                      'submissionEndPoint'],
                                                              draftId: snapshot.data![index]['_id'] ?? ''),
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
