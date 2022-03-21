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
  late Future<List>? _listFuture;

  @override
  void initState() {
    super.initState();
    //  find a way to get arguments in init
    // final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    _listFuture =
        getHcaiForm('623826388b1903e2f2d2f3d6', '62205d48109d1e5a55e215b2');
  }

  refresh() async {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    this._values['hospitalId'] = args.hospitalId;
    this._values['userId'] = args.userId;
    _listFuture = getHcaiForm(args.hcaiId, args.hospitalId);
  }

  @override
  Widget build(BuildContext context) {
    final homeArgs = ModalRoute.of(context)!.settings.arguments as Arguments;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(homeArgs.hcaiTitle?.toUpperCase() ?? 'HCAI FORM',
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
              future: _listFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Center(child: Text(snapshot.error.toString())),
                      );
                    } else if (snapshot.hasData) {
                      return _formWizard(snapshot.data, context);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  default:
                    return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }

  Widget _formWizard(formData, context) {
    Map<String, dynamic> hcaiForm = formData?.first;
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
                        if (field['index'] == 0)
                          {
                            _controller[field['index']].text =
                                field['description'].toString()
                          },
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildTextField(
                              key: field['key'].toString(),
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
                              key: field['key'].toString(),
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
                                  : field['options'][0]['name'] != null
                                      ? field['options'][0]['name']
                                      : field['options'][0]['title'],
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
                              type: 'date',
                              selectedDate: DateTime.now()),
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
                              type: 'time',
                              selectedDate: DateTime.now()),
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
      type: String,
      required DateTime selectedDate}) {
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
        initialDate: selectedDate,
        // selectedDate: selectedDateKey,
        mode: type == 'time'
            ? DateTimeFieldPickerMode.time
            : DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime value) {
          setState(() {
            selectedDate = value;
          });
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
      String? key,
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
        nextValue = _getCompletedField(key, newValue, []),
        if (nextValue['controllerIndex'] > -1)
          {_controller[nextValue['controllerIndex']].text = nextValue['value']},
        _onUpdate(key, newValue),
        if (nextValue['controllerIndex2'] > -1)
          {
            _controller[nextValue['controllerIndex2']].text =
                nextValue['value2']
          },
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
        _onUpdate(key, newValue),
        if (nextValue['controllerIndex2'] > -1)
          {
            _controller[nextValue['controllerIndex2']].text =
                nextValue['value2']
          },
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
                  .toString(),
              'controllerIndex2':
                  Helper.getNextControllerIndex(this.allSteps, 'ICD10Code'),
              'value2': options
                  .firstWhere((each) => each['_id'] == value)['ICDCode']
                  .toString(),
            };
          }
        case 'dateOfProcedure':
        case 'dateOfEvent':
          {
            return {
              'controllerIndex': Helper.getNextControllerIndex(
                  this.allSteps, 'infectionSurveyTime'),
              'value': Helper.daysBetweenDate(_values['dateOfProcedure'],
                      _values['dateOfEvent'], 'days')
                  .toString(),
              'controllerIndex2': -1,
              'value2': ''
            };
          }
        case 'dateOfDischarge':
          {
            return {
              'controllerIndex': Helper.getNextControllerIndex(
                  this.allSteps, 'postOpHospitalStay'),
              'value': Helper.daysBetweenDate(_values['dateOfProcedure'],
                      _values['dateOfDischarge'], 'days')
                  .toString(),
              'controllerIndex2': -1,
              'value2': ''
            };
          }
        case 'patientDateOfBirth':
          {
            print(Helper.daysBetweenDate(_values['patientDateOfBirth'],
                new DateTime.now().toString(), 'years'));
            return {
              'controllerIndex':
                  Helper.getNextControllerIndex(this.allSteps, 'patientAge'),
              'value': Helper.daysBetweenDate(_values['patientDateOfBirth'],
                      new DateTime.now().toString(), 'years')
                  .toString(),
              'controllerIndex2': -1,
              'value2': ''
            };
          }
        case 'patientWeight':
        case 'patientHeight':
          {
            return {
              'controllerIndex':
                  Helper.getNextControllerIndex(this.allSteps, 'bodyMassIndex'),
              'value': Helper.bodyMassIndex(
                      _values['patientWeight'], _values['patientHeight'])
                  .toString(),
              'controllerIndex2': Helper.getNextControllerIndex(
                  this.allSteps, 'bodyMassIndexScale'),
              'value2': Helper.bodyMassIndexScale(
                      _values['patientWeight'], _values['patientHeight'])
                  .toString()
            };
          }
        default:
          return {
            'controllerIndex': -1,
            'value': '',
            'controllerIndex2': -1,
            'value2': ''
          };
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
  print(url);
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
