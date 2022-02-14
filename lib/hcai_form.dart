import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'args/Arguments.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

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
  var _values = {};
  var _result = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;

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
          if (step['fields'] is List)
            {
              step['fields'].forEach((field) => {
                    if (field['type'] == 'text')
                      {
                        data.add(Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: Text(
                            field['description'].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        )),
                      }
                    else if (field['type'] == 'textfield')
                      {
                        data.add(_buildTextField(
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
                            myController: new TextEditingController())),
                      }
                    else if (field['type'] == 'dropdown')
                      {
                        data.add(
                          _buildDropDown(
                              labelText: field['label'].toString(),
                              options: field['options'],
                              value: field['options'][0]['name']),
                        ),
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
                        data.add(_buildDateField(
                            hint: field['label'].toString(),
                            selectedDate: selectedDate,
                            type: 'date'))
                      }
                    else if (field['type'] == 'timefield')
                      {
                        data.add(_buildDateField(
                            hint: field['label'].toString(),
                            selectedDate: selectedDate,
                            type: 'name'))
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
        sendData(context);
        print('Steps completed!');
        print(this._result);
      },
      steps: steps,
      config: CoolStepperConfig(
        backText: 'PREV',
      ),
    );
  }

  Widget _buildDateField(
      {required String hint, required DateTime selectedDate, type: String}) {
    return DateTimeField(
        decoration: InputDecoration(hintText: hint),
        selectedDate: selectedDate,
        mode: type == 'time'
            ? DateTimeFieldPickerMode.time
            : DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime value) {
          selectedDate = value;
        });
  }

  Widget _buildTextField({
    String? labelText,
    FormFieldValidator<String>? validator,
    required TextEditingController myController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
        ),
        controller: myController,
        onSaved: (newValue) => {
          _onUpdate(labelText, newValue),
        },
      ),
    );
  }

  Widget _buildDropDown({
    required String labelText,
    required List<dynamic> options,
    required String value,
  }) {
    return DropdownButtonFormField(
      hint: Text(labelText),
      value: value,
      onSaved: (String? newValue) => {
        setState(() {
          value = newValue!;
        }),
        _onUpdate(labelText, value)
      },
      onChanged: (String? newValue) {},
      items: options.map((value) {
        return DropdownMenuItem(
          value: value['name'].toString(),
          child: Text(Helper.truncateString(value['name'].toString(), 20)),
        );
      }).toList(),
    );
  }

  Widget _buildRadioButton(
      {required BuildContext context,
      required String title,
      required List<dynamic> options}) {
    List<Widget> list = [];
    list.add(Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    options.forEach((each) => {
          list.add(_buildTile(
              title: each['name'], value: 0, selected: options[0]['name']))
        });
    return Column(
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
    list.add(Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    options.forEach((each) => {
          list.add(_buildCheckBoxTile(
              title: each['name'], value: 0, selected: options[0]['name']))
        });
    return Column(
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

  _onUpdate(String? key, String? val) {
    _values[key] = val;
    setState(() {
      _result = _values;
    });
  }
}

sendData(context) {
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.SUCCES,
      showCloseIcon: false,
      title: 'Succes',
      desc: 'Submitted!',
      onDissmissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      })
    ..show();
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
