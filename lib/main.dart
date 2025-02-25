import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/pages/onboard_travel.dart';



void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAAqb54PkbP-L5atLFS0NRokMRgJL2MrQU',
      appId: '1:1015423722551:android:e3e3ba040120440579cbb2',
      messagingSenderId: '1015423722551',
      projectId: 'gobuddy-at1435',)
  )
  :await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Color(0xFFF2F5F1),
              fontFamily: 'Rubik',

            ),
            title: 'Go Buddy',
            home: TravelOnBoardingScreen()
        );

  }
}
