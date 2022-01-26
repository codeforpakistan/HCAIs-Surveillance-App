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
    print(fields);
    final List<CoolStep> steps1 = [];
    var a = [
      [
        {
          "name": "hcai_definition",
          "description":
              "SSI or Surgical Site Infection is an infection that occurs after surgery in the part of the body where the surgery took place.",
          "label": "HCAI",
          "type": "text",
          "options": [],
          "is_required": false,
          "has_help_label": false,
          "help_label_text": null
        },
        {
          "name": "hospital_name",
          "description": "Pakistan Institute of Medical Sciences (PIMS)",
          "label": "Hospital Name",
          "type": "text",
          "options_from": "array",
          "options": [],
          "is_required": false,
          "has_help_label": false,
          "help_label_text": null
        },
        {
          "name": "department",
          "description": "Department where the HCAI occured",
          "label": "Department",
          "type": "dropdown",
          "options": [
            "Department 1",
            "Department 2",
            "Department 3",
            "Department 4",
            "Department 5"
          ],
          "is_required": true,
          "has_help_label": false,
          "help_label_text": null
        },
        {
          "name": "unit_or_ward",
          "description": "Ward or Unit where the HCAI occured",
          "label": "Unit / Ward",
          "type": "textfield",
          "options": [],
          "is_required": true,
          "has_help_label": false,
          "help_label_text": null
        }
      ],
      [
        {
          "name": "cnic",
          "description": "CNIC of the patient",
          "label": "CNIC",
          "type": "textfield",
          "options": [],
          "is_required": true,
          "has_help_label": true,
          "help_label_text": "CNIC of the patient"
        },
        {
          "name": "pcr_or_mr_number",
          "description": "PCR / MR number of the patient",
          "label": "PCR / MR Number",
          "type": "textfield",
          "options": [],
          "is_required": true,
          "has_help_label": true,
          "help_label_text": "PCR / MR number of the patient"
        },
        {
          "name": "patient_name",
          "description": "Patient Name",
          "label": "Patient Name",
          "type": "textfield",
          "options": [],
          "is_required": true,
          "has_help_label": false,
          "help_label_text": null
        }
      ]
    ];
    List<Widget> data = [];
    a.forEach((each) => {
          data = [],
          if (each is List)
            {
              each.forEach((eachItem) => {
                    if (eachItem['type'] == 'textfield')
                      {
                        data.add(_buildTextField(
                            labelText: eachItem['label'].toString()))
                      }
                  }),
              steps1.add(CoolStep(
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
      steps: steps1,
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

// class _SsiFormPageState extends State<SsiFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? selectedRole = 'Writer';
//   final TextEditingController _nameCtrl = TextEditingController();
//   final TextEditingController _emailCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final formName = Padding(
//       padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 15.0),
//       child: Text(
//         'Surgical Site Inspections (SSIs) Form',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: 28.0,
//           color: Colors.white,
//         ),
//       ),
//     );

//     final body = Container(
//       width: MediaQuery.of(context).size.width,
//       padding: EdgeInsets.all(28.0),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.blue,
//             Colors.lightBlueAccent,
//           ],
//         ),
//       ),
//       child: Column(
//         children: <Widget>[
//           formName,
//         ],
//       ),
//     );

//     return Scaffold(
//       body: body,
//     );
//   }
// }