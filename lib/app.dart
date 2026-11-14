import 'package:flutter/material.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';

import 'package:geogame/app_routes.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/splash_screen/splash_screen.dart';

/// GeoGame ana uygulama widget'ı (MaterialApp, Temalar ve Rotalar)
class Geogame extends StatelessWidget {
  const Geogame({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeBuilder(
      builder: (BuildContext context, ThemeMode themeMode) {
        return MaterialApp(
          scaffoldMessengerKey: AppState.scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'GeoGame',
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF6200EE),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF6200EE),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          onGenerateRoute: AppRoutes.generateRoute,
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ),
        );
      },
    );
  }
}
