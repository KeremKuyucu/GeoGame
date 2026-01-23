import 'package:flutter/material.dart';

import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/widgets/game_card.dart';
import 'package:geogame/screens/mainscreen/main_screen_controller.dart';
import 'package:geogame/services/localization_service.dart';

/// Grid görünümü widget'ı
class MainScreenGameGrid extends StatelessWidget {
  final MainScreenController controller;
  final double? topPadding;

  const MainScreenGameGrid({
    super.key,
    required this.controller,
    this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20, topPadding ?? 100, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: gameMetadataList.length,
      itemBuilder: (context, index) => GameCard(
        metadata: gameMetadataList[index],
        isGrid: true,
        onTap: () => controller.startGame(gameMetadataList[index]),
      ),
    );
  }
}

/// Giriş yapmamış kullanıcılar için uyarı banner'ı
class LoginWarningBanner extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const LoginWarningBanner({
    super.key,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black45 : Colors.white70,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade300.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Localization.t('auth.warning_no_account'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff6200ee),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onLoginPressed,
            child: Text(
              Localization.t('auth.login'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
