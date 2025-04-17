import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hatter/screen/auth_log.dart';
import 'package:hatter/screen/auth_reg.dart';
import 'package:hatter/screen/posts.dart';
import 'package:hatter/screen/profile_page.dart';import 'main.dart';
import 'components/navbotbar.dart';
import 'components/appBar.dart';
class HomePage extends StatefulWidget{

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final screens = [
    HomePage(),
    RegisterAuthentication(),
    LoginAuthentication(),
  ];
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool _didNavigate = false;
  Future<DocumentSnapshot<Map<String,dynamic>>> getUserData() async{
    return await FirebaseFirestore
        .instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWall(context),
      body: Center(
        child: Text('Tew'),
      ),
      bottomNavigationBar: NavigationBottomBar()
    );
  }
}