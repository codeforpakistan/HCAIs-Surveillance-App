import 'package:flutter/material.dart';

class Arguments {
  static const title = 'HCAI Surveillance App';
  final String userId;
  final String hospitalId;
  final String hcaiId;
  final String hcaiTitle;
  final bool goodToGo;
  final Map values;
  final bool reviewed;

  // This Widget accepts the arguments as constructor
  // parameters. It does not extract the arguments from
  // the ModalRoute.
  //
  // The arguments are extracted by the onGenerateRoute
  // function provided to the MaterialApp widget.
  const Arguments(
      {Key? key,
      title,
      required this.goodToGo,
      required this.userId,
      required this.hospitalId,
      required this.hcaiId,
      required this.hcaiTitle,
      required this.values,
      required this.reviewed});
}
