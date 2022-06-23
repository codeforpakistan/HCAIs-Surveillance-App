import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:hcais/utils/WidgetHelper.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'args/Arguments.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';
import 'components/alertDialog_widget.dart';
import 'home.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MultiSelect {
  final int id;
  final String name;

  MultiSelect({
    required this.id,
    required this.name,
  });
}

class HcaiFormPage extends StatefulWidget {
  HcaiFormPage({Key? key, this.title}) : super(key: key);
  final String? title;
  static String tag = 'ssi-form-page';
  @override
  _HcaiFormPageState createState() => _HcaiFormPageState();
}

class _HcaiFormPageState extends State<HcaiFormPage> {
  Arguments args = new Arguments(
      goodToGo: false,
      hcaiId: '',
      hcaiTitle: '',
      hospitalId: '',
      userId: '',
      values: {},
      reviewed: false,
      isEditedView: false);
  final _formKey = GlobalKey<FormState>();
  Map _values = {};
  Map _selectedRole = {};
  List<dynamic> allSteps = [];
  List<dynamic> originalSteps = [];
  List<TextEditingController> _controller = [];
  late Future<List>? _listFuture;
  bool showFullValue = false;

  @override
  void initState() {
    this._values = {};
    Future.delayed(Duration.zero, () {
      setState(() {
        args = ModalRoute.of(context)!.settings.arguments as Arguments;
      });
      this._values = args.values;
      this._values['hospitalId'] = args.hospitalId;
      this._values['userId'] = args.userId;
      this._values['reviewed'] = args.reviewed;
      this._values['isEditedView'] = args.isEditedView;
      _listFuture = getHcaiForm(args.hcaiId, args.hospitalId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!args.goodToGo) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () async {
        this._showDialog(context, 'Do you want to close?',
            'Your will loose your progress.', true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(193, 30, 47, 1),
          title: Text(Helper.getInitials(args.hcaiTitle.toUpperCase()),
              style: TextStyle(fontSize: 20, color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    this._showDialog(context, 'Do you want to close?',
                        'Your will loose your progress.', true);
                  },
                  child: Icon(Icons.cancel_sharp, color: Colors.white),
                )),
          ],
        ),
        body: Container(
          child: FutureBuilder(
              future: _listFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                  case ConnectionState.active:
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
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }

  Widget _formWizard(formData, context) {
    Map<String, dynamic> hcaiForm = formData?.first;
    this.originalSteps = hcaiForm["steps"].toList();
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                    if (field['isHidden'] != true ||
                        this._values[field['key']] != null)
                      {
                        if (field['type'] == 'text')
                          {
                            if (field['index'] == 0)
                              {
                                _controller[field['index']].text =
                                    field['description'].toString()
                              },
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildTextField(
                                  key: field['key'].toString(),
                                  isRequired: field!['isRequired'] == true,
                                  labelText: field['label'].toString(),
                                  validator: (value) {
                                    if (field['isRequired'] == true) {
                                      if (value?.isEmpty ?? true) {
                                        return field['label'].toString() +
                                            " is required";
                                      }
                                    }
                                    return null;
                                  },
                                  myController: _controller[field['index']],
                                  hasHelpLabel: field['hasHelpLabel'],
                                  helpLabelText:
                                      field['helpLabelText'] ?? 'N/A',
                                  index: field['index'],
                                  readOnly: true,
                                  maskType: ''),
                            )),
                          }
                        else if (field['type'] == 'textfield')
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildTextField(
                                  key: field['key'].toString(),
                                  labelText: field['label'].toString(),
                                  isRequired: field!['isRequired'] == true,
                                  validator: (value) {
                                    if (field['isRequired'] == true) {
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
                                      'Please enter text',
                                  index: field['index'],
                                  maskType: field['maskType'] ?? ''),
                            )),
                          }
                        else if (field['type'] == 'dropdown' &&
                            field['multiple'] == true)
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildMultipleSelect(
                                  isRequired: field!['isRequired'] == true,
                                  key: field['key'].toString(),
                                  options: field['options'],
                                  label: field['label'] ?? 'Please Select',
                                  index: field['index'],
                                  isEditedView:
                                      this._values['isEditedView'] == true),
                            )),
                          }
                        else if (field['type'] == 'searchable')
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildSearchble(
                                isRequired: field!['isRequired'] == true,
                                key: field['key'].toString(),
                                options: field['options'],
                                hasHelpLabel: false,
                                helpLabelText: '',
                                labelText: field['label'].toString(),
                                value: '',
                              ),
                            )),
                          }
                        else if (field['type'] == 'dropdown' &&
                            field['options'] is List &&
                            field['options'].length > 0)
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildDropDown(
                                  isRequired: field!['isRequired'] == true,
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
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildRadioButton(
                                  context: context,
                                  title: field['label'].toString(),
                                  key: field['key'].toString(),
                                  options: field['options'],
                                  truncate: field['truncate'] ?? false,
                                  hiddenFeilds: field['hiddenFeilds'] != null
                                      ? field['hiddenFeilds']
                                      : []),
                            )),
                          }
                        else if (field['type'] == 'checkboxfield')
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildCheckbox(
                                  context: context,
                                  title: field['label'].toString(),
                                  options: field['options']),
                            )),
                          }
                        else if (field['type'] == 'datefield')
                          {
                            data.add(Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildDateField(
                                  isRequired: field!['isRequired'] == true,
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
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: _buildDateField(
                                  isRequired: field!['isRequired'] == true,
                                  hint: field['label'].toString(),
                                  selectedDateKey: field['key'],
                                  hasHelpLabel: field['hasHelpLabel'],
                                  helpLabelText: field['helpLabelText'] ??
                                      'Please select a date',
                                  type: 'time',
                                  selectedDate: DateTime.now()),
                            ))
                          }
                        else if (field['type'] == 'divider')
                          {
                            data.add(Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                                child: Divider(
                                  color: Colors.black,
                                )))
                          }
                      }
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
                      subtitle: '',
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
      },
      steps: steps,
      config: CoolStepperConfig(
          backText: 'PREVIOUS', stepText: 'Step', icon: Icon(null)),
    );
  }

  Widget _buildDateField(
      {required String hint,
      required String selectedDateKey,
      required bool hasHelpLabel,
      required String helpLabelText,
      type: String,
      required DateTime selectedDate,
      required bool isRequired}) {
    if (this._values[selectedDateKey] == null) {
      this._values[selectedDateKey] = '';
    }
    Column childs = WidgetHelper.buildColumn(hint.toString(), isRequired);
    childs.children.add(DateTimeFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromRGBO(242, 242, 242, 1),
            contentPadding: EdgeInsets.fromLTRB(7.0, 1.0, 1.0, 1.0),
            // labelText: labelText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // width: 0.0 produces a thin "hairline" border
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
            ),
            suffixIcon: hasHelpLabel
                ? IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(context, "Information", helpLabelText, false);
                    },
                  )
                : null),
        lastDate: DateTime.now(),
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
            _setCompleteField(selectedDateKey, value.toIso8601String(), [], []);
          }
        }));
    return childs;
  }

  Widget _buildTextField(
      {String? labelText,
      String? key,
      FormFieldValidator<String>? validator,
      required TextEditingController myController,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index,
      bool readOnly = false,
      required String maskType,
      required bool isRequired}) {
    if (myController.text == '' && this._values[key] != null) {
      myController.text = this._values[key];
    }
    Column childs = WidgetHelper.buildColumn(labelText.toString(), isRequired);
    childs.children.add(TextFormField(
        validator: validator,
        keyboardType: Helper.getMaskType(maskType),
        inputFormatters: Helper.getMask(maskType),
        decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? Color.fromRGBO(233, 233, 233, 1)
                : Color.fromRGBO(246, 246, 246, 1),
            contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            // labelText: labelText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // width: 0.0 produces a thin "hairline" border
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
            ),
            suffixIcon: hasHelpLabel
                ? IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(context, "Information", helpLabelText, false);
                    },
                  )
                : null),
        controller: myController,
        readOnly: readOnly,
        onChanged: (newValue) => {
              this._values[key] = newValue,
              _setCompleteField(key, this._values[key] ?? '', [], []),
            }));
    return childs;
  }

  Widget _buildMultipleSelect(
      {required String key,
      required List<dynamic> options,
      required String label,
      required int index,
      required bool isRequired,
      required bool isEditedView}) {
    try {
      if (options.length <= 0) {
        return Container();
      }
      if (this._values[key] != null &&
          this._values[key].runtimeType == String) {
        this._values[key] = [this._values[key]];
      }
      List<dynamic> found = [];
      if (isEditedView) {
        String name = '';
        options.forEach((each) => {
              name = each['name'] != null
                  ? each['name'].toString()
                  : each['title'].toString(),
              each['selected'] = false,
              found = this._values[key] != null
                  ? this
                      ._values[key]!
                      .where((eachSelected) =>
                          (eachSelected!['name'] != null
                              ? eachSelected!['name']!.toString()
                              : eachSelected!['title']!.toString()) ==
                          name)!
                      .toList()!
                  : [],
              if (found.length > 0)
                {
                  each['selected'] = true,
                }
            });
      }
      final _options = options
          .map((each) => MultiSelectItem(
              each,
              each['name'] != null
                  ? each['name'].toString()
                  : each['title'].toString()))
          .toList();
      Column childs = WidgetHelper.buildColumn(label.toString(), isRequired);
      childs.children.add(MultiSelectDialogField(
          buttonIcon: Icon(Icons.arrow_drop_down),
          onConfirm: (val) {
            if (this.mounted) {
              this._values[key] = val;
              setState(() => {this._values[key] = val});
              _setCompleteField(key, val.toString(), options, []);
            }
          },
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey,
              width: 0.0,
            ),
            color: Color.fromRGBO(242, 242, 242, 1),
          ),
          buttonText: Text(''),
          title: Text('Please Select'),
          dialogWidth: MediaQuery.of(context).size.width * 0.9,
          searchable: true,
          items: _options,
          initialValue: isEditedView
              ? options.where((i) => i!['selected'] == true).toList()
              : this._values[key]));
      return childs;
    } catch (err) {
      print(err);
      return Container();
    }
  }

  Widget _buildSearchble(
      {required String key,
      required String labelText,
      required List<dynamic> options,
      required String value,
      required bool hasHelpLabel,
      required String helpLabelText,
      required bool isRequired}) {
    try {
      if (this._values[key] == null) {
        this._values[key] = value;
      }
      String item = '';
      List<String> items = [];
      if (this._values[key] != null &&
          this._values[key] != '' &&
          options.length > 0) {
        try {
          var selected = options.firstWhere((each) =>
              each['_id'] != null &&
              each['_id'].toString() == this._values[key]);
          item =
              selected['name'] != null ? selected['name'] : selected['title'];
        } catch (err) {
          print(err);
        }
      }
      options.forEach((each) => {
            if (each['name'] != null)
              {items.add(each['name'])}
            else if (each['title'] != null)
              {items.add(each['title'])}
          });
      Column childs =
          WidgetHelper.buildColumn(labelText.toString(), isRequired);
      childs.children.add(DropdownSearch<String>(
        mode: Mode.DIALOG,
        showSearchBox: true,
        items: items,
        showSelectedItems: true,
        showAsSuffixIcons: true,
        dropdownSearchDecoration: InputDecoration(
            filled: true,
            fillColor: Color.fromRGBO(242, 242, 242, 1),
            contentPadding: EdgeInsets.fromLTRB(10.0, 1.7, 2.0, 1.7),
            // labelText: labelText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // width: 0.0 produces a thin "hairline" border
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
            ),
            suffixIcon: hasHelpLabel
                ? IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(context, "Information", helpLabelText, false);
                    },
                  )
                : null),
        selectedItem: item,
        onChanged: (v) {
          if (v != '') {
            var newValue = options
                .firstWhere((each) => each['name'] == v || each['title'] == v);
            if (this.mounted && newValue['_id'] != null) {
              setState(() => {this._values[key] = newValue['_id']});
              _setCompleteField(key, newValue['_id'], options, []);
            }
          }
        },
      ));
      return childs;
    } catch (err) {
      print(err);
      return Container();
    }
  }

  Widget _buildDropDown(
      {required String key,
      required String labelText,
      required List<dynamic> options,
      String? value,
      required bool hasHelpLabel,
      required String helpLabelText,
      required int index,
      required bool isRequired}) {
    try {
      if (this._values[key] != null && this._values[key].runtimeType == List) {
        this._values[key] = this._values[key][0]['title'] != ''
            ? this._values[key][0]['title']
            : this._values[key][0]['name'];
      }
      Column childs =
          WidgetHelper.buildColumn(labelText.toString(), isRequired);
      childs.children.add(DropdownButtonFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromRGBO(242, 242, 242, 1),
            contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            // labelText: labelText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              // width: 0.0 produces a thin "hairline" border
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
            ),
            suffixIcon: hasHelpLabel
                ? IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(context, "Information", helpLabelText, false);
                    },
                  )
                : null),
        isExpanded: true,
        hint: Text('Select ' + labelText),
        value: this._values[key] != null ? this._values[key].toString() : null,
        onChanged: (String? newValue) => {
          if (this.mounted)
            {
              setState(() => {this._values[key] = newValue}),
              _setCompleteField(key, newValue, options, []),
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
      ));
      return childs;
    } catch (err) {
      print(err);
      return Container();
    }
  }

  Widget _buildRadioButton({
    required BuildContext context,
    required String title,
    required String key,
    required List<dynamic> options,
    required bool truncate,
    required List<dynamic> hiddenFeilds,
  }) {
    List<Widget> list = [];
    int _groupValue = -1;
    list.add(Text(title,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        )));

    options.asMap().forEach((index, each) => {
          if (this._values[key] != null && this._values[key] == each['name'])
            {this._selectedRole[key] = index},
          list.add(_buildTile(
              title: each['name'],
              key: key,
              value: index,
              groupValue: _groupValue,
              selected: options[0]['name'],
              truncate: truncate,
              hiddenFeilds: hiddenFeilds))
        });
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    ));
  }

  Widget _buildTile({
    required String title,
    required String key,
    required int value,
    required int groupValue,
    String? selected,
    required bool truncate,
    required List<dynamic> hiddenFeilds,
  }) {
    return RadioListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      value: value,
      activeColor: Color(0xFF6200EE),
      groupValue: _selectedRole[key],
      title: new Text(title),
      onChanged: (Object? value) {
        if (this.mounted) {
          setState(() {
            _selectedRole[key] = value;
            _values[key] = title;
          });
          _setCompleteField(key, title, [], hiddenFeilds);
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

  void _setCompleteField(String? key, String? value, List<dynamic> options,
      List<dynamic> hiddenFields) {
    try {
      switch (key) {
        case 'ICD10Id':
          {
            if (options.length > 0) {
              this._values['recommendedSurveillancePeriod'] = options
                  .firstWhere(
                      (each) => each['_id'] == value)['surveillancePeriod']
                  .toString();
              this._values['ICD10Code'] = options
                  .firstWhere((each) => each['_id'] == value)['ICDCode']
                  .toString();
            }

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
        case 'antimicrobialProphylaxisAdministered':
        case 'pathogenCausingSSI':
        case 'secondaryBloodstreamInfection':
        case 'previousHistoryOfBacterialColonization':
        case 'died':
          {
            if (this._values[key] == 'Yes' ||
                this._values[key] == 'Positive Growth') {
              this.unHide(hiddenFields, false);
            } else {
              this.unHide(hiddenFields, true);
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

  unHide(List<dynamic> fields, flag) {
    for (var step in this.allSteps) {
      if (step["fields"] is List) {
        for (var eachField in step["fields"]) {
          var found = fields.firstWhere(
            (eachHiddenField) =>
                eachField['key'] != null &&
                eachHiddenField == eachField['key'].toString(),
            orElse: () => null,
          );
          if (found != null) {
            if (flag == true) {
              this._values.remove(eachField['key']);
            }
            eachField['isHidden'] = flag;
          }
        }
      }
    }
  }

  filterData(key, value) {
    List<dynamic> steps = json.decode(json.encode(originalSteps));
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
    try {
      values['isVerified'] = false;
      if (!Helper.isValidData(this._values)) {
        Helper.showMsg(
            context, 'Please select Department, ICD-10 Code and Ward', true);
        return null;
      }
      print(jsonEncode(values));
      if (values['reviewed'] == true) {
        values['reviewed'] = values['isSSI'] != null;
      }
      final response = await http.post(
        Uri.parse(Constants.BASE_URL + "/submissions/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(values),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
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
          ..show()
              .then((value) => Navigator.of(context).pushNamed(HomePage.tag));
      } else {
        Helper.showMsg(context, jsonDecode(response.body).toString(), true);
      }
    } catch (err) {
      Helper.showMsg(context, err.toString(), true);
    }
  }

  _showDialog(context, String alertTitle, String alertMsg, bool showCancel) {
    List<Widget> buttons = [];
    if (showCancel) {
      buttons.add(new MaterialButton(
        child: Text("No"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
      ));
      buttons.add(new MaterialButton(
        child: Text("Close Anyway"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);
        },
      ));
    }
    BlurryDialog alert = BlurryDialog(alertTitle, alertMsg, buttons);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
