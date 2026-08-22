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

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Blue: #4285F4
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(w * 0.98, h * 0.51)
      ..cubicTo(w * 0.98, h * 0.47, w * 0.97, h * 0.43, w * 0.96, h * 0.40)
      ..lineTo(w * 0.50, h * 0.40)
      ..lineTo(w * 0.50, h * 0.60)
      ..lineTo(w * 0.77, h * 0.60)
      ..cubicTo(w * 0.76, h * 0.66, w * 0.72, h * 0.72, w * 0.66, h * 0.76)
      ..lineTo(w * 0.66, h * 0.89)
      ..lineTo(w * 0.83, h * 0.89)
      ..cubicTo(w * 0.93, h * 0.80, w * 0.98, h * 0.67, w * 0.98, h * 0.51)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green: #34A853
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(w * 0.50, h * 0.98)
      ..cubicTo(w * 0.64, h * 0.98, w * 0.75, h * 0.94, w * 0.83, h * 0.89)
      ..lineTo(w * 0.66, h * 0.76)
      ..cubicTo(w * 0.62, h * 0.79, w * 0.56, h * 0.81, w * 0.50, h * 0.81)
      ..cubicTo(w * 0.37, h * 0.81, w * 0.27, h * 0.72, w * 0.23, h * 0.60)
      ..lineTo(w * 0.06, h * 0.60)
      ..lineTo(w * 0.06, h * 0.74)
      ..cubicTo(w * 0.14, h * 0.88, w * 0.31, h * 0.98, w * 0.50, h * 0.98)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow: #FBBC05
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(w * 0.23, h * 0.60)
      ..cubicTo(w * 0.22, h * 0.57, w * 0.21, h * 0.54, w * 0.21, h * 0.50)
      ..cubicTo(w * 0.21, h * 0.46, w * 0.22, h * 0.43, w * 0.23, h * 0.40)
      ..lineTo(w * 0.23, h * 0.40)
      ..lineTo(w * 0.06, h * 0.26)
      ..cubicTo(w * 0.02, h * 0.33, 0.00, h * 0.41, 0.00, h * 0.50)
      ..cubicTo(0.00, h * 0.59, w * 0.02, h * 0.67, w * 0.06, h * 0.74)
      ..lineTo(w * 0.23, h * 0.60)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Red: #EA4335
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(w * 0.50, h * 0.19)
      ..cubicTo(w * 0.58, h * 0.19, w * 0.65, h * 0.22, w * 0.70, h * 0.27)
      ..lineTo(w * 0.84, h * 0.13)
      ..cubicTo(w * 0.75, h * 0.05, w * 0.64, 0.00, w * 0.50, 0.00)
      ..cubicTo(w * 0.31, 0.00, w * 0.14, h * 0.10, w * 0.06, h * 0.26)
      ..lineTo(w * 0.23, h * 0.40)
      ..cubicTo(w * 0.27, h * 0.28, w * 0.37, h * 0.19, w * 0.50, h * 0.19)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthGoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String? label;

  const AuthGoogleButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final text = label ?? Localization.t('auth.google_sign_in');
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4285F4),
                    ),
                  )
                else ...[
                  const GoogleLogoWidget(size: 22),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  final String? text;
  const AuthOrDivider({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final label = text ?? Localization.t('auth.or_divider');
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
