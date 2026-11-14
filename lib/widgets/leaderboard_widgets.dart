import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/leaderboard/leaderboard_controller.dart';

/// Modern ve Canlı Şampiyonluk Podyumu Widget'ı (İlk 3 Sıra)
class LeaderboardPodium extends StatelessWidget {
  final LeaderboardController controller;

  const LeaderboardPodium({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E2E).withValues(alpha: 0.85),
                  const Color(0xFF12121C).withValues(alpha: 0.90),
                ]
              : [
                  Colors.white.withValues(alpha: 0.90),
                  const Color(0xFFF0F3F9).withValues(alpha: 0.95),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: isDark ? 0.08 : 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. sıranın arkasında altın ışıltı aurası
          Positioned(
            top: 10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: isDark ? 0.28 : 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2. Sıra (Gümüş - Sol)
              Expanded(
                child: LeaderboardPodiumItem(
                  controller: controller,
                  index: 1,
                  avatarRadius: 28,
                  pedestalHeight: 65,
                ),
              ),
              const SizedBox(width: 8),
              // 1. Sıra (Altın - Orta, En Yüksek)
              Expanded(
                child: LeaderboardPodiumItem(
                  controller: controller,
                  index: 0,
                  avatarRadius: 36,
                  pedestalHeight: 95,
                  isCenter: true,
                ),
              ),
              const SizedBox(width: 8),
              // 3. Sıra (Bronz - Sağ)
              Expanded(
                child: LeaderboardPodiumItem(
                  controller: controller,
                  index: 2,
                  avatarRadius: 26,
                  pedestalHeight: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Podyumdaki Tek Bir Oyuncu ve Basamak Sütunu
class LeaderboardPodiumItem extends StatelessWidget {
  final LeaderboardController controller;
  final int index;
  final double avatarRadius;
  final double pedestalHeight;
  final bool isCenter;

  const LeaderboardPodiumItem({
    super.key,
    required this.controller,
    required this.index,
    required this.avatarRadius,
    required this.pedestalHeight,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = controller.users[index];
    final color = controller.getRankColor(index);
    final gradientColors = controller.getRankGradient(index);
    final glowColor = controller.getRankGlowColor(index);
    final String avatarUrl = user['avatar_url']?.toString() ?? '';
    final String name = (user['name']?.toString().trim().isNotEmpty ?? false)
        ? user['name'].toString()
        : Localization.t('player');
    final bool hasAvatar = avatarUrl.trim().isNotEmpty;
    final int score = user['total_score'] is int
        ? user['total_score'] as int
        : (int.tryParse(user['total_score']?.toString() ?? '0') ?? 0);
    final bool isMe = controller.isCurrentUser(user);

    final IconData rankIcon = switch (index) {
      0 => Icons.emoji_events_rounded,
      1 => Icons.military_tech_rounded,
      2 => Icons.military_tech_rounded,
      _ => Icons.star_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.navigateToProfile(context, user),
        borderRadius: BorderRadius.circular(20),
        splashColor: glowColor.withValues(alpha: 0.25),
        highlightColor: glowColor.withValues(alpha: 0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Taç / Rozet İkonu
          Container(
            padding: EdgeInsets.all(isCenter ? 6 : 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: isCenter ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              rankIcon,
              size: isCenter ? 20 : 15,
              color: index == 1 ? Colors.blueGrey.shade800 : Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Avatar & Glow Çerçevesi
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: isCenter ? 16 : 8,
                      spreadRadius: isCenter ? 2 : 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: hasAvatar
                      ? ResizeImage(
                          NetworkImage(avatarUrl),
                          width: (avatarRadius * 3).toInt(),
                          height: (avatarRadius * 3).toInt(),
                        )
                      : null,
                  onBackgroundImageError: hasAvatar ? (_, __) {} : null,
                  backgroundColor: isDark
                      ? const Color(0xFF2C2C3E)
                      : Colors.white,
                  child: !hasAvatar
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: avatarRadius * 0.9,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        )
                      : null,
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6200EE), Color(0xFFFF2A6D)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      Localization.t('leaderboard.you').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // İsim
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isCenter ? FontWeight.w900 : FontWeight.bold,
                fontSize: isCenter ? 13 : 11,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),

          // Puan Hapı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: isCenter ? 13 : 11,
                  color: color,
                ),
                const SizedBox(width: 3),
                Text(
                  '$score P',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: isCenter ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Podyum Basamak Sütunu (3D Efektli & Şampiyonluk Numaralı)
          Container(
            height: pedestalHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        gradientColors.first.withValues(alpha: isCenter ? 0.40 : 0.25),
                        gradientColors.last.withValues(alpha: isCenter ? 0.15 : 0.08),
                      ]
                    : [
                        gradientColors.first.withValues(alpha: isCenter ? 0.70 : 0.50),
                        gradientColors.last.withValues(alpha: isCenter ? 0.35 : 0.20),
                      ],
              ),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.35 : 0.55),
                width: isCenter ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: isDark ? 0.2 : 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: isCenter ? 32 : 24,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white.withValues(alpha: isCenter ? 0.95 : 0.8)
                        : Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
}

/// Canlı ve Modern Kullanıcı Sıralama Kartı (4. sıra ve sonrası)
class LeaderboardUserCard extends StatelessWidget {
  final LeaderboardController controller;
  final int index;

  const LeaderboardUserCard({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = controller.users[index];
    final String avatarUrl = user['avatar_url']?.toString() ?? '';
    final String name = (user['name']?.toString().trim().isNotEmpty ?? false)
        ? user['name'].toString()
        : Localization.t('player');
    final bool hasAvatar = avatarUrl.trim().isNotEmpty;
    final int totalScore = user['total_score'] is int
        ? user['total_score'] as int
        : (int.tryParse(user['total_score']?.toString() ?? '0') ?? 0);
    final int rank = index + 1;
    final bool isMe = controller.isCurrentUser(user);
    final bool isTopTen = rank <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMe
              ? (isDark
                  ? const [
                      Color(0xFF2C194D),
                      Color(0xFF38153A),
                    ]
                  : const [
                      Color(0xFFF1E6FF),
                      Color(0xFFFFEBF2),
                    ])
              : (isDark
                  ? const [
                      Color(0xFF1E1E2C),
                      Color(0xFF151520),
                    ]
                  : const [
                      Colors.white,
                      Color(0xFFF7F9FC),
                    ]),
        ),
        border: Border.all(
          color: isMe
              ? const Color(0xFFBB86FC).withValues(alpha: 0.8)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : Colors.white.withValues(alpha: 0.7)),
          width: isMe ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? const Color(0xFF6200EE).withValues(alpha: isDark ? 0.35 : 0.20)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: isMe ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToProfile(context, user),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Sıra Rozeti (Top 10 için canlı mor/indigo gradyan)
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isTopTen
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                              const Color(0xFF651FFF).withValues(alpha: 0.40),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isTopTen
                        ? null
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04)),
                    border: isTopTen
                        ? Border.all(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.6),
                            width: 1.2,
                          )
                        : null,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isTopTen
                          ? const Color(0xFF9E7BFF)
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isMe
                          ? const Color(0xFFFF2A6D)
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: isMe ? 2 : 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: hasAvatar
                        ? ResizeImage(
                            NetworkImage(avatarUrl),
                            width: 80,
                            height: 80,
                          )
                        : null,
                    onBackgroundImageError:
                        hasAvatar ? (_, __) {} : null,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.18),
                    child: !hasAvatar
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // İsim & Alt Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6200EE), Color(0xFFFF2A6D)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                Localization.t('leaderboard.you').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$totalScore ${Localization.t('leaderboard.score')}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Detay Ok İkonu
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black45,
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

/// Canlı Boş Durum (Empty State) Widget'ı
class LeaderboardEmptyState extends StatelessWidget {
  const LeaderboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB300).withValues(alpha: 0.3),
                    const Color(0xFFFF2A6D).withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 50,
                color: Color(0xFFFFB300),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Localization.t('leaderboard.no_data'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canlı İnternet Bağlantısı Yok (Offline) Widget'ı
class LeaderboardOfflineView extends StatelessWidget {
  final Future<void> Function()? onRetry;

  const LeaderboardOfflineView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.pink.shade900.withValues(alpha: 0.6),
                          Colors.pink.shade700.withValues(alpha: 0.3),
                        ]
                      : [Colors.pink.shade100, Colors.pink.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.3),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 46,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Localization.t('leaderboard.offline_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              Localization.t('leaderboard.offline_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            if (onRetry != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(Localization.t('common.retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A6D),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFFFF2A6D).withValues(alpha: 0.45),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}
