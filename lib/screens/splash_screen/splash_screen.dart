import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Modeller ve Servisler
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/game_log_service.dart';

import 'package:geogame/screens/main_scaffold/main_scaffold.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    // 1. Veri yükleme ve Oturum kontrolleri (Context gerektirmez)
    await loadCountries();
    AppState.activePool = AppState.filteredCountries;
    await AuthService.checkSession();

    // ama arkaplanda çalışması UI'ı bloklamaz, bu hali de uygundur)
    GameLogService.syncPendingLogs();

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppState.version = packageInfo.version;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Köşeleri yumuşatır
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png', // Dosya yolunun doğru olduğundan emin ol
                  width: 150,        // Logonun genişliği
                  height: 150,       // Logonun yüksekliği
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "GeoGame",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2
              ),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ... AuthGate sınıfı aynı kalabilir ...
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const MainScaffold();
      },
    );
  }
}