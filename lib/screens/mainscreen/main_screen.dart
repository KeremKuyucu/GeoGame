import 'package:flutter/material.dart';

import 'package:geogame/widgets/mainscreen_widgets.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/auth_service.dart';

import 'package:geogame/screens/mainscreen/main_screen_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainScreenController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = MainScreenController(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoggedIn = AuthService.isAuthenticated;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFFFF2A6D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6200EE).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              Localization.t('GeoGame').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : const Color(0xFF2C2C3E),
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _controller.getBackgroundColors(isDark),
          ),
        ),
        child: Column(
          children: [
            if (!isLoggedIn) ...[
              SizedBox(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top),
              LoginWarningBanner(
                onLoginPressed: () async {
                  await Navigator.pushNamed(context, '/auth');
                  if (mounted) setState(() {});
                },
              ),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isGrid =
                      _controller.shouldUseGridLayout(constraints.maxWidth);
                  return isGrid
                      ? MainScreenGameGrid(
                          controller: _controller,
                          topPadding: isLoggedIn ? null : 10,
                        )
                      : MainScreenGameList(
                          controller: _controller,
                          topPadding: isLoggedIn ? null : 10,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
