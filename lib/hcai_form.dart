import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'args/Arguments.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'components/alertDialog_widget.dart';

class HcaiFormPage extends StatefulWidget {
  HcaiFormPage({Key? key, this.title}) : super(key: key);

  final String? title;

  static String tag = 'ssi-form-page';

  @override
  _HcaiFormPageState createState() => _HcaiFormPageState();
}

class _HcaiFormPageState extends State<HcaiFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRole = 'Writer';
  Map _values = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    this._values['hospitalId'] = args.hospitalId;
    this._values['userId'] = args.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title?.toUpperCase() ?? 'SSI FORM'),
      ),
      body: Container(
        child: FutureBuilder(
            future: getHcaiForm(args.hcaiId, args.hospitalId),
            builder: (context, AsyncSnapshot<List> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  } else if (snapshot.hasData) {
                    return _formWizard(snapshot.data?.first, context);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                default:
                  return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Widget _formWizard(Map<String, dynamic> hcaiForm, context) {
    List<dynamic> allSteps = hcaiForm["steps"];
    DateTime? selectedDate = DateTime.now();
    final List<CoolStep> steps = [];
    List<Widget> data = [];
    var objToConstruct;
    allSteps.asMap().forEach((index, step) => {
          data = [],
          if (index == 0)
            {
              data.add(Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  hcaiForm['description'].toString(),
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              )),
            },
          if (step['fields'] is List)
            {
              step['fields'].forEach((field) => {
                    if (field['type'] == 'text')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: Text(
                            field['description'].toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )),
                      }
                    else if (field['type'] == 'textfield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildTextField(
                              labelText: field['label'].toString(),
                              validator: (value) {
                                if (field['is_required'] == true) {
                                  if (value?.isEmpty ?? true) {
                                    return field['label'].toString() +
                                        " is required";
                                  }
                                }
                                return null;
                              },
                              myController: new TextEditingController(),
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please enter text'),
                        )),
                      }
                    else if (field['type'] == 'dropdown')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildDropDown(
                              key: field['key'].toString(),
                              labelText: field['label'].toString(),
                              options: field['options'],
                              value: field['options'][0]['_id'] != null
                                  ? field['options'][0]['_id']
                                  : field['options'][0]['name'],
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select an option'),
                        )),
                      }
                    else if (field['type'] == 'radiofield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildRadioButton(
                              context: context,
                              title: field['label'].toString(),
                              options: field['options']),
                        )),
                      }
                    else if (field['type'] == 'checkboxfield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildCheckbox(
                              context: context,
                              title: field['label'].toString(),
                              options: field['options']),
                        )),
                      }
                    else if (field['type'] == 'datefield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildDateField(
                              hint: field['label'].toString(),
                              selectedDate: selectedDate,
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select a date',
                              type: 'date'),
                        ))
                      }
                    else if (field['type'] == 'timefield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: _buildDateField(
                              hint: field['label'].toString(),
                              selectedDate: selectedDate,
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select a date',
                              type: 'time'),
                        ))
                      }
                  }),
              if (index == 0)
                {
                  objToConstruct =
                      Form(key: _formKey, child: Column(children: data))
                }
              else
                {objToConstruct = Form(child: Column(children: data))},
              if (data.length > 0)
                {
                  steps.add(CoolStep(
                      title: step['stepTitle'].toString(),
                      subtitle: step['stepDescription'].toString(),
                      content: objToConstruct,
                      validation: () {
                        return null;
                      })),
                }
            }
        });
    return CoolStepper(
      showErrorSnackbar: false,
      onCompleted: () {
        sendData(context, this._values);
        print(this._values);
      },
      steps: steps,
      config: CoolStepperConfig(
        backText: 'PREV',
      ),
    );
  }

  Widget _buildDateField(
      {required String hint,
      required DateTime selectedDate,
      required bool hasHelpLabel,
      required String helpLabelText,
      type: String}) {
    List<Widget> list = [];
    list.add(Text(hint,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    list.add(DateTimeField(
        decoration: InputDecoration(
            hintText: hint,
            suffixIcon: hasHelpLabel
                ? IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(context, helpLabelText);
                    },
                  )
                : null),
        selectedDate: selectedDate,
        mode: type == 'time'
            ? DateTimeFieldPickerMode.time
            : DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime value) {
          selectedDate = value;
        }));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildTextField({
    String? labelText,
    FormFieldValidator<String>? validator,
    required TextEditingController myController,
    required bool hasHelpLabel,
    required String helpLabelText,
  }) {
    List<Widget> list = [];
    // list.add(Text(labelText!,
    //     textAlign: TextAlign.left,
    //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    list.add(TextFormField(
      validator: validator,
      decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: hasHelpLabel
              ? IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    _showDialog(context, helpLabelText);
                  },
                )
              : null),
      controller: myController,
      onChanged: (newValue) => {
        _onUpdate(labelText, newValue),
      },
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildDropDown({
    required String key,
    required String labelText,
    required List<dynamic> options,
    required String value,
    required bool hasHelpLabel,
    required String helpLabelText,
  }) {
    List<Widget> list = [];
    // list.add(Text(labelText,
    //     textAlign: TextAlign.left,
    //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    list.add(DropdownButtonFormField(
      decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: hasHelpLabel
              ? IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    _showDialog(context, helpLabelText);
                  },
                )
              : null),
      isExpanded: true,
      hint: Text(labelText),
      value: value,
      onSaved: (String? newValue) => {
        setState(() {
          value = newValue!;
        }),
      },
      onChanged: (String? newValue) {
        _onUpdate(key, newValue);
      },
      items: options.map((value) {
        return DropdownMenuItem(
          value: value['_id'] != null
              ? value['_id'].toString()
              : value['name'].toString(),
          child: Text(Helper.truncateString(value['name'].toString(), 20)),
        );
      }).toList(),
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildRadioButton(
      {required BuildContext context,
      required String title,
      required List<dynamic> options}) {
    List<Widget> list = [];
    // list.add(Text(title,
    //     textAlign: TextAlign.left,
    //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    options.forEach((each) => {
          list.add(_buildTile(
              title: each['name'], value: 0, selected: options[0]['name']))
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildTile(
      {required String title, required int value, String? selected}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.subtitle1!),
      leading: Radio(
        value: title,
        groupValue: value,
        activeColor: Color(0xFF6200EE),
        onChanged: (value) => {selected = value!.toString()},
      ),
    );
  }

  Widget _buildCheckbox(
      {required BuildContext context,
      required String title,
      required List<dynamic> options}) {
    List<Widget> list = [];
    // list.add(Text(title,
    //     textAlign: TextAlign.center,
    //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    options.forEach((each) => {
          list.add(_buildCheckBoxTile(
              title: each['name'], value: 0, selected: options[0]['name']))
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildCheckBoxTile(
      {required String title, required int value, String? selected}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.subtitle1!),
      leading: Checkbox(
        value: false,
        // groupValue: value,
        activeColor: Color(0xFF6200EE),
        onChanged: (value) => {selected = value!.toString()},
      ),
    );
  }

  _showDialog(BuildContext context, String message) {
    BlurryDialog alert = BlurryDialog("Information", message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _onUpdate(String? key, String? val) {
    _values[key] = val;
    // print(_values);
  }
}

Future<List> getHcaiForm(String hcaiId, String hospitalId) async {
  var data = [];
  var url = Constants.BASE_URL + "/hcai/" + hospitalId + "/" + hcaiId;
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

sendData(context, Map values) async {
  values['isVerified'] = false;
  final response = await http.post(
    Uri.parse(Constants.BASE_URL + "/submissions/"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(values),
  );
  if (response.statusCode == 201) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        showCloseIcon: false,
        title: 'Success',
        desc: 'Submitted!',
        onDissmissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        })
      ..show();
  } else {
    print(response);
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.ERROR,
        showCloseIcon: false,
        title: 'ERROR',
        desc: jsonDecode(response.body).toString(),
        onDissmissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        })
      ..show();
  }
}
