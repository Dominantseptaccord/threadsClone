import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hatter/screen/auth_reg.dart';
import 'package:hatter/home.dart';
import '../components/textfield_auth.dart';
import '../components/button_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import 'package:hatter/help/helper.dart';
import 'package:hatter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatter/models/userProfile.dart';
class LoginAuthentication extends StatefulWidget{

  @override
  State<LoginAuthentication> createState() => _LoginAuthenticationState();
}

class _LoginAuthenticationState extends State<LoginAuthentication> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  void loginUser() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        )
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
      );

      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));

    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      helpDialog('The email or the password wrong!', context);
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
              children: [
                const SizedBox(height: 75,),
                Text('Login to your account'),
                const SizedBox(height: 25,),
                Image.asset('assets/logo.jpg'),
                const SizedBox(height: 25.0,),

                // username textfield
                AuthTextField(controller: emailController, hintText: 'Email Address'),
                const SizedBox(height: 10.0,),

                AuthTextField(controller: passwordController, hintText: 'Password'),
                const SizedBox(height: 10.0,),

                Text('Forgot Password?', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 25.0,),
                ButtonAuthentication(
                    buttonText: 'Login',
                    onTap: (){
                      loginUser();
                    }
                ),
                TextButton(
                  onPressed: (){
                    Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterAuthentication()
                      ),
                    );
                  },
                  child: Text('Does not have an Account?', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            ),
            ),
        ),
      ),
    );
  }
}