import 'package:flutter/material.dart';


class CustomAlerts{

  void showSnackBar(String message, BuildContext context, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success?Colors.blue:Theme.of(context).errorColor,
    ));
  }




}