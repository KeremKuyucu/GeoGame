import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/leaderboard/leaderboard_controller.dart';

/// Podium widget'ı
class LeaderboardPodium extends StatelessWidget {
  final LeaderboardController controller;

  const LeaderboardPodium({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: LeaderboardPodiumItem(
                controller: controller, index: 1, height: 100),
          ),
          Expanded(
            child: LeaderboardPodiumItem(
                controller: controller, index: 0, height: 130),
          ),
          Expanded(
            child: LeaderboardPodiumItem(
                controller: controller, index: 2, height: 90),
          ),
        ],
      ),
    );
  }
}

/// Podium item widget'ı
class LeaderboardPodiumItem extends StatelessWidget {
  final LeaderboardController controller;
  final int index;
  final double height;

  const LeaderboardPodiumItem({
    super.key,
    required this.controller,
    required this.index,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.users[index];
    final color = controller.getRankColor(index);

    return GestureDetector(
      onTap: () => controller.navigateToProfile(context, user),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: height / 2.5,
                  backgroundImage: NetworkImage(user['avatar_url']),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: controller.getRankTextColor(index),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              user['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            '${user['total_score']} P',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// User card widget'ı
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
    final user = controller.users[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => controller.navigateToProfile(context, user),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
              CircleAvatar(backgroundImage: NetworkImage(user['avatar_url'])),
            ],
          ),
          title: Text(user['name'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${user['total_score']} ${Localization.t('leaderboard.score')}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

/// Empty state widget'ı
class LeaderboardEmptyState extends StatelessWidget {
  const LeaderboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_rounded, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            Localization.t('leaderboard.no_data'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// İnternet bağlantısı olmadığında gösterilen Leaderboard çevrimdışı görünümü
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
              width: 90,
              height: 90,
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
                    color: Colors.pink.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Localization.t('leaderboard.offline_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
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
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.pink.withValues(alpha: 0.4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

