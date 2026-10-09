import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/screens/profiles/profiles_controller.dart';

/// Gezgin (oturum açmamış) profil görünümü
class ProfilesGuestView extends StatelessWidget {
  final ProfilesController controller;

  const ProfilesGuestView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const DrawerWidget(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gezgin İkonu / Rozeti
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 64,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  Localization.t('settings.guest'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.teal.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Localization.t('auth.warning_no_account'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Cihazda Biriken Yerel Puan Kartı
                FutureBuilder<int>(
                  future: GameLogService.getPendingScore(),
                  builder: (context, snapshot) {
                    final int pendingScore = snapshot.data ?? 0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.teal.shade900.withValues(alpha: 0.25)
                            : Colors.teal.shade50.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.teal.withValues(alpha: isDark ? 0.35 : 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.military_tech_rounded,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pendingScore > 0
                                      ? '$pendingScore ${Localization.t('leaderboard.score')}'
                                      : '0 ${Localization.t('leaderboard.score')}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pendingScore > 0
                                      ? 'Cihazınızda biriken puanlar hesabınıza aktarılmaya hazır.'
                                      : 'Oynadıkça puanlarınız cihazınızda birikir ve hesap açtığınızda aktarılır.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Giriş / Hesap Aç Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      Localization.t('auth.login'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () => controller.navigateToAuth(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
