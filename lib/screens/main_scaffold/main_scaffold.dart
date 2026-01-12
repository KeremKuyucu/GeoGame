import 'package:flutter/material.dart';

import 'package:geogame/widgets/custom_navbar.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leaderboard/leaderboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings_screen.dart';

import 'main_scaffold_controller.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final MainScaffoldController _controller = MainScaffoldController();

  final List<Widget> _pages = const [
    MainScreen(),
    Leaderboard(),
    Profiles(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _controller.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _controller.currentIndex,
        onTap: (index) => _controller.onTabChanged(
          context,
          index,
          () => setState(() {}),
        ),
      ),
    );
  }
}
