import 'package:flutter/material.dart';

import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:geogame/screens/games/borderline/borderline_screen.dart';
import 'package:geogame/screens/games/borderpath/borderpath_screen.dart';
import 'package:geogame/screens/games/capital/capital_screen.dart';
import 'package:geogame/screens/games/distance/distance_screen.dart';
import 'package:geogame/screens/games/flag/flag_screen.dart';
import 'package:geogame/screens/games/findmap/findmap_screen.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leaderboard/leaderboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings_screen.dart';
import 'package:geogame/screens/auth/auth_screen.dart';
import 'package:geogame/screens/edit_profile/edit_profile.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // Başlangıç ekranı
    '/': (context) => const SplashScreen(),

    '/home': (context) => const MainScaffold(),

    '/game/capital': (context) => const CapitalGame(),
    '/game/flag': (context) => const FlagGame(),
    '/game/distance': (context) => const DistanceGame(),
    '/game/borderline': (context) => const BorderLineGame(),
    '/game/borderpath': (context) => const BorderPathGame(),
    '/game/findmap': (context) => const FindMapGame(),

    '/games': (context) => const MainScreen(),
    '/leaderboard': (context) => const Leaderboard(),
    '/profile': (context) => const Profiles(),
    '/settings': (context) => const SettingsPage(),

    '/auth': (context) => const AuthPage(),
    '/profile/edit': (context) => const EditProfilePage(),
  };
}
