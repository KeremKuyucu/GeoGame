import 'package:flutter/material.dart';

import 'package:geogame/widgets/custom_navbar.dart';
import 'package:geogame/app_routes.dart';

import 'main_scaffold_controller.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final MainScaffoldController _controller = MainScaffoldController();

  final List<String> _pageKeys = const [
    '/games',
    '/leaderboard',
    '/profile',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _controller.currentIndex,
        children:
            _pageKeys.map((key) => AppRoutes.routes[key]!(context)).toList(),
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
