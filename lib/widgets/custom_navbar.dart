// lib/widgets/custom_navbar.dart

import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:geogame/services/localization_service.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xff6200ee),
      unselectedItemColor: const Color(0xff757575),
      onTap: onTap, // Tıklama olayını üst katmana (AnaIskelet) bildirir

      // Items listesini burada oluşturuyoruz (Her build'de dil güncellenir)
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: Text(Localization.t('nav.games')),
          selectedColor: const Color(0xff6200ee),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.leaderboard),
          title: Text(Localization.t('nav.rank')),
          selectedColor: Colors.pink,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person),
          title: Text(Localization.t('nav.profile')),
          selectedColor: Colors.teal,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: Text(Localization.t('nav.settings')),
          selectedColor: Colors.orange,
        ),
      ],
    );
  }
}