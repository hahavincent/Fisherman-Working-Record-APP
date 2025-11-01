import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/Login_Page.dart';
import 'package:flutter_project/Captain_Home.dart';
import 'package:flutter_project/time.dart';
import 'package:flutter_project/fisherHome.dart';
import 'package:flutter_project/PersonnelManagement.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project/firebase_options.dart';
import 'package:flutter_project/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ensure services are registered after binding is initialized
  setupServices();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //讓debug那條不顯示
      title: 'fishermen\'s service management',
      theme: ThemeData(
          fontFamily: 'GenJyuu',
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.windows: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
            TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
            TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
          })), //字體
      routes: {
        '/': (context) => const HomePage(), //首頁
        '/Captain_Home': (context) => const Captain_Home(),
        '/time': (context) => const Timeout(),
        '/Management': (context) => const Management(),
        '/FisherHome': (context) => const FisherHome(),
      },
    );
  }
}
