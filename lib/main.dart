import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';

// Kendi proje dosyaların
import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/widgets/restart_widget.dart';
import 'env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// 1. Supabase Başlat
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await PreferencesService.loadConfig();

  Locale deviceLocale = PlatformDispatcher.instance.locale;
  await Localization.init(
      deviceLocale: deviceLocale.languageCode,
      userPref: AppState.settings.language
  );

  // 4. Uygulamayı Başlat
  runApp(
    const RestartWidget(
      child: Geogame(),
    ),
  );
}

class Geogame extends StatefulWidget {
  const Geogame({super.key});

  @override
  State<Geogame> createState() => _GeogameState();
}

class _GeogameState extends State<Geogame> {
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
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
/*
Notlar:
Build Komutları:
flutter pub run flutter_launcher_icons:main

flutter build web
flutter build apk --release --split-per-abi
flutter build windows

*/