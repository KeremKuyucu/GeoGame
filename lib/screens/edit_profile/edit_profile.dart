import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  // Controller'lar
  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // Animasyon
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );

    _loadUserProfile();
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.id;
        _emailController.text = user.email ?? '';

        // Metadata bilgilerini çek
        final metadata = user.userMetadata;
        if (metadata != null) {
          _nameController.text = metadata['full_name'] ?? '';
          _avatarUrlController.text = metadata['avatar_url'] ?? '';
        }
      });
      debugPrint("✅ Kullanıcı bilgileri cache'den başarıyla okundu.");
    } else {
      debugPrint("❌ Kullanıcı bulunamadı, giriş sayfasına yönlendiriliyor...");
      Navigator.pop(context);
    }
  }

  /// İsim ve Avatar Güncelleme
  Future<void> _updateProfile() async {
    if (_uid == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    String finalAvatarUrl = _avatarUrlController.text.trim();

    if (finalAvatarUrl.isEmpty) {
      finalAvatarUrl = "https://api.dicebear.com/8.x/initials/png?seed=$name";
    }

    final String? error = await AuthService.updateProfileMetadata(
        name: name,
        avatarUrl: finalAvatarUrl
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        await AuthService.syncUserData(AuthService.currentUser!);
        _showSnackBar(Localization.t('edit_profile.update_success'), Colors.greenAccent);
        setState(() => _avatarUrlController.text = finalAvatarUrl);
      } else {
        _showSnackBar(error, Colors.redAccent);
      }
    }
  }

  /// E-posta Güncelleme (Supabase her iki adrese onay gönderir)
  Future<void> _changeEmail() async {
    final newEmail = _emailController.text.trim();

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      _showSnackBar(Localization.t('auth.invalid_email'), Colors.orangeAccent);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final String? error = await AuthService.updateEmail(newEmail);

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        _showSnackBar(
            Localization.t('auth.check_email_confirmation'),
            Colors.blueAccent
        );
      } else {
        _showSnackBar(error, Colors.redAccent);
      }
    }
  }

  /// Şifre Güncelleme
  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      _showSnackBar(Localization.t('common.field_required'), Colors.orangeAccent);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final String? error = await AuthService.updatePassword(newPassword);

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        _showSnackBar(Localization.t('auth.password_changed'), Colors.greenAccent);
        _passwordController.clear();
      } else {
        _showSnackBar(error, Colors.redAccent);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.redAccent ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = _avatarUrlController.text.isNotEmpty
        ? _avatarUrlController.text
        : "https://api.dicebear.com/8.x/initials/png?seed=${_nameController.text}";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('edit_profile.edit_title'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatarHeader(previewUrl),
                      const SizedBox(height: 40),

                      // KİŞİSEL BİLGİLER
                      _buildGlassSection(
                        title: Localization.t('edit_profile.personal_info'),
                        icon: Icons.person_pin_circle_outlined,
                        children: [
                          _buildGlassTextField(
                            controller: _nameController,
                            hintText: Localization.t('edit_profile.display_name'),
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                            controller: _avatarUrlController,
                            hintText: Localization.t('edit_profile.avatar_url'),
                            icon: Icons.link_rounded,
                            onChanged: (val) => setState(() {}),
                          ),
                          const SizedBox(height: 25),
                          _buildGradientButton(
                            label: Localization.t('common.save'),
                            onPressed: _updateProfile,
                            isLoading: _isLoading,
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // HESAP GÜVENLİĞİ (Email & Şifre Burada)
                      _buildGlassSection(
                        title: Localization.t('auth.security'),
                        icon: Icons.security_rounded,
                        children: [
                          // EMAIL DEĞİŞTİRME BÖLÜMÜ
                          _buildGlassTextField(
                            controller: _emailController,
                            hintText: Localization.t('auth.email'),
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 10),
                          _buildGradientButton(
                            label: Localization.t('auth.update_email'),
                            onPressed: _changeEmail,
                            isLoading: _isLoading,
                            colors: [Colors.blueGrey, Colors.indigo],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Colors.white10),
                          ),
                          // ŞİFRE DEĞİŞTİRME BÖLÜMÜ
                          _buildGlassTextField(
                            controller: _passwordController,
                            hintText: Localization.t('auth.new_password'),
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                          ),
                          const SizedBox(height: 15),
                          _buildGradientButton(
                            label: Localization.t('auth.update_password'),
                            onPressed: _changePassword,
                            isLoading: _isLoading,
                            colors: [Colors.orangeAccent, Colors.deepOrange],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader(String previewUrl) {
    return Hero(
      tag: 'profile_avatar',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.purpleAccent]),
        ),
        child: CircleAvatar(
          radius: 65,
          backgroundColor: Colors.grey[900],
          child: ClipOval(
            child: Image.network(
              previewUrl,
              width: 130, height: 130, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.person, size: 60, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSection({required String title, required IconData icon, required List<Widget> children}) {
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildGlassTextField({required TextEditingController controller, required String hintText, required IconData icon, bool obscureText = false, Function(String)? onChanged}) {
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
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String label, required VoidCallback onPressed, required bool isLoading, required List<Color> colors}) {
    return Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}