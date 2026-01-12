import 'dart:ui';
import 'package:flutter/material.dart';

class EditProfileBackground extends StatelessWidget {
  const EditProfileBackground({super.key});

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

class EditProfileAvatarHeader extends StatelessWidget {
  final String previewUrl;

  const EditProfileAvatarHeader({super.key, required this.previewUrl});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'profile_avatar',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              LinearGradient(colors: [Colors.cyanAccent, Colors.purpleAccent]),
        ),
        child: CircleAvatar(
          radius: 65,
          backgroundColor: Colors.grey[900],
          child: ClipOval(
            child: Image.network(
              previewUrl,
              width: 130,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.person, size: 60, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfileGlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const EditProfileGlassSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 30),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileGlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Function(String)? onChanged;

  const EditProfileGlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon:
              Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}

class EditProfileGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final List<Color> colors;

  const EditProfileGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
