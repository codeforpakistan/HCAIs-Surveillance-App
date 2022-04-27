import 'package:flutter/material.dart';

class WidgetHelper {
  static Column buildColumn(String label) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label + ' *'), SizedBox(height: 4)]);
  }
}
