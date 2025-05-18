import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hatter/screen/auth_log.dart';
import '../components/textfield_auth.dart';
import '../components/button_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hatter/help/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatter/models/userProfile.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class DatabaseService {
  Future<void> createUserInfo(UserCredential? userCredential,
      TextEditingController userNameController,
      TextEditingController passwordController) async {
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
      createUserInfo(regUserCredential, userNameController, passwordController);
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

  void registerUserAsGoogle({required BuildContext context}) async {
    showDialog(
        context: context,
        builder: (context) =>
        const Center(
          child: CircularProgressIndicator(),
        )
    );
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("Users").doc(
            userCredential.user!.email).set({
          "email": userCredential.user!.email,
          "username": userCredential.user!.displayName ?? "NoName",
          "authMethod": "google",
        });
      }
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginAuthentication()),
      );
    } catch (e) {
      Navigator.pop(context);
      helpDialog("Google Sign-In failed: ${e.toString()}", context);
    }
  }


  void registerUserAsFacebook({required BuildContext context}) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userCredential.user!.email)
              .set({
            "email": userCredential.user!.email,
            "username": userCredential.user!.displayName ?? "FacebookUser",
            "authMethod": "facebook",
          });
        }

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginAuthentication()),
        );
      } else {
        Navigator.pop(context);
        helpDialog("Facebook Sign-In cancelled or failed.", context);
      }
    } catch (e) {
      Navigator.pop(context);
      helpDialog("Facebook Sign-In failed: ${e.toString()}", context);
    }
  }

}