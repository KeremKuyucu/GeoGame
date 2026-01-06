import 'package:flutter/material.dart';

// 1. Modeller ve Servisler
import 'package:geogame/models/app_context.dart';

import 'package:geogame/widgets/custom_navbar.dart';

import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leaderboard/leaderboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<Widget> _sayfalar = [
     MainScreen(),    // Index 0: Oyunlar
     Leaderboard(),   // Index 1: Sıralama
     Profiles(),      // Index 2: Profil
     SettingsPage(),  // Index 3: Ayarlar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: AppState.selectedIndex,
        children: _sayfalar,
      ),

      bottomNavigationBar: CustomNavBar(
        currentIndex: AppState.selectedIndex,
        onTap: (index) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
          setState(() {
            AppState.selectedIndex = index;
          });
        },
      ),
    );
  }
}