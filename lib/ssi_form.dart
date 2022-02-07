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
  var _values = {};
  var _result = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    final fields = args.fields;
    final List<CoolStep> steps = [];
    List<Widget> data = [];
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
                            })),
                      }
                    else if (field['type'] == 'dropdown')
                      {
                        data.add(
                          _buildDropDown(
                              labelText: field['label'].toString(),
                              options:
                                  List<String>.from(field['options'] as List),
                              value: field['options'][0]),
                        ),
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

  Widget _buildDropDown({
    required String labelText,
    required List<String> options,
    required String value,
  }) {
    return DropdownButtonFormField(
      hint: Text(labelText),
      value: value,
      onSaved: (String? newValue) => {
        setState(() {
          value = newValue!;
        })
      },
      onChanged: (String? newValue) {
        setState(() {
          value = newValue!;
          _onUpdate(labelText, newValue);
        });
      },
      items: options.map((value) {
        return DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
    );
  }

  // Widget _buildSelector({
  //   BuildContext? context,
  //   required String name,
  // }) {
  //   final isActive = name == selectedRole;
  //   return Expanded(
  //     child: AnimatedContainer(
  //       duration: Duration(milliseconds: 200),
  //       curve: Curves.easeInOut,
  //       decoration: BoxDecoration(
  //         color: isActive ? Theme.of(context!).primaryColor : null,
  //         border: Border.all(
  //           width: 0,
  //         ),
  //         borderRadius: BorderRadius.circular(8.0),
  //       ),
  //       child: RadioListTile(
  //         value: name,
  //         activeColor: Colors.white,
  //         groupValue: selectedRole,
  //         onChanged: (String? v) {
  //           setState(() {
  //             selectedRole = v;
  //           });
  //         },
  //         title: Text(
  //           name,
  //           style: TextStyle(
  //             color: isActive ? Colors.white : null,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  _onUpdate(String? key, String? val) {
    _values[key] = val;
    setState(() {
      _result = _values;
    });
  }
}
