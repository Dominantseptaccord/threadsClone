import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatter/components/navbotbar.dart';

import '../components/appBar.dart';
class ProfilePage extends StatefulWidget{
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final controllerBio = TextEditingController();
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return await FirebaseFirestore
        .instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottomBar(),
      appBar: AppBarWall(context),
      body: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if (snapshot.hasError) {
              return Center(
                child: Text('What happen?'),
              );
            }
            else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child:
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/profile_default.jpg'),
                      ),
                    ),
                    Text(user!['username'], style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                        child: TextField(
                          controller: controllerBio,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Bio'
                          ),
                        )
                    )
                  ],
                ),
              );
            }
            else {
              return Text('No data');
            }
          }
      ),
    );
  }
}