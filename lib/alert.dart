import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String message) {

  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context, rootNavigator: true).pop(); },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}