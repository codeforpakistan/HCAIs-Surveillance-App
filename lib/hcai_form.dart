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
  List<dynamic> orignalSteps = [];
  List<TextEditingController> _controller = [];
  late Future<List>? _listFuture;

  @override
  void initState() {
    this._values = {};
    super.initState();
    //  find a way to get arguments in init
    // final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    _listFuture =
        getHcaiForm('623826388b1903e2f2d2f3d6', '62205d48109d1e5a55e215b2');
  }

  refresh() async {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    _listFuture = getHcaiForm(args.hcaiId, args.hospitalId);
  }

  @override
  Widget build(BuildContext context) {
    final homeArgs = ModalRoute.of(context)!.settings.arguments as Arguments;
    this._values['hospitalId'] = homeArgs.hospitalId;
    this._values['userId'] = homeArgs.userId;
    return Scaffold(
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
    );
  }

  Widget _formWizard(formData, context) {
    Map<String, dynamic> hcaiForm = formData?.first;
    this.orignalSteps = hcaiForm["steps"].toList();
    this.allSteps = hcaiForm["steps"].toList();
    // ignore: unused_local_variable
    DateTime? selectedDate = DateTime.now();
    final List<CoolStep> steps = [];
    List<Widget> data = [];
    var objToConstruct;
    int currentIndex = 0;
    this.allSteps.forEach((each) => {
          each['fields'].forEach((eachField) => {
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
                        field['options'] is List &&
                        field['options'].length > 0)
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
    if (this._values[selectedDateKey] == null) {
      this._values[selectedDateKey] = '';
    }
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
        initialValue:
            DateTime.tryParse(this._values[selectedDateKey]), //Add this in your
        mode: type == 'time'
            ? DateTimeFieldPickerMode.time
            : DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime value) {
          if (this.mounted) {
            setState(() {
              this._values[selectedDateKey] = value.toIso8601String();
            });
            _setCompleteField(selectedDateKey, value.toIso8601String(), []);
          }
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
    if (myController.text == '' && this._values[key] != null) {
      myController.text = this._values[key];
    }
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
              this._values[key] = newValue,
              _setCompleteField(key, this._values[key], []),
            });
  }

  Widget _buildDropDown(
      {required String key,
      required String labelText,
      required List<dynamic> options,
      required String value,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index}) {
    if (this._values[key] == null) {
      this._values[key] = value;
    }
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
      value: this._values[key].toString(),
      onChanged: (String? newValue) => {
        if (this.mounted)
          {
            setState(() => {this._values[key] = newValue}),
            _setCompleteField(key, newValue, options),
          }
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
        if (this.mounted) {
          setState(() {
            _selectedRole[key] = value;
          });
        }
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

  void _setCompleteField(String? key, String? value, List<dynamic> options) {
    try {
      switch (key) {
        case 'ICD10Id':
          {
            this._values['recommendedSurveillancePeriod'] = options
                .firstWhere(
                    (each) => each['_id'] == value)['surveillancePeriod']
                .toString();
            this._values['ICD10Code'] = options
                .firstWhere((each) => each['_id'] == value)['ICDCode']
                .toString();
            print(this._values['ICD10Code']);
            break;
          }
        case 'dateOfProcedure':
        case 'dateOfEvent':
          {
            this._values['infectionSurveyTime'] = Helper.daysBetweenDate(
                    _values['dateOfProcedure'], _values['dateOfEvent'], 'days')
                .toString();
            break;
          }
        case 'dateOfDischarge':
          {
            this._values['postOpHospitalStay'] = Helper.daysBetweenDate(
                    _values['dateOfProcedure'],
                    _values['dateOfDischarge'],
                    'days')
                .toString();
            break;
          }
        case 'patientDateOfBirth':
          {
            this._values['patientAge'] = Helper.daysBetweenDate(
                    this._values['patientDateOfBirth'],
                    new DateTime.now().toString(),
                    'years')
                .toString();
            break;
          }
        case 'patientWeight':
        case 'patientHeight':
          {
            if (this._values['patientWeight'] != null &&
                this._values['patientHeight'] != null) {
              this._values['bodyMassIndex'] = Helper.bodyMassIndex(
                      this._values['patientWeight'],
                      this._values['patientHeight'])
                  .toString();
              this._values['bodyMassIndexScale'] = Helper.bodyMassIndexScale(
                  this._values['patientWeight'], this._values['patientHeight']);
              _controller[
                      Helper.getNextControllerIndex(allSteps, 'bodyMassIndex')]
                  .text = this._values['bodyMassIndex'];
              _controller[Helper.getNextControllerIndex(
                      allSteps, 'bodyMassIndexScale')]
                  .text = this._values['bodyMassIndexScale'];
            }
            break;
          }
        default:
          break;
      }
    } catch (e) {
      print('error in switch' + e.toString());
    }
  }

  _setState(key, value) {
    if (mounted) {
      setState(() => {this._values[key]: value});
    }
  }

  filterData(key, value) {
    List<dynamic> steps = json.decode(json.encode(orignalSteps));
    if (key == 'departmentId') {
      for (var step in allSteps) {
        if (step["fields"] is List) {
          for (var eachField in step["fields"]) {
            if (eachField['key'] == 'wardId') {
              eachField['options'] = eachField['options']
                  .where((each) => each['departmentId'] == value)
                  .toList();
              break;
            }
          }
        }
      }
      setState(() {
        allSteps = steps;
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
}
