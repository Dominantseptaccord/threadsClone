import 'package:flutter/material.dart';
import 'package:hatter/screen/auth_log.dart';
import '../components/textfield_auth.dart';
import '../components/button_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hatter/help/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatter/models/userProfile.dart';
class DatabaseService {
  Future<void> createUserInfo(UserCredential? userCredential, TextEditingController userNameController, TextEditingController passwordController) async {
    if (userCredential != null && userCredential.user != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        "email": userCredential.user!.email,
        "username": userNameController.text,
        "password": passwordController.text,
      });
    }
  }

  void registerUser({required BuildContext context,
      required TextEditingController userNameController,
      required TextEditingController emailAddressController,
      required TextEditingController passwordController,
      required TextEditingController confirmPasswordController}) async {
    showDialog(
        context: context,
        builder: (context) =>
        const Center(
          child: CircularProgressIndicator(),
        )
    );
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      helpDialog('The password is not correct!', context);
      return;
    }
    try {
      UserCredential regUserCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailAddressController.text, password: passwordController.text
      );
      Navigator.pop(context);
      createUserInfo(regUserCredential,userNameController,passwordController);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              LoginAuthentication()
          )
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      helpDialog('The email address is not available!', context);
    }
  }
}