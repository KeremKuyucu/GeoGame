import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://brgwnlbgasameiuuoxte.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJyZ3dubGJnYXNhbWVpdXVveHRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNzE3NDEsImV4cCI6MjA4MTc0Nzc0MX0.G3vFjkWthJZ7h7N_K3yNPrr_ney9pSXdTko4cYdwR0k',
  );

  Locale deviceLocale = PlatformDispatcher.instance.locale;
  diltercihi = deviceLocale.languageCode;

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

flutter build apk --release --split-per-abi
flutter build windows
*/