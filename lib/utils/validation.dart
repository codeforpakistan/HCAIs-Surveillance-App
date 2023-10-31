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
        return value2?.any((value) =>
            !isNullOrEmpty(value) &&
            value1.any(
                (map) => map.containsKey("index") && map["index"] != value));
      }
    } else {
      return false;
    }
  }

  static isLessThan(val, val1, comparisionType) {
    if (isNullOrEmpty(val ?? '') && isNullOrEmpty(val1 ?? '')) {
      return comparisionType == 'int' ? -1 : false;
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

  static handleAndConditions(_currentValue, conditions, String returnType) {
    try {
      bool isValid = false;
      for (var eachOR in conditions) {
        isValid = handleCriteria(
            _currentValue[eachOR?['key']],
            (eachOR?['type'] == 'mutual'
                ? _currentValue[eachOR?[eachOR?['key']]]
                : eachOR?['selecteds'] ?? -1),
            eachOR?['comparisionType'] ?? '',
            eachOR?['criteria'] ?? '');
        if (!isValid) {
          break;
        }
      }
      return returnType == 'bool' ? isValid : (isValid ? 'Yes' : 'No');
    } catch (err) {
      print(err);
      return returnType == 'bool' ? false : '';
    }
  }
}
