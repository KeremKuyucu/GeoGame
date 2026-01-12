import 'package:flutter/material.dart';

import 'package:geogame/widgets/splash_screen_widgets.dart';

import 'splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenController _controller = SplashScreenController();

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (mounted) {
        _controller.navigateToHome(context, const AuthGate());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreenBody();
  }
}
