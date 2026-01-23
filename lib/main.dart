import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:geogame/app_routes.dart';
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
      userPref: AppState.settings.language);

  runApp(
    const RestartWidget(
      child: Geogame(),
    ),
  );
}

class Geogame extends StatelessWidget {
  const Geogame({super.key});

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
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
