import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hatter/provider/theme_provider.dart';
import 'package:provider/provider.dart';
AppBar AppBarWall(BuildContext context) {
  final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
  return AppBar(
    backgroundColor: isDark ? Colors.black : Colors.white,
    centerTitle: true,
    title: Icon(Icons.account_box),
    actions: [
      IconButton(
          onPressed: (){
            Provider.of<ThemeProvider>(context,listen: false).toggleTheme();
          },
          icon: Icon(Icons.shield_moon)
      ),
      IconButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/register');
          FirebaseAuth.instance.signOut();
        },
        icon: Icon(Icons.exit_to_app),
      ),
    ],
  );
}