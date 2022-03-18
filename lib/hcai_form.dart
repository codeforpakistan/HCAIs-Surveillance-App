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
import 'home.dart';

class HcaiFormPage extends StatefulWidget {
  HcaiFormPage({Key? key, this.title}) : super(key: key);
  final String? title;
  static String tag = 'ssi-form-page';
  @override
  _HcaiFormPageState createState() => _HcaiFormPageState();
}

class _HcaiFormPageState extends State<HcaiFormPage> {
  final _formKey = GlobalKey<FormState>();
  Map _values = {};
  Map _selectedRole = {};
  List<dynamic> allSteps = [];
  List<TextEditingController> _controller = [];

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
        title: Text(args.hcaiTitle?.toUpperCase() ?? 'HCAI FORM',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.cancel_outlined, color: Colors.white),
              )),
        ],
      ),
      body: Container(
        child: FutureBuilder(
            future: getHcaiForm(args.hcaiId, args.hospitalId),
            builder: (context, AsyncSnapshot<List> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError) {
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
    this.allSteps = hcaiForm["steps"];
    // ignore: unused_local_variable
    DateTime? selectedDate = DateTime.now();
    final List<CoolStep> steps = [];
    List<Widget> data = [];
    var objToConstruct;
    int currentIndex = 0;
    this.allSteps.forEach((each) => {
          each['fields'].forEach((eachField) => {
                if (each['type'] == 'radiofield') {},
                eachField['index'] = currentIndex,
                currentIndex = currentIndex + 1,
              }),
        });
    _controller = List.generate(currentIndex, (i) => TextEditingController());
    this.allSteps.asMap().forEach((stepIndex, step) => {
          data = [],
          if (stepIndex == 0)
            {
              data.add(Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  hcaiForm['description'].toString(),
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              )),
            },
          if (step['fields'] is List)
            {
              step['fields'].asMap().forEach((fieldIndex, field) => {
                    if (field['type'] == 'text')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                              myController: _controller[field['index']],
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ?? 'N/A',
                              index: field['index'],
                              readOnly: true),
                        )),
                      }
                    else if (field['type'] == 'textfield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                              helpLabelText:
                                  field['helpLabelText'] ?? 'Please enter text',
                              index: field['index']),
                        )),
                      }
                    else if (field['type'] == 'dropdown' &&
                        field['options'] is List)
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildDropDown(
                              key: field['key'].toString(),
                              labelText: field['label'].toString(),
                              options: field['options'],
                              value: field['options'][0]['_id'] != null
                                  ? field['options'][0]['_id']
                                  : field['options'][0]['name'],
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select an option',
                              index: field['index']),
                        )),
                      }
                    else if (field['type'] == 'radiofield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildRadioButton(
                              context: context,
                              title: field['label'].toString(),
                              key: field['key'].toString(),
                              options: field['options']),
                        )),
                      }
                    else if (field['type'] == 'checkboxfield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildCheckbox(
                              context: context,
                              title: field['label'].toString(),
                              options: field['options']),
                        )),
                      }
                    else if (field['type'] == 'datefield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildDateField(
                              hint: field['label'].toString(),
                              selectedDateKey: field['key'],
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select a date',
                              type: 'date'),
                        ))
                      }
                    else if (field['type'] == 'timefield')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildDateField(
                              hint: field['label'].toString(),
                              selectedDateKey: field['key'],
                              hasHelpLabel: field['hasHelpLabel'],
                              helpLabelText: field['helpLabelText'] ??
                                  'Please select a date',
                              type: 'time'),
                        ))
                      },
                  }),
              if (stepIndex == 0)
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
        print(this._values);
        sendData(context, this._values);
      },
      steps: steps,
      config: CoolStepperConfig(
        backText: 'PREVIOUS',
      ),
    );
  }

  Widget _buildDateField(
      {required String hint,
      required String selectedDateKey,
      required bool hasHelpLabel,
      required String helpLabelText,
      type: String}) {
    var nextValue;
    return DateTimeFormField(
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
        initialDate: null,
        // selectedDate: selectedDateKey,
        mode: type == 'time'
            ? DateTimeFieldPickerMode.time
            : DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime value) {
          _onUpdate(selectedDateKey, value.toIso8601String());
          nextValue =
              _getCompletedField(selectedDateKey, value.toIso8601String(), []);
          if (nextValue['controllerIndex'] > -1) {
            _controller[nextValue['controllerIndex']].text = nextValue['value'];
          }
          // selectedDateKey = value;
        });
  }

  Widget _buildTextField(
      {String? labelText,
      FormFieldValidator<String>? validator,
      required TextEditingController myController,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index,
      bool readOnly = false}) {
    var nextValue;
    return TextFormField(
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
      readOnly: readOnly,
      onChanged: (newValue) => {
        nextValue = _getCompletedField(labelText, newValue, []),
        if (nextValue['controllerIndex'] > -1)
          {_controller[nextValue['controllerIndex']].text = nextValue['value']},
        _onUpdate(labelText, newValue),
      },
    );
  }

  Widget _buildDropDown(
      {required String key,
      required String labelText,
      required List<dynamic> options,
      required String value,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index}) {
    var nextValue;
    return DropdownButtonFormField(
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
      onChanged: (String? newValue) => {
        nextValue = _getCompletedField(key, newValue, options),
        if (nextValue['controllerIndex'] > -1)
          {_controller[nextValue['controllerIndex']].text = nextValue['value']},
        _onUpdate(key, newValue)
      },
      items: options.map((option) {
        return DropdownMenuItem(
          value: option['_id'] != null
              ? option['_id'].toString()
              : option['name'].toString(),
          child: Text(option['name'].toString()),
        );
      }).toList(),
    );
  }

  Widget _buildRadioButton(
      {required BuildContext context,
      required String title,
      required String key,
      required List<dynamic> options}) {
    List<Widget> list = [];
    int _groupValue = -1;
    list.add(Text(title,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        )));
    options.asMap().forEach((index, each) => {
          list.add(_buildTile(
              title: each['name'],
              key: key,
              value: index,
              groupValue: _groupValue,
              selected: options[0]['name']))
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget _buildTile(
      {required String title,
      required String key,
      required int value,
      required int groupValue,
      String? selected}) {
    return RadioListTile(
      value: title,
      activeColor: Color(0xFF6200EE),
      groupValue: _selectedRole[key],
      title: Text(title),
      onChanged: (Object? value) {
        setState(() {
          _selectedRole[key] = value;
        });
      },
    );
  }

  Widget _buildCheckbox(
      {required BuildContext context,
      required String title,
      required List<dynamic> options}) {
    List<Widget> list = [];
    list.add(Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        )));
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
      {required String title, required int value, required String selected}) {
    return ListTile(
      visualDensity: VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity),
      title: Text(title, style: Theme.of(context).textTheme.subtitle1!),
      leading: Checkbox(
        value: title == selected ? true : false,
        // groupValue: value,
        activeColor: Color(0xFF6200EE),
        onChanged: (value) => {print(value)},
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

  Map _getCompletedField(String? key, String? value, List<dynamic> options) {
    try {
      switch (key) {
        case 'ICD10Id':
          {
            return {
              'controllerIndex': Helper.getNextControllerIndex(
                  this.allSteps, 'recommendedSurveillancePeriod'),
              'value': options
                  .firstWhere(
                      (each) => each['_id'] == value)['surveillancePeriod']
                  .toString()
            };
          }
        case 'dateOfEvent':
        case 'dateOfProcedure':
          {
            return {
              'controllerIndex': Helper.getNextControllerIndex(
                  this.allSteps, 'infectionSurveyTime'),
              'value': Helper.daysBetweenDate(_values['dateOfEvent'],
                      _values['dateOfProcedure'], 'days')
                  .toString()
            };
          }
        case 'patientDateOfBirth':
          {
            return {
              'controllerIndex':
                  Helper.getNextControllerIndex(this.allSteps, 'patientAge'),
              'value': Helper.daysBetweenDate(_values['patientDateOfBirth'],
                      new DateTime.now().toString(), 'years')
                  .toString()
            };
          }
        default:
          return {'controllerIndex': -1, 'value': ''};
      }
    } catch (e) {
      print(e);
      return {'controllerIndex': -1, 'value': ''};
    }
  }

  _onUpdate(String? key, String? val) {
    _values[key] = val;
    // print(_values);
  }
}

filterData(List<dynamic> allSteps, key, value) {
  if (key == 'departmentId') {
    allSteps.forEach((each) => {
          print(each),
        });
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
      ..show().then((value) => Navigator.of(context).pushNamed(HomePage.tag));
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
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }
}
