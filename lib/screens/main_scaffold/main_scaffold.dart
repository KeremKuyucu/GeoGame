import 'package:flutter/material.dart';

import 'package:geogame/widgets/custom_navbar.dart';
import 'package:geogame/app_routes.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold_controller.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final MainScaffoldController _controller = MainScaffoldController();

  List<String> get _pageKeys => [
        '/games',
        '/leaderboard',
        '/profile',
        '/settings',
      ];

  @override
  void initState() {
    super.initState();
    AppState.userNotifier.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    AppState.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int safeIndex = _controller.currentIndex < _pageKeys.length
        ? _controller.currentIndex
        : 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: safeIndex,
        children:
            _pageKeys.map((key) => AppRoutes.routes[key]!(context)).toList(),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: safeIndex,
        onTap: (index) => _controller.onTabChanged(
          context,
          index,
          () => setState(() {}),
        ),
      ),
    );
  }
}
