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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Arguments;
    // final Map dataFromHospitalScreen = ModalRoute.of(context).settings.arguments;
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
                              return null;
                            }
                          },
                          // controller: _nameCtrl,
                        ))
                      }
                    else if (field['type'] == 'dropdown')
                      {
                        //     data.add(_buildSelector(
                        //       context: context,
                        //       name: field['label'].toString(),
                        //     ))
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
        print('Steps completed!');
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
        decoration: InputDecoration(
          labelText: labelText,
        ),
        validator: validator,
        controller: controller,
      ),
    );
  }

  Widget _buildDropDown({
    String? labelText,
    List<String>? items,
    String? selectedItem,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        value: selectedItem,
        items: items?.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        })?.toList(),
        onChanged: onChanged,
      ),
    );
  }

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
}
