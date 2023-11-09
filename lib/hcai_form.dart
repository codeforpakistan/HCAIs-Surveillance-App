import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:hcais/components/FormElements.dart';
import 'package:hcais/utils/WidgetHelper.dart';
import 'package:hcais/utils/constants.dart';
import 'package:hcais/utils/helper.dart';
import 'package:hcais/utils/validation.dart';
import 'package:hcais/services/data_service.dart';
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
      isEditedView: false,
      submissionEndPoint: '',
      draftId: '');
  final dataService = new Service();
  final formElements = new FormElements();
  final _formKey = GlobalKey<FormState>();
  Map _values = {};
  String draftId = '';
  Map _selectedRole = {};
  List<dynamic> allSteps = [];
  List<dynamic> originalSteps = [];
  List<TextEditingController> _controller = [];
  late Future<List>? _listFuture;
  bool showFullValue = false;
  bool isSubmitted = false;
  Timer? _debounce;

  @override
  void initState() {
    this._values = {};
    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        setState(() {
          args = ModalRoute.of(context)!.settings.arguments as Arguments;
        });
        this._values = args.values;
        this._values['hospitalId'] = args.hospitalId;
        this._values['submissionEndPoint'] = args.submissionEndPoint;
        this._values['hcaiId'] = args.hcaiId;
        this._values['userId'] = args.userId;
        this._values['reviewed'] = args.reviewed;
        this._values['isSubmitted'] = false;
        this._values['isEditedView'] = args.isEditedView;
        this._values['draftId'] = args.draftId;
        if (args.draftId != '') {
          setState(() => this.draftId = args.draftId);
        }
        _listFuture = getHcaiForm(args.hcaiId, args.hospitalId);
      } else {
        Navigator.of(context).pushNamed(HomePage.tag);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    this.allSteps = [];
    this.allSteps = [];
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!args.goodToGo) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () async {
        this._showDialog(context, 'Do you want to close?',
            'Your Progress will be saved as Draft.', true, false, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(193, 30, 47, 1),
          title: Text(args.hcaiTitle.toUpperCase(),
              style: TextStyle(fontSize: 20, color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    this._showDialog(
                        context,
                        'Do you want to close?',
                        'Your progress will be Saved as Draft.',
                        true,
                        false,
                        false);
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
    final List<CoolStep> steps = [];
    try {
      Map<String, dynamic> hcaiForm = formData?.first;
      this.originalSteps = hcaiForm["steps"].toList();
      this.allSteps = hcaiForm["steps"].toList();
      // ignore: unused_local_variable
      DateTime? selectedDate = DateTime.now();
      List<Widget> data = [];
      var objToConstruct;
      int currentIndex = 0;
      this.allSteps.forEach(
            (each) => each['fields'].forEach((eachField) => {
                  eachField['index'] = currentIndex,
                  currentIndex = currentIndex + 1,
                }),
          );
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
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
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
                                    key: field['key']!.toString(),
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
                          else if (field['type'] == 'label')
                            {
                              data.add(Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                child: Text(field['label'].toString(),
                                    style: TextStyle(
                                        fontSize: field['fontSize'] ?? 13)),
                              ))
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
                                        this._values['isEditedView'] == true,
                                    conditions: field!['conditions'] ?? [],
                                    andConditions: field!['andConditions'] ??
                                        {'conditions': []},
                                    hasHelpLabel:
                                        field['hasHelpLabel'] ?? false,
                                    helpLabelText: field['helpLabelText'] ??
                                        'Please select an option',
                                  ))),
                            }
                          else if (field['type'] == 'searchable')
                            {
                              data.add(Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: _buildSearchble(
                                  isRequired: field!['isRequired'] == true,
                                  key: field['key'].toString(),
                                  options: field['options'],
                                  hasHelpLabel: field['hasHelpLabel'] ?? false,
                                  helpLabelText: field['helpLabelText'] ?? '',
                                  labelText: field['label'].toString(),
                                  value: '',
                                  onChange: field['onChange'] ?? '',
                                  type: field['type'] ?? '',
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
                                  index: field['index'],
                                  conditions: field!['conditions'] ?? [],
                                ),
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
                                    readOnly: field['readOnly'] ?? false,
                                    helpLabelText: field['hasHelpLabel']
                                        ? field['helpLabelText']
                                        : '',
                                    hiddenFeilds: field['hiddenFeilds'] != null
                                        ? field['hiddenFeilds']
                                        : [],
                                    conditions: field!['conditions'] ?? []),
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
                                    selectedDate: DateTime.now(),
                                    calculateDates:
                                        field!['calculateDates'] ?? {}),
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
                                    selectedDate: DateTime.now(),
                                    calculateDates:
                                        field!['calculateDates'] ?? {}),
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
                        // validation: () {
                        //   if (!(_formKey.currentState != null &&
                        //       _formKey.currentState!.validate())) {
                        //     return 'Please Fill All required * fields';
                        //   }
                        //   return null;
                        // })),
                        validation: () {
                          handleDraft();
                          return null;
                        })),
                  }
              }
          });
    } on Exception catch (e, s) {
      print(s);
    }
    return CoolStepper(
      showErrorSnackbar: true,
      onCompleted: () {
        sendData(context, this._values, false);
      },
      steps: steps,
      config: CoolStepperConfig(
          backText: 'PREVIOUS', stepText: 'Step', icon: Icon(null)),
    );
  }

  handleDraft() async {
    try {
      this._values['draftName'] =
          this._values['pcnOrMrNumber'] ?? '' + DateTime.now().toString();
      if (this.draftId == '') {
        this.dataService.createDraft(this._values).then((value) => {
              if (value != '')
                {
                  print(value),
                  setState(() => this.draftId = value),
                }
            });
      } else {
        this.dataService.updateDraft(this._values, this.draftId);
      }
    } catch (err) {
      print(err);
    }
  }

  Widget _buildDateField(
      {required String hint,
      required String selectedDateKey,
      required bool hasHelpLabel,
      required String helpLabelText,
      String? type,
      required DateTime selectedDate,
      required bool isRequired,
      calculateDates = const {}}) {
    if (this._values[selectedDateKey] == null) {
      this._values[selectedDateKey] = '';
    }
    Column childs =
        WidgetHelper.buildColumn(hint.toString(), isRequired, context);
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
                      _showDialog(context, "Information", helpLabelText, false,
                          false, false);
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
            _setCompleteField(selectedDateKey, value.toIso8601String(), [], [],
                [], [], calculateDates);
          }
        }));
    return childs;
  }

  Widget _buildTextField(
      {String? labelText,
      required String key,
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
    Column childs =
        WidgetHelper.buildColumn(labelText.toString(), isRequired, context);
    childs.children.add(TextFormField(
        validator: validator,
        keyboardType: Helper.getMaskType(maskType),
        // inputFormatters: Helper.getMask(maskType),
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
                      _showDialog(context, "Information", helpLabelText, false,
                          false, false);
                    },
                  )
                : null),
        controller: myController,
        readOnly: readOnly,
        onChanged: (newValue) => {
              if (_debounce?.isActive ?? false) _debounce?.cancel(),
              _debounce = Timer(const Duration(milliseconds: 500), () {
                // do something with query
                this._values[key] = newValue;
                _setCompleteField(key, this._values[key] ?? '', [], []);
              }),
            }));
    return childs;
  }

  Widget _buildMultipleSelect(
      {required String key,
      required List<dynamic> options,
      required String label,
      required int index,
      required bool isRequired,
      required bool isEditedView,
      List<dynamic> conditions = const [],
      andConditions = const {},
      required bool hasHelpLabel,
      required String helpLabelText}) {
    try {
      bool isWithInRange = false;
      if (options.length <= 0) {
        return Container();
      }
      if (this._values[key] != null &&
          this._values[key].runtimeType == String) {
        this._values[key] = [this._values[key]];
      }
      List<dynamic> found = [];
      if (key == 'superficialSurgicalSiteInfection' ||
          key == 'deepSurgicalSiteInfection') {
        isWithInRange =
            Helper.isGreaterThan30(this._values['infectionSurveyTime']);
      }
      if (isEditedView || isWithInRange) {
        String name = '';
        int counter = 0;
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
                },
              if (counter == 0 && isWithInRange)
                {
                  each['selected'] = true,
                },
              counter++,
            });
      }
      final _options = options
          .map((each) => MultiSelectItem(
              each,
              each['name'] != null
                  ? each['name'].toString()
                  : each['title'].toString()))
          .toList();

      var initialValue = (isEditedView || isWithInRange)
          ? options.where((i) => i!['selected'] == true).toList()
          : this._values[key] ?? [];
      Column childs = WidgetHelper.buildColumn(label.toString(), isRequired,
          context, hasHelpLabel ? helpLabelText : '');
      childs.children.add(MultiSelectDialogField(
          buttonIcon: Icon(Icons.arrow_drop_down),
          onConfirm: (val) {
            if (this.mounted) {
              this._values[key] = val;
              setState(() => this._values[key] = val);
              _setCompleteField(
                  key, val.toString(), options, [], conditions, andConditions);
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
          initialValue: initialValue));
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
      required bool isRequired,
      required String onChange,
      required String type}) {
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
      Column childs = WidgetHelper.buildColumn(labelText.toString(), isRequired,
          context, hasHelpLabel ? helpLabelText : '');
      childs.children.add(DropdownSearch<String>(
        items: items,
        enabled: true,
        dropdownDecoratorProps: DropDownDecoratorProps(
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
                        _showDialog(context, "Information", helpLabelText,
                            false, false, false);
                      },
                    )
                  : null),
        ),
        popupProps: PopupProps.menu(
            showSearchBox: true, isFilterOnline: true, showSelectedItems: true),
        selectedItem: item,
        onChanged: (v) async {
          if (v != '') {
            var newValue = options
                .firstWhere((each) => each['name'] == v || each['title'] == v);
            if (onChange != '' && type != '') {
              final response = await this
                  .dynamicOnChangeRequest(onChange, newValue['name'], key);
              _setAddressValues(response);
            }
            if (this.mounted && newValue['_id'] != null) {
              setState(() => this._values[key] = newValue['_id']);
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
      required bool isRequired,
      List<dynamic> conditions = const []}) {
    try {
      if (this._values[key] != null && this._values[key].runtimeType == List) {
        this._values[key] = this._values[key][0]['title'] != ''
            ? this._values[key][0]['title']
            : this._values[key][0]['name'];
      }
      Column childs =
          WidgetHelper.buildColumn(labelText.toString(), isRequired, context);
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
                      _showDialog(context, "Information", helpLabelText, false,
                          false, false);
                    },
                  )
                : null),
        isExpanded: true,
        // hint: Text('Select ' + labelText),
        value: this._values[key] != null ? this._values[key].toString() : null,
        onChanged: (String? newValue) => {
          if (this.mounted)
            {
              setState(() => this._values[key] = newValue),
              _setCompleteField(key, newValue, options, [], conditions),
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

  Widget _buildRadioButton(
      {required BuildContext context,
      required String title,
      required String key,
      required List<dynamic> options,
      required bool truncate,
      required bool readOnly,
      required String helpLabelText,
      required List<dynamic> hiddenFeilds,
      List<dynamic> conditions = const []}) {
    List<Widget> list = [];
    int _groupValue = -1;
    list.add(Row(
      children: [
        Flexible(
            child: Text(title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ))),
        !Helper.isNullOrEmpty(helpLabelText)
            ? new IconButton(
                icon: new Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Information'),
                      content: Text(helpLabelText),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(),
        SizedBox(width: 8), // Add some spacing/ Title
      ],
    ));
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
              readOnly: readOnly,
              helpLabelText: helpLabelText,
              hiddenFeilds: hiddenFeilds,
              conditions: conditions))
        });
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    ));
  }

  Widget _buildTile(
      {required String title,
      required String key,
      required int value,
      required int groupValue,
      String? selected,
      required bool truncate,
      required bool readOnly,
      required String helpLabelText,
      required List<dynamic> hiddenFeilds,
      List<dynamic> conditions = const []}) {
    return RadioListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      value: value,
      activeColor: Color(0xFF6200EE),
      groupValue: _selectedRole[key],
      title: Text(title,
          maxLines: 10,
          softWrap: true,
          style: readOnly
              ? TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                )
              : null),
      onChanged: (Object? value) {
        if (this.mounted && !readOnly) {
          setState(() {
            _selectedRole[key] = value;
            _values[key] = title;
          });
          _setCompleteField(key, title, [], hiddenFeilds, conditions);
        }
      },
    );
  }

  _setAddressValues(data) {
    if (data['district'] != null) {
      this._values['patientDistrict'] =
          data['district']['title'] + '-' + data['district']['code'];
      this._values['patientProvince'] =
          data['province']['title'] + '-' + data['province']['code'];
    }
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
    options.forEach((each) => list.add(_buildCheckBoxTile(
        title: each['name'], value: 0, selected: options[0]['name'])));
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
      title: Text(title, style: Theme.of(context).textTheme.titleMedium!),
      leading: Checkbox(
        value: title == selected ? true : false,
        // groupValue: value,
        activeColor: Color(0xFF6200EE),
        onChanged: (value) => {print(value)},
      ),
    );
  }

  void _setCompleteField(String key, String? value, List<dynamic> options,
      List<dynamic> hiddenFields,
      [List<dynamic> conditions = const [],
      andConditons = const {'conditions': []},
      calculateDates = const []]) async {
    try {
      var matches = [];
      switch (key) {
        case 'isSSI':
          {
            this.updateFormFieldsBaseOnIsSS();
            break;
          }
        case 'ICD10Id':
          {
            if (options.length > 0) {
              var survilancePeriod = options
                  .firstWhere(
                      (each) => each['_id'] == value)['surveillancePeriod']
                  .toString();
              this._values['recommendedSurveillancePeriod'] = survilancePeriod;
              this._values['ICD10Code'] = options
                  .firstWhere((each) => each['_id'] == value)['ICDCode']
                  .toString();
              this._values['isSSI'] = Helper.isInfectionLessThanRecomended(
                      this._values['infectionSurveyTime'], survilancePeriod)
                  ? 'No'
                  : 'Yes';
              this.updateFormFieldsBaseOnIsSS();
            }
            break;
          }
        case 'dateOfProcedure':
        case 'dateOfEvent':
          {
            this._values['infectionSurveyTime'] = Helper.daysBetweenDate(
                    _values['dateOfProcedure'], _values['dateOfEvent'], 'days')
                .toString();
            this._values['isSSI'] = Helper.isInfectionLessThanRecomended(
                    this._values['infectionSurveyTime'],
                    this._values['recommendedSurveillancePeriod'])
                ? 'No'
                : 'Yes';
            this.updateFormFieldsBaseOnIsSS();
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
        case 'sSICriteria':
          {
            for (var each in this._values[key]) {
              if (each['name'] == 'Signs & Symptoms') {
                this.unHide(['signsAndSymptoms'], false);
              }
              if (each['name'] == 'Laboratory') {
                this.unHide(['laboratory'], false);
              }
              if (each['name'] == 'Clinical Diagnosis') {
                this.unHide(['clinicalDiagnosis'], false);
              }
            }
            break;
          }
        default:
          var allForceHidden = [];
          if (conditions.length > 0) {
            // ignore: unnecessary_set_literal
            conditions.forEach((each) => {
                  matches.add({
                    'key': each!['key'],
                    'unHide': each!['unHide'],
                    'childHiddenFields': each['childHiddenFields'] ?? [],
                    'shouldHide': this._values[each!['key']] is String
                        ? (this._values[each!['key']] == each[each!['key']] ||
                            each[each!['key']] == 'all')
                        : this._values[each!['key']]!.indexWhere((eachIndex) =>
                                eachIndex!['name'] == each[each!['key']]) >
                            -1
                  }),
                  if (!Helper.isNullOrEmpty(each!['forceHide']) &&
                      each!['forceHide']!.length > 0)
                    {
                      allForceHidden.addAll(each['forceHide']),
                    }
                });
          }
          // force hidden fields
          // handle and conditions
          if (andConditons.length > 0 &&
              andConditons?['conditions']?.length > 0) {
            String localKey = andConditons?['key'] ?? '';
            this._values[localKey] = Validation.handleAndConditions(
                this._values,
                andConditons['conditions'],
                andConditons['returnType']);
            setState(() {
              _selectedRole[localKey] = this._values[localKey];
            });
          }
          if (matches.length > 0) {
            matches.forEach((each) => {
                  if (each!['unHide']!.length > 0)
                    {
                      // if parent elements are going to hide, hide the child even if they are dependent on subchild
                      if (each!['shouldHide'] == false &&
                          each!['childHiddenFields']!.length > 0)
                        {each!['unHide']!.addAll(each!['childHiddenFields'])},
                      this.unHide(each!['unHide'], !each!['shouldHide']),
                    }
                });
          }
          if (allForceHidden.length > 0) {
            this.unHide(allForceHidden, true);
          }
          if (calculateDates.length > 0) {
            calculateDates.forEach((eachCalculation) => {
                  _values[eachCalculation['calculatedKey']] =
                      Helper.daysBetweenDate(
                              _values[eachCalculation!['to']] ?? '',
                              _values[eachCalculation!['from']] ?? '',
                              'days')
                          .toString()
                });
          }
          break;
      }
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  Future<dynamic> dynamicOnChangeRequest(url, newValue, key) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.BASE_URL + '/' + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({key: newValue}),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return {};
    } catch (err) {
      print('error fetching adddress');
      return {};
    }
  }

  updateFormFieldsBaseOnIsSS() {
    setState(() {
      _selectedRole['isSSI'] = this._values['isSSI'];
    });
    // show simple alert
    if (this._values['isSSI'] == 'No') {
      this._showDialog(
          context,
          'Surgical Site Infection (SSI) event criteria has not been met. SSI does not exist.',
          'Your data will be saved.',
          true,
          true,
          false);
    }
    // if (this._values['isSSI'] == 'No') {
    //   this.updateFlagForAll(this.allSteps, true, 'SSIDetected');
    // } else if (this._values['isSSI'] == 'Yes') {
    //   // this.allSteps = this.originalSteps;
    //   this.updateFlagForAll(this.allSteps, false, 'SSIDetected');
    // }
  }

  unHide(List<dynamic> fields, flag) {
    if (fields.length > 0) {
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
  }

  updateFlagForAll(List<dynamic> fields, flag, key) {
    bool found = false;
    for (var step in this.allSteps) {
      if (step["fields"] is List) {
        for (var eachField in step["fields"]) {
          if (!found) {
            found = eachField['key'] == key;
          }
          if (found) {
            if (flag == true) {
              this._values.remove(eachField['key']);
            }
            eachField['isHidden'] = flag;
          }
        }
      }
    }
  }

  getSubmissionCount(String hcaiId, String hospitalId) async {
    try {
      var data = {};
      var url = Constants.BASE_URL +
          "/submissions/count/" +
          hospitalId +
          "/" +
          hcaiId;
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      data = json.decode(utf8.decode(response.bodyBytes));
      return data['count'] ?? 0;
    } on Exception catch (e, s) {
      print(s);
      print(e);
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

  sendData(context, Map values, bool forcedSubmit) async {
    try {
      if (isSubmitted) {
        print('stopping duplicate submission');
        return;
      }
      values['isVerified'] = false;
      values['isSubmitted'] = true;
      if (!Helper.isValidData(this._values) && !forcedSubmit) {
        Helper.showMsg(
            context,
            'Please select ' + Helper.missingFields(this._values)!.join(', '),
            true);
        return null;
      }
      setState(() {
        isSubmitted = true;
      });
      // print(jsonEncode(values));
      if (values['reviewed'] == true) {
        values['reviewed'] = values['isSSI'] != null;
      }
      final response = await http.post(
        Uri.parse(Constants.BASE_URL + this._values['submissionEndPoint']),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(values),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        this.dataService.deleteDraft(this.draftId);
        AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.success,
            showCloseIcon: false,
            title: 'Success',
            desc: 'Submitted!',
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
              Navigator.of(context).pushNamed(HomePage.tag);
            })
          ..show();
      } else {
        Helper.showMsg(context, jsonDecode(response.body).toString(), true);
      }
    } catch (err) {
      Helper.showMsg(context, err.toString(), true);
    }
  }

  _showDialog(context, String alertTitle, String alertMsg, bool showOnlyCancel,
      bool shouldSave, bool showOnlyClose) {
    List<Widget> buttons = [];
    if (showOnlyClose) {
      buttons.add(new MaterialButton(
        child: Text("No"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
      ));
    }
    if (showOnlyCancel) {
      buttons.add(new MaterialButton(
        child: Text("Close"),
        onPressed: () {
          if (shouldSave) {
            sendData(context, this._values, true);
          } else {
            handleDraft();
          }
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
