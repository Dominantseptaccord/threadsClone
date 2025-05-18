import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hatter/home.dart';
import 'package:hatter/provider/theme_provider.dart';
import 'package:hatter/screen/post_filter_search.dart';
import 'package:hatter/screen/posts.dart';
import 'package:hatter/screen/auth_log.dart';
import 'package:hatter/screen/auth_reg.dart';
import 'package:hatter/screen/profile_page.dart';
import 'package:hatter/screen/createPostPage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/appTheme.dart';
import 'components/navbotbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: user == null ? LoginAuthentication() : MainScreen(),
          routes: {
            '/home': (context) => HomePage(),
            '/register': (context) => RegisterAuthentication(),
            '/login': (context) => LoginAuthentication(),
            '/posts': (context) => PostScreen(),
            '/profile': (context) => ProfilePage(),
            '/createPost': (context) => CreatePostPage(),
            '/search_posts': (context) => SearchScreen(),
          },
        );
      },
    );
  }
}
