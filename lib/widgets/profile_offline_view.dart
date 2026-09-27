import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';

/// Profil ekranı için çevrimdışı (internet yok) durumu widget'ı
class ProfileOfflineView extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final Future<void> Function()? onRetry;

  const ProfileOfflineView({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName =
        name.trim().isNotEmpty ? name : Localization.t('settings.guest');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Kullanıcı Başlık Kartı (Önbellekteki kullanıcı bilgisi)
          _buildUserCard(context, displayName, isDark),
          const SizedBox(height: 18),

          // 2. İnternet Yok Uyarısı
          _buildOfflineNoticeCard(isDark),
          const SizedBox(height: 18),

          // 3. Puanlarınız Güvende & Otomatik Senkronizasyon Kartı
          _buildScoresSafeCard(isDark),
          const SizedBox(height: 24),

          // 4. Tekrar Dene Butonu
          if (onRetry != null)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(Localization.t('common.retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.teal.withValues(alpha: 0.4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onRetry,
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Kullanıcının mevcut/önbellekteki adını ve avatarını gösteren kart
  Widget _buildUserCard(
      BuildContext context, String displayName, bool isDark) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [Colors.teal.shade800, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2.5),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white24,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                onBackgroundImageError: avatarUrl.isNotEmpty
                    ? (_, __) {
                        debugPrint('Offline avatar load fallback');
                      }
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 36, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amberAccent.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 13,
                          color: Colors.amberAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Çevrimdışı',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İnternet bağlantısı yok uyarısı kartı
  Widget _buildOfflineNoticeCard(bool isDark) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.amber.shade900.withValues(alpha: 0.5),
                          Colors.amber.shade700.withValues(alpha: 0.2),
                        ]
                      : [Colors.amber.shade100, Colors.amber.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Localization.t('profile.offline_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Localization.t('profile.offline_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Puanlarınız Güvende!" ve senkronizasyon bilgilendirme kartı
  Widget _buildScoresSafeCard(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.teal.withValues(alpha: isDark ? 0.35 : 0.5),
          width: 1.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.teal.shade900.withValues(alpha: 0.3),
                    const Color(0xFF0F2B26),
                  ]
                : [
                    Colors.teal.shade50.withValues(alpha: 0.8),
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.teal,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    Localization.t('profile.offline_scores_safe_title'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.tealAccent : Colors.teal.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Localization.t('profile.offline_scores_safe_desc'),
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.tealAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Yerel yedekleme aktif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.tealAccent.shade100 : Colors.teal.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
