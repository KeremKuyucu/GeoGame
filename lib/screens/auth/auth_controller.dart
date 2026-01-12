import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_ui_service.dart';
import 'package:geogame/services/localization_service.dart';

class AuthController {
  // State
  bool isLoading = false;
  bool isLoginMode = true;
  bool obscurePassword = true;

  // Colors
  static const Color primaryColor = Color(0xFF4A00E0);
  static const Color secondaryColor = Color(0xFF8E2DE2);

  Future<AuthResult> handleLogin(String email, String password) async {
    return await AuthUIService.performLogin(email.trim(), password.trim());
  }

  Future<AuthResult> handleRegister({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
  }) async {
    return await AuthUIService.performRegister(
      email: email.trim(),
      password: password.trim(),
      name: name.trim(),
      confirmPassword: confirmPassword.trim(),
    );
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    return await AuthUIService.sendPasswordReset(email.trim());
  }

  void navigateToHome(BuildContext context) {
    AppState.selectedIndex = 0;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void toggleMode() {
    isLoginMode = !isLoginMode;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  void unfocusAndFinishAutofill(BuildContext context) {
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext(shouldSave: true);
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
              child: Text(message,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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

  String getSubtitle() {
    return isLoginMode
        ? Localization.t('auth.login_subtitle')
        : Localization.t('auth.register_subtitle');
  }

  String getCardTitle() {
    return isLoginMode
        ? Localization.t('auth.login')
        : Localization.t('auth.signup');
  }

  String getSubmitButtonText() {
    return (isLoginMode
            ? Localization.t('auth.login')
            : Localization.t('auth.register'))
        .toUpperCase();
  }

  String getModeToggleText() {
    return isLoginMode
        ? Localization.t('auth.no_account')
        : Localization.t('auth.have_account');
  }

  String getModeToggleButtonText() {
    return isLoginMode
        ? Localization.t('auth.signup')
        : Localization.t('auth.login');
  }
}
