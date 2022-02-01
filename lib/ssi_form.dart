import 'dart:convert';

import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';

import 'args/Arguments.dart';

class SsiFormPage extends StatefulWidget {
  SsiFormPage({Key? key, this.title}) : super(key: key);

  final String? title;

  static String tag = 'ssi-form-page';

  @override
  _SsiFormPageState createState() => _SsiFormPageState();
}

class _SsiFormPageState extends State<SsiFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRole = 'Writer';
  List<Map<String, dynamic>> _values = [];
  List<TextEditingController> _controllers = [];
  String _result = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    // final Map dataFromHospitalScreen = ModalRoute.of(context).settings.arguments;
    final fields = args.fields;
    final List<CoolStep> steps = [];
    final List<Map<String, TextEditingController>> ctrls = [];
    List<Widget> data = [];
    var label = '';
    int count = -1;
    fields.forEach((step) => {
          data = [],
          if (step is List)
            {
              step.forEach((field) => {
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
                        label = field['label'].toString(),
                        count++,
                        ctrls.insert(
                            count, {label: new TextEditingController()}),
                        print(ctrls[count][label]),
                        data.add(_buildTextField(
                            labelText: field['label'].toString(),
                            validator: (value) {
                              if (field['is_required'] == true) {
                                if (value?.isEmpty ?? true) {
                                  return field['label'].toString() +
                                      " is required";
                                }
                                return null;
                              }
                            },
                            controller: ctrls[count][label]))
                      }
                    else if (field['type'] == 'dropdown')
                      {
                        // data.add(_buildDropDown(content, ))
                      }
                  }),
              steps.add(CoolStep(
                  title: 'Hospital Information',
                  subtitle: 'Please fill the hospital information below',
                  content: Form(key: _formKey, child: Column(children: data)),
                  validation: () {
                    if (!_formKey.currentState!.validate()) {
                      return 'Fill form correctly';
                    }
                    return null;
                  })),
            }
        });

    final stepper = CoolStepper(
      showErrorSnackbar: false,
      onCompleted: () {
        print(_result);
      },
      steps: steps,
      config: CoolStepperConfig(
        backText: 'PREV',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title?.toUpperCase() ?? 'SSI FORM'),
      ),
      body: Container(
        child: stepper,
      ),
    );
  }

  Widget _buildTextField({
    String? labelText,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
        ),
        onChanged: (data) => {_onUpdate(labelText, data)},
      ),
    );
  }

  // Widget _buildDropDown({
  //   BuildContext? context,
  //   required String name,
  // }) {

  // }

  Widget _buildSelector({
    BuildContext? context,
    required String name,
  }) {
    final isActive = name == selectedRole;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context!).primaryColor : null,
          border: Border.all(
            width: 0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: RadioListTile(
          value: name,
          activeColor: Colors.white,
          groupValue: selectedRole,
          onChanged: (String? v) {
            setState(() {
              selectedRole = v;
            });
          },
          title: Text(
            name,
            style: TextStyle(
              color: isActive ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  _onUpdate(String? key, String val) {
    Map<String, dynamic> json = {'key': key, 'value': val};
    _values.add(json);
    setState(() {
      _result = _prettyPrint(_values);
    });
  }

  String _prettyPrint(jsonObj) {
    var encoder = JsonEncoder.withIndent(' ');
    return encoder.convert(jsonObj);
  }
}
