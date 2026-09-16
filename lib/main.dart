import 'package:flutter/foundation.dart';
import 'package:theme_mode_builder/theme_mode_builder/theme_mode_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'package:geogame/app_routes.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/telemetry_service.dart';
import 'package:geogame/services/ad_service.dart';

import 'package:geogame/screens/splash_screen/splash_screen.dart';
import 'package:geogame/widgets/restart_widget.dart';
import 'package:geogame/models/app_context.dart';

import 'package:geogame/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global hata yakalama (Flutter UI & Framework hataları)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    TelemetryService.sendError(
      event: 'flutter_uncaught_error',
      message: details.exceptionAsString(),
      stackTrace: details.stack,
      metadata: {
        'library': details.library,
        if (details.context != null) 'context': details.context.toString(),
      },
    );
  };

  // Asenkron ve platform seviyesi yakalanmamış hatalar
  PlatformDispatcher.instance.onError = (error, stack) {
    TelemetryService.sendError(
      event: 'platform_uncaught_error',
      message: error.toString(),
      stackTrace: stack,
    );
    return false;
  };

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await PreferencesService.loadConfig();
  await Localization.init();
  TelemetryService.init();
  AdService.initialize();
  AuthService.initAuthStateListener();

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
          scaffoldMessengerKey: AppState.scaffoldMessengerKey,
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
          onGenerateRoute: (settings) {
            if (settings.name != null &&
                (settings.name!.contains('login-callback') ||
                    settings.name!.startsWith('com.keremkuyucu.geogame'))) {
              if (AppState.allCountries.isEmpty) {
                return MaterialPageRoute(
                    builder: (context) => const SplashScreen());
              }
              return PageRouteBuilder(
                pageBuilder: (context, _, __) => const SizedBox.shrink(),
                transitionDuration: Duration.zero,
              );
            }
            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          },
        );
      },
    );
  }
}
