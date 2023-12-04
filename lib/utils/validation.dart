class Validation {
  static bool handleCriteria(
      value1, value2, String comparisionType, String criteria) {
    if (criteria == '>') {
      return isLessThan(value2, value1, comparisionType);
    } else if (criteria == '<') {
      return isLessThan(value1, value2, comparisionType);
    } else if (criteria == '==') {
      return isEqual(value1, value2, comparisionType);
    } else if (criteria == 'in' || criteria == 'and' || criteria == 'nin') {
      //now all values of array 2 which is in value2 must be in 1 otherwise false
      return hasValue1ContainsValue2(value1, value2, criteria);
    } else if (criteria == 'or') {
      return handSingleDropDown(value1, value2, criteria);
    } else {
      return false;
    }
  }

  static hasValue1ContainsValue2(value1, value2, criteria) {
    if (!isNullOrEmpty(value1) &&
        !isNullOrEmpty(value2) &&
        value1?.length > 0 &&
        value2?.length > 0) {
      value2 = value2.where((element) => element != null).cast<int>().toList();
      if (criteria == 'and') {
        return value2?.every((value) =>
            !isNullOrEmpty(value) &&
            value1.any(
                (map) => map.containsKey("index") && map["index"] == value));
      } else if (criteria == 'in') {
        return value2?.any((value) =>
            !isNullOrEmpty(value) &&
            value1.any(
                (map) => map.containsKey("index") && map["index"] == value));
      } else if (criteria == 'nin') {
        return value2?.every((value) =>
            !isNullOrEmpty(value) &&
            value1.every(
                (map) => map.containsKey("index") && map["index"] != value));
      }
    } else {
      return false;
    }
  }

  static handSingleDropDown(value1, value2, criteria) {
    if (criteria == 'or') {
      // for single dropdown
      return value2?.any((value) =>
          !isNullOrEmpty(value) && !isNullOrEmpty(value1) && value1 == value);
    }
  }

  static isLessThan(val, val1, comparisionType) {
    if (isNullOrEmpty(val ?? '') || isNullOrEmpty(val1 ?? '')) {
      return false;
    }
    if (comparisionType == 'int') {
      return int.parse(val) < int.parse(val1);
    } else {
      return val < val1;
    }
  }

  static isEqual(val, val1, comparisionType) {
    if (isNullOrEmpty(val) && isNullOrEmpty(val1)) {
      return comparisionType == 'int' ? -1 : false;
    }
    if (comparisionType == 'int') {
      return int.parse(val) == int.parse(val1);
    } else {
      return val == val1;
    }
  }

  static bool isNullOrEmpty(value) {
    return value == null || value == '';
  }

  static bool handleOr(_currentValue, conditions) {
    bool isValid = false;
    try {
      for (var eachOR in conditions) {
        if (!isNullOrEmpty(eachOR['conditionalCount']) &&
            eachOR['conditionalCount'] &&
            shouldIgnoreDates(_currentValue['iucReinserted'],
                _currentValue['totalNumberofDaysbetweenDOIRNandDOIR'])) {
          isValid = true;
          continue;
        }
        isValid = handleCriteria(
            _currentValue[eachOR?['key']] ?? '',
            (eachOR?['type'] == 'mutual'
                    ? _currentValue[eachOR?[eachOR?['key']]]
                    : eachOR?['selecteds'] ?? eachOR[eachOR?['key']]) ??
                '',
            eachOR?['comparisionType'] ?? '',
            eachOR?['criteria'] ?? '');
        if (isValid) {
          break;
        }
      }
    } catch (e) {
      print('error in or');
      print(e);
    }
    return isValid;
  }

  static bool shouldIgnoreNull(value1, value2) {
    return isNullOrEmpty(value1) || isNullOrEmpty(value2);
  }

  static bool shouldIgnoreDates(
      iucReinserted, totalNumberofDaysbetweenDOIRNandDOIR) {
    try {
      if (!isNullOrEmpty(iucReinserted)) {
        int? diff = int.tryParse(totalNumberofDaysbetweenDOIRNandDOIR);
        return diff! < 2;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static handleAndConditions(_currentValue, conditions, String returnType) {
    try {
      bool isValid = false;
      for (var eachOR in conditions) {
        if (!isNullOrEmpty(eachOR['ignore']) &&
            eachOR['ignore'] &&
            shouldIgnoreNull(_currentValue[eachOR['key']],
                _currentValue[eachOR?[eachOR?['key']]])) {
          isValid = true;
          continue;
        }
        if (!isNullOrEmpty(eachOR['or'])) {
          {
            isValid = handleOr(_currentValue, eachOR['or']);
          }
        } else {
          isValid = handleCriteria(
              _currentValue[eachOR?['key']] ?? '',
              (eachOR?['type'] == 'mutual'
                      ? _currentValue[eachOR?[eachOR?['key']]]
                      : eachOR?['selecteds'] ?? eachOR[eachOR?['key']]) ??
                  '',
              eachOR?['comparisionType'] ?? '',
              eachOR?['criteria'] ?? '');
        }
        if (!isValid) {
          break;
        }
      }
      return returnType == 'bool' ? isValid : (isValid ? 'Yes' : 'No');
    } catch (e) {
      // Handle the exception here
      print(e);
    }
  }
}
