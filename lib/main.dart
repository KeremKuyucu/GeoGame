import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/models/app_context.dart';
import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';

import 'env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  Locale deviceLocale = PlatformDispatcher.instance.locale;
  AppState.settings.languagePref = deviceLocale.languageCode;

  runApp(Geogame());
}

class Geogame extends StatefulWidget {
  @override
  State<Geogame> createState() => GeoGame();
}

class GeoGame extends State<Geogame> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeBuilder(
      builder: (BuildContext context, ThemeMode themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "GeoGame",
          themeMode: AppState.settings.darkTheme ? ThemeMode.dark : ThemeMode.light,
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
          home: const SplashScreen(),
        );
      },
    );
  }
}

/*
flutter pub run flutter_launcher_icons:main

flutter build apk --release --split-per-abi
flutter build windows
*/