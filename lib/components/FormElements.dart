// ignore_for_file: unused_element

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hcais/utils/WidgetHelper.dart';
import 'package:hcais/utils/helper.dart';

class FormElements {
  Timer? _debounce;
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
    // if (myController.text == '' && this._values[key] != null) {
    //   myController.text = this._values[key];
    // }
    Column childs =
        WidgetHelper.buildColumn(labelText.toString(), isRequired, null);
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
                      // _showDialog(context, "Information", helpLabelText, false);
                    },
                  )
                : null),
        controller: myController,
        readOnly: readOnly,
        onChanged: (newValue) => {
              if (_debounce?.isActive ?? false) _debounce?.cancel(),
              _debounce = Timer(const Duration(milliseconds: 500), () {
                // do something with query
                // this._values[key] = newValue;
                // _setCompleteField(key, this._values[key] ?? '', [], []);
              }),
            }));
    return childs;
  }
}
