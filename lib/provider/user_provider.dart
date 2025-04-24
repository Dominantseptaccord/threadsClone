import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier{
  String userName = FirebaseAuth.instance.currentUser.toString();
  Future<void> fetchData(String uid)async {

  }
}