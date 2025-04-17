import 'package:flutter/material.dart';

void helpDialog(String help, BuildContext context){
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(help),
      backgroundColor: Colors.red,
    )
  );
}