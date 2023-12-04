import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:intl/intl.dart';

class Helper {
  static List<dynamic> optionsToKeepAge1s = [
    {"name": "Fever (>38°C)", "index": 1},
    {"name": "Hypothermia", "index": 2},
    {"name": "Apnea", "index": 3},
    {"name": "Bradycardia", "index": 4},
    {"name": "Lethargy", "index": 5},
    {"name": "Vomiting", "index": 6},
    {"name": "Suprapubic Tenderness", "index": 7}
  ];

  static int daysBetweenDate(date1, date2, String returnType) {
    try {
      if (isNullOrEmpty(date1) || isNullOrEmpty(date2)) {
        return -1;
      }
      final startDate = DateTime.parse(date1.toString());
      final endDate = DateTime.parse(date2.toString());
      final days = endDate.difference(startDate).inDays;
      switch (returnType) {
        case 'days':
          return days;
        case 'years':
          return days ~/ 365;
        default:
          return days;
      }
    } catch (e) {
      print('date range failed' + e.toString());
      return -1;
    }
  }

  static bool isInfectionLessThanRecomended(
      survilancePeriod, infectionSurveyTime) {
    try {
      if (!isNullOrEmpty(survilancePeriod) &&
          !isNullOrEmpty(infectionSurveyTime)) {
        return int.parse(infectionSurveyTime) < int.parse(survilancePeriod);
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static int bodyMassIndex(String weight, String height) {
    try {
      if (weight == '' || height == '') {
        return 0;
      }
      double w = double.parse(json.encode(json.decode(weight)));
      double h = double.parse(json.encode(json.decode(height)));
      final bmi = w / pow(h, 2);
      return bmi.round();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static String bodyMassIndexScale(weight, height) {
    try {
      // Show Underweight if BMI is less than 18.5, show Normal Weight if BMI is in range of 18.5-22.9, show Over-weight if BMI is in range of 23.0-27.5 and show Obese if BMI is more than 27.5
      if (weight == '' || height == '') {
        return "NA";
      }
      weight = double.parse(weight);
      height = double.parse(height);
      final bmi = weight / pow(height, 2);
      if (bmi < 18.5) {
        return "Underweight";
      } else if (bmi >= 18.5 && bmi <= 22.9) {
        return "Normal Weight";
      } else if (bmi >= 23.0 && bmi <= 27.5) {
        return "Overweight";
      } else {
        return "Obese";
      }
    } catch (e) {
      print(e);
      return "NA";
    }
  }

  static int getNextControllerIndex(List<dynamic> list, String key) {
    int index = -1;
    bool done = false;
    for (var step in list) {
      if (step["fields"] is List) {
        for (var eachField in step["fields"]) {
          if (eachField['key'] == key) {
            index = eachField['index'];
            done = true;
            break;
          }
        }
        if (done) {
          break;
        }
      }
    }
    return index;
  }

  static String truncateWithEllipsis(
      int cutoff, String myString, bool trucate) {
    if (cutoff == -1) {
      cutoff = myString.indexOf('...');
    }
    if (cutoff > -1) {
      return (myString.length <= cutoff)
          ? myString
          : '${myString.substring(0, cutoff)}...';
    } else {
      return myString;
    }
  }

  static isValidData(_values) {
    return _values['requiredFields'].indexWhere(
            (each) => _values![each] == null || _values![each] == '') ==
        -1;
  }

  static missingFields(_values) {
    return _values['requiredFields']
        .where((each) => _values![each] == null || _values![each] == '')!
        .toList();
  }

  static showMsg(context, msg, isError) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: isError ? DialogType.error : DialogType.success,
      showCloseIcon: true,
      title: isError ? 'ERROR' : 'Success',
      desc: msg,
    )..show();
  }

  static String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(3).join()
      : '';

  static TextInputType getMaskType(maskType) {
    if (maskType == 'phone') {
      return TextInputType.phone;
    } else if (maskType == 'cnic' ||
        maskType == 'number' ||
        maskType == 'float') {
      return TextInputType.numberWithOptions(decimal: true);
    } else {
      return TextInputType.text;
    }
  }

  static List<TextInputFormatter> getMask(maskType) {
    if (maskType == 'phone') {
      return [MaskedInputFormatter('0000-0000000')];
    } else if (maskType == 'cnic') {
      return [MaskedInputFormatter('00000-0000000-0')];
    } else if (maskType == 'float') {
      return [MaskedInputFormatter('0.00')];
    } else if (maskType == 'number') {
      return [FilteringTextInputFormatter.digitsOnly];
    } else {
      return [];
    }
  }

  static bool isNullOrEmpty(value) {
    return value == null || value == '';
  }

  static bool isGreaterThan30(infectionSurveyTime) {
    try {
      return int.parse(infectionSurveyTime) <= 30;
    } catch (err) {
      return false;
    }
  }

  static List<MultiSelectItem<dynamic>> getOptions(
      List<dynamic> options, String key, int age) {
    if (key == 'signsorSymptoms') {
      if (age <= 1) {
        options = optionsToKeepAge1s
            .where((option2) =>
                options.any((option1) => option1["name"] != option2["name"]))
            .toList();
      }
    }
    return options
        .map<MultiSelectItem>((each) => MultiSelectItem(
            each,
            each['name'] != null
                ? each['name'].toString()
                : each['title'].toString()))
        .toList();
  }

  static List<MultiSelectItem> mapOptions(
      List<dynamic> options, bool selected) {
    return options
        .map<MultiSelectItem>((each) => MultiSelectItem(
            each,
            each['name'] != null
                ? each['name'].toString()
                : each['title'].toString()))
        .toList();
  }

  static String rangeInText(_values) {
    try {
      var dateToConsider =
          _values['sameDateforSigns/Symptoms&UrineSampleCollection'] == 'No'
              ? _values['dateofUrineSampleCollectionforCulture']
              : _values['dateofAppearanceofFirstSignsorSymptoms'];
      if (isNullOrEmpty(dateToConsider)) return '';
      dateToConsider = DateTime.parse(dateToConsider);
      DateTime startDate = dateToConsider.subtract(Duration(days: 3));
      DateTime endDate = dateToConsider.add(Duration(days: 3));
      return '${DateFormat('MMMM d').format(startDate)} - ${DateFormat('d').format(endDate)}';
    } catch (e) {
      print(e);
      return '';
    }
  }

  static greaterThanDate(dateList, criteria, _values) {
    try {
      if (criteria == 'smallest') {}
      if (dateList.isEmpty) {
        throw Exception('The date list is empty.');
      }
      var poulatedList = [];
      dateList.forEach((each) => {
            if (isNullOrEmpty(_values[each]) == false)
              {poulatedList.add(DateTime.parse(_values[each]))}
          });
      DateTime smallestDate = poulatedList.reduce((current, next) {
        if (current is DateTime && next is DateTime) {
          return current.isBefore(next) ? current : next;
        } else {
          return null;
        }
      });
      return smallestDate;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
