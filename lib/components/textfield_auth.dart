import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget{
  final controller;
  final String hintText;
  const AuthTextField({super.key, required this.controller, required this.hintText});
  Widget build(BuildContext build){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hintText,
          ),
        )
    );
  }
}