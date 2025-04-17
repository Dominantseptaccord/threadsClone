import 'package:flutter/material.dart';

class ButtonAuthentication extends StatelessWidget{
  final String buttonText;
  final Function()? onTap;
  ButtonAuthentication({super.key, required this.buttonText, required this.onTap});

  Widget build(BuildContext build){
    return SafeArea(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(25.0),
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        )
    );
  }
}