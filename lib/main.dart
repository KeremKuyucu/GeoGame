import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/app.dart';
import 'package:geogame/config/supabase_config.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/telemetry_service.dart';
import 'package:geogame/widgets/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global hata dinleyicilerini kur
  TelemetryService.setupErrorHandling();

  // 2. Supabase istemcisini ve yerel ayarları paralel oku (İkisi birbirinden bağımsızdır)
  await Future.wait([
    Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    ),
    PreferencesService.loadConfig(),
  ]);

  // 3. Anında uygulamayı başlat (ThemeModeBuilder mount edilecek)
  runApp(
    const RestartWidget(
      child: Geogame(),
    ),
  );
}
