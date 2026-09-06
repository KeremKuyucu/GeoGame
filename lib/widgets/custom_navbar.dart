// lib/widgets/custom_navbar.dart

import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

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
    final bool isChildMode = SettingsController.isChildMode;

    return SalomonBottomBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xff6200ee),
      unselectedItemColor: const Color(0xff757575),
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: Text(Localization.t('nav.games')),
          selectedColor: const Color(0xff6200ee),
        ),
        if (!isChildMode)
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