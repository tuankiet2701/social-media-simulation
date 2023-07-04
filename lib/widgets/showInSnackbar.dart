import 'package:flutter/material.dart';

void showInSnackBar(String value, context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
}
