import 'package:flutter/material.dart';
import 'package:GeoGame/screens/mainscreen/geogamelobi.dart';
import "package:theme_mode_builder/theme_mode_builder.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  disableCertificateVerification();
  runApp(Geogame());
}

class Geogame extends StatefulWidget {
  @override
  State<Geogame> createState() => GeoGame();
}
class GeoGame extends State<Geogame> {
  @override
  Widget build(BuildContext context) {
    return ThemeModeBuilder(
      builder: (BuildContext context, ThemeMode themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "GeoGame",
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: Colors.red,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: Colors.deepPurple,
            ),
          ),
          home: GeoGameLobi(),
        );
      },
    );
  }
}


/*
flutter pub run flutter_launcher_icons:main
flutter build apk

adb install build\app\outputs\flutter-apk\app-release.apk

flutter build apk
xcopy /Y /I "build\app\outputs\apk\release\app-release.apk" "C:\Users\KeremK\Desktop\app-release.apk"
flutter build windows
xcopy /E /I "build\windows\x64\runner\Release" "C:\Users\KeremK\Desktop\Release"

 */