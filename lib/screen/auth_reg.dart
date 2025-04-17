import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hatter/screen/auth_log.dart';
import '../components/textfield_auth.dart';
import '../components/button_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hatter/help/helper.dart';
import 'package:hatter/database/database_service.dart';
class RegisterAuthentication extends StatefulWidget{
  @override
  State<RegisterAuthentication> createState() => _RegisterAuthenticationState();
}

class _RegisterAuthenticationState extends State<RegisterAuthentication> {
  final userNameController = TextEditingController();

  final emailAddressController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final db = DatabaseService();

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
                AuthTextField(controller: userNameController, hintText: 'Username'),
                const SizedBox(height: 10.0,),

                AuthTextField(controller: emailAddressController, hintText: 'Email Address'),
                const SizedBox(height: 10.0,),

                AuthTextField(controller: passwordController, hintText: 'Password'),
                const SizedBox(height: 10.0,),

                AuthTextField(controller: confirmPasswordController, hintText: 'Confirm Password'),
                const SizedBox(height: 10.0,),
                TextButton(
                  onPressed: (){
                    Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginAuthentication()
                      ),
                    );
                  },
                  child: Text('Have an Account?'),
                ),
                const SizedBox(height: 25.0,),
                ButtonAuthentication(
                    buttonText: 'Register',
                    onTap: (){
                      db.registerUser(
                          context: context,
                          userNameController: userNameController,
                          emailAddressController: emailAddressController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController
                      );
                    }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}