  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:hatter/home.dart';
  import 'package:hatter/provider/theme_provider.dart';
  import 'package:hatter/screen/posts.dart';
  import 'screen/auth_log.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'firebase_options.dart';
  import 'screen/auth_reg.dart';
  import 'screen/profile_page.dart';
  import 'screen/auth_reg.dart';
  import 'screen/auth_log.dart';
  import 'screen/post_details.dart';
  import 'package:provider/provider.dart';
  import 'models/appTheme.dart';
  import 'screen/createPostPage.dart';
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
    ),
    );
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
    Widget build(BuildContext context) {
      final themeProvider = context.watch<ThemeProvider>();
      return MaterialApp(
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
        home: RegisterAuthentication(),
        routes: {
          '/home': (context) => HomePage(),
          '/register': (context) => RegisterAuthentication(),
          '/login': (context) => LoginAuthentication(),
          '/posts': (context) => Post(),
          '/profile': (context) => ProfilePage(),
          '/createPost': (context) => CreatePostPage(),
        },
      );
    }
  }