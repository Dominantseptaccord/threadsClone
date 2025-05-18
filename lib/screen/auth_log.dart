import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
  Future<void> loginWithGoogle() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
          "email": userCredential.user!.email,
          "username": userCredential.user!.displayName ?? "NoName",
          "authMethod": "google",
        });
      }

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      Navigator.pop(context);
      helpDialog("Google Sign-In failed: ${e.toString()}", context);
    }
  }

  Future<void> loginWithFacebook() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

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
          MaterialPageRoute(builder: (context) => HomePage()),
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
                const SizedBox(height: 10.0,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ElevatedButton.icon(
                        icon: Image.asset('assets/icons/google.png', width: 30),
                        label: Text('Google'),
                        onPressed: () async {
                          await loginWithGoogle();
                        },
                      ),
                    ),
                ElevatedButton.icon(
                  icon: Image.asset('assets/icons/facebook.png', width: 30),
                  label: Text('Facebook'),
                  onPressed: () async {
                    await loginWithFacebook();
                  },
                ),
                  ],
                ),
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