import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'package:geogame/app_routes.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';

import 'package:geogame/widgets/restart_widget.dart';

import 'package:geogame/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await PreferencesService.loadConfig();

  await Localization.init();

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
          title: 'GeoGame',
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
              seedColor: Colors.red,
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
