import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:geogame/screens/games/borderline/borderline_screen.dart';
import 'package:geogame/screens/games/borderpath/borderpath_screen.dart';
import 'package:geogame/screens/games/capital/capital_screen.dart';
import 'package:geogame/screens/games/distance/distance_screen.dart';
import 'package:geogame/screens/games/flag/flag_screen.dart';
import 'package:geogame/screens/games/findmap/findmap_screen.dart';
import 'package:geogame/screens/games/coat_of_arms/coat_of_arms_screen.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leaderboard/leaderboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings_screen.dart';
import 'package:geogame/screens/auth/auth_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/home': (context) => const MainScaffold(),

    '/game/capital': (context) => const CapitalGame(),
    '/game/flag': (context) => const FlagGame(),
    '/game/distance': (context) => const DistanceGame(),
    '/game/borderline': (context) => const BorderLineGame(),
    '/game/borderpath': (context) => const BorderPathGame(),
    '/game/findmap': (context) => const FindMapGame(),
    '/game/coatofarms': (context) => const CoatOfArmsGame(),

    '/games': (context) => const MainScreen(),
    '/leaderboard': (context) => const Leaderboard(),
    '/profile': (context) => const Profiles(),
    '/settings': (context) => const SettingsPage(),

    '/auth': (context) => const AuthPage(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    // '/' → Her zaman normal SplashScreen
    if (name == '/') {
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    }

    // Login callback (OAuth deep link)
    final isLoginCallback = name.contains('login-callback') ||
        name.startsWith('com.keremkuyucu.geogame');

    if (isLoginCallback) {
      if (AppState.allCountries.isEmpty) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      }
      return PageRouteBuilder(
        pageBuilder: (context, _, __) => const SizedBox.shrink(),
        transitionDuration: Duration.zero,
      );
    }

    // Uygulama henüz başlatılmamışsa → Splash önce, sonra hedefe git
    if (AppState.allCountries.isEmpty) {
      return MaterialPageRoute(
        builder: (context) => SplashScreen(
          onInitialized: () {
            Navigator.of(context).pushReplacementNamed(name);
          },
        ),
      );
    }

    // Uygulama hazır → doğrudan aç
    final builder = routes[name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder);
    }

    return null;
  }
}
