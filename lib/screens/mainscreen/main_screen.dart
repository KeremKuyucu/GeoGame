import 'package:flutter/material.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/mainscreen_widgets.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/auth_service.dart';

import 'main_screen_controller.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = MainScreenController(context);
      _controller.checkForUpdates();
    });
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
        title: Text(
          Localization.t('GeoGame').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xff6200ee),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
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
                  setState(() {});
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
          ],
        ),
      ),
    );
  }
}
