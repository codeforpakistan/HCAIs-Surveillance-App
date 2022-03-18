import 'dart:math';

class Helper {
  static int daysBetweenDate(date1, date2, String returnType) {
    try {
      final startDate = DateTime.parse(date1);
      final endDate = DateTime.parse(date2);
      final days = startDate.difference(endDate).inDays;
      switch (returnType) {
        case 'days':
          return days;
        case 'years':
          return days ~/ 365;
        default:
          return days;
      }
    } catch (e) {
      print(e);
      return -1;
    }
  }

  static int bodyMassIndex(weight, height) {
    try {
      final bmi = weight / pow(height, 2);
      return bmi.round();
    } catch (e) {
      print(e);
      return -1;
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
}
