import 'package:flutter/material.dart';
import 'package:GeoGame/screens/geogamelobi.dart';

void main() {
  runApp(Geogame());
}

class Geogame extends StatefulWidget {
  @override
  State<Geogame> createState() => _QuizAppState();
}

class _QuizAppState extends State<Geogame> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      home: GeoGameLobi(),
    );
  }
}


/*
flutter pub run flutter_launcher_icons:main
flutter build apk
adb install C:\Users\KeremK\StudioProjects\geogame\build\app\outputs\flutter-apk\app-release.apk

 */