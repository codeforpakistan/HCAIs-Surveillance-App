import 'dart:convert';

import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:hcais/utils/constants.dart';
import 'args/Arguments.dart';
import 'package:http/http.dart' as http;

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
                    return _formWizard(snapshot.data?.first);
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

  Widget _formWizard(Map<String, dynamic> hcaiForm) {
    List<dynamic> allSteps = hcaiForm["steps"];
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
                          myController: new TextEditingController(),
                        )),
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
                  }),
              if (index == 0)
                {
                  objToConstruct =
                      Form(key: _formKey, child: Column(children: data))
                }
              else
                {objToConstruct = Form(child: Column(children: data))},
              steps.add(CoolStep(
                  title: step['stepTitle'].toString(),
                  subtitle: step['stepDescription'].toString(),
                  content: objToConstruct,
                  validation: () {
                    if (!_formKey.currentState!.validate()) {
                      return 'Fill form correctly';
                    }
                    return null;
                  })),
            }
        });
    return CoolStepper(
      showErrorSnackbar: false,
      onCompleted: () {
        print(_result);
      },
      steps: steps,
      config: CoolStepperConfig(
        backText: 'PREV',
      ),
    );
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
        onChanged: (data) => {print(data)},
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
        _onUpdate(labelText, newValue)
      },
      onChanged: (String? newValue) {},
      items: options.map((value) {
        return DropdownMenuItem(
          value: value['name'].toString(),
          child: Text(value['name'].toString()),
        );
      }).toList(),
    );
  }

  _onUpdate(String? key, String? val) {
    _values[key] = val;
    setState(() {
      _result = _values;
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
