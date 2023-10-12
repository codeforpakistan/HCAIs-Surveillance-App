import 'dart:convert';

import 'package:hcais/utils/constants.dart';
import 'package:http/http.dart' as http;

class Service {
  Future<String> createDraft(Map values) async {
    try {
      var url = Constants.BASE_URL + '/draft';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(values),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        print(result);
        return result!['_id'] ?? '';
      } else {
        return '';
      }
    } catch (err) {
      print(err);
      return '';
    }
  }

  updateDraft(Map values, String id) async {
    try {
      var url = Constants.BASE_URL + '/draft/' + id;
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(values),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
      } else {}
    } catch (err) {}
  }

  deleteDraft(String id) async {
    try {
      if (id == '') return;
      var url = Constants.BASE_URL + '/draft/' + id;
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
      } else {}
    } catch (err) {}
  }
}
