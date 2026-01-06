import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';

// Kendi proje dosyaların
import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:geogame/screens/games/borderline/borderline_screen.dart';
import 'package:geogame/screens/games/borderpath/borderpath_screen.dart';
import 'package:geogame/screens/games/capital/capital_screen.dart';
import 'package:geogame/screens/games/distance/distance_screen.dart';
import 'package:geogame/screens/games/flag/flag_screen.dart';
import 'package:geogame/screens/leaderboard/leaderboard.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings.dart';
import 'package:geogame/screens/auth/auth_page.dart';
import 'package:geogame/screens/edit_profile/edit_profile.dart';

import 'package:geogame/models/app_context.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';

import 'package:geogame/widgets/restart_widget.dart';

import 'env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await PreferencesService.loadConfig();

  Locale deviceLocale = PlatformDispatcher.instance.locale;
  await Localization.init(
      deviceLocale: deviceLocale.languageCode,
      userPref: AppState.settings.language
  );

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
          initialRoute: '/',

          routes: {
            // Başlangıç ekranı
            '/': (context) => const SplashScreen(),

            '/home': (context) => const MainScaffold(),

            '/game/capital': (context) => const CapitalGame(),
            '/game/flag': (context) => const FlagGame(),
            '/game/distance': (context) => const DistanceGame(),
            '/game/borderline': (context) => const BorderLineGame(),
            '/game/borderpath': (context) => const BorderPathGame(),

            '/leaderboard': (context) => const Leaderboard(),
            '/profile': (context) => const Profiles(),
            '/settings': (context) => const SettingsPage(),

            '/auth': (context) => const AuthPage(),
            '/profile/edit': (context) => const EditProfilePage(),
          },
        );
      },
    );
  }
}