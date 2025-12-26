import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modeller ve Servisler
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/update_checker_service.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';

// Sayfalar
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/auth/authpage.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
    await PreferencesService.loadConfig();
    await loadcountries();
    await AuthService.checkSession();
    await Localization.languageLoad();
    UpdateService.check(context);
    GameLogService.syncPendingLogs();
    if (mounted) {
      UpdateService.check(context);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
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
                  'assets/logo.png', // Dosya yolunun doğru olduğundan emin ol
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
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.data?.session;

        if (session != null) {
          return MainScreen();
        } else {
          AppState.selectedIndex = 4;
          return LoginPage(onLoginSuccess: () {});
        }
      },
    );
  }
}