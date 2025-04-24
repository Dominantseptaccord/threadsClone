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
  final List<Map<String, String>> newsList = [
    {
      'title': '🔥 Latest Threads Clone Updates',
      'description': 'A new version of Threads Clone has been released with improved performance.'
    },
    {
      'title': '📱 Most Popular Apps of 2025',
      'description': 'Check out the top downloaded apps on Android and iOS.'
    },
    {
      'title': '🧠 AI in Daily Life',
      'description': 'How artificial intelligence helps us in everyday tasks.'
    },
    {
      'title': '🌐 Web & Mobile Integration',
      'description': 'Best practices for cross-platform development.'
    },
  ];
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
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title']!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      news['description']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      bottomNavigationBar: NavigationBottomBar()
    );
  }
}