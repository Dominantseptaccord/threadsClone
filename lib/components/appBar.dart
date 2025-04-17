import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

AppBar AppBarWall(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.black,
    centerTitle: true,
    title: Icon(Icons.account_box),
    actions: [
      IconButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/register');
          FirebaseAuth.instance.signOut();
        },
        icon: Icon(Icons.exit_to_app),
      )
    ],
  );
}