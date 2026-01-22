import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/auth/auth_controller.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
    );
  }
}

class AuthDecorativeCircles extends StatelessWidget {
  const AuthDecorativeCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AuthController.primaryColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AuthController.secondaryColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Image.asset(
          'assets/images/logo.webp',
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class AuthTitle extends StatelessWidget {
  final String subtitle;

  const AuthTitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'GEOGAME',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
            shadows: [
              Shadow(
                  blurRadius: 10, color: Colors.black45, offset: Offset(0, 2))
            ],
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  final List<Widget> children;

  const AuthGlassCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class AuthGlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final bool obscurePassword;
  final List<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final VoidCallback? onTogglePassword;

  const AuthGlassTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.obscurePassword = true,
    this.autofillHints,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText ? obscurePassword : false,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          suffixIcon: obscureText
              ? IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0072FF).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthModeToggle extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onToggle;

  const AuthModeToggle({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AuthForgotPasswordDialog extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSend;

  const AuthForgotPasswordDialog({
    super.key,
    required this.emailController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF203A43),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        Localization.t('auth.reset_password_title'),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Localization.t('auth.reset_password_desc'),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 20),
          AuthGlassTextField(
            controller: emailController,
            focusNode: FocusNode(),
            icon: Icons.email_outlined,
            hintText: Localization.t('auth.email'),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Localization.t('common.cancel'),
              style: const TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0072FF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onSend,
          child: Text(Localization.t('auth.send_link'),
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
