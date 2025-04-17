import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hatter/home.dart';
import 'package:hatter/screen/posts.dart';
import 'screen/auth_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screen/auth_reg.dart';
import 'screen/profile_page.dart';
import 'screen/auth_reg.dart';
import 'screen/auth_log.dart';
import 'screen/post_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: RegisterAuthentication(),
      routes: {
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterAuthentication(),
        '/login': (context) => LoginAuthentication(),
        '/posts': (context) => Post(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}