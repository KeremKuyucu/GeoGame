import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_ui_service.dart';

class AuthController {
  // State
  bool isGoogleLoading = false;

  // Colors
  static const Color primaryColor = Color(0xFF4A00E0);
  static const Color secondaryColor = Color(0xFF8E2DE2);

  Future<AuthResult> handleGoogleLogin() async {
    return await AuthUIService.performGoogleSignIn();
  }

  void navigateToHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      AppState.selectedIndex = 0;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (color == Colors.redAccent)
              const Icon(Icons.error_outline, color: Colors.white),
            if (color == Colors.greenAccent)
              const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
