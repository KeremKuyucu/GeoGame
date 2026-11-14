import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/app.dart';
import 'package:geogame/config/supabase_config.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/telemetry_service.dart';
import 'package:geogame/widgets/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TelemetryService.setupErrorHandling();

  await Future.wait([
    Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    ),
    PreferencesService.loadConfig(),
  ]);

  await SettingsController.applyTheme();

  runApp(
    const RestartWidget(
      child: Geogame(),
    ),
  );
}
