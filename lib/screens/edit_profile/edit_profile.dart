import 'dart:ui'; // Glassmorphism için gerekli
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Projenizdeki yolları kontrol edin
import 'package:geogame/services/localization_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  // Controller'lar
  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _passwordController;

  // Animasyon
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _uid;
  String? _email;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _passwordController = TextEditingController();

    // Animasyon Kurulumu
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
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Mevcut kullanıcı verilerini yükle
  Future<void> _loadUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.id;
        _email = user.email;
        _nameController.text = user.userMetadata?['full_name'] ?? '';
        _avatarUrlController.text = user.userMetadata?['avatar_url'] ?? '';
      });
    }
  }

  /// Profil Bilgilerini Güncelle
  Future<void> _updateProfile() async {
    if (_uid == null) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    String finalAvatarUrl = _avatarUrlController.text.trim();

    if (finalAvatarUrl.isEmpty) {
      finalAvatarUrl = "https://api.dicebear.com/8.x/initials/png?seed=$name";
    }

    try {
      final UserResponse res = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'avatar_url': finalAvatarUrl,
          },
        ),
      );

      if (res.user == null) throw "Kullanıcı güncellenemedi.";

      await _supabase.from('profiles').upsert({
        'uid': _uid,
        'email': _email,
        'full_name': name,
        'avatar_url': finalAvatarUrl,
      }, onConflict: 'uid');

      if (mounted) {
        _showSnackBar(Localization.t('edit_profile.update_success'), Colors.greenAccent);
        setState(() {
          _avatarUrlController.text = finalAvatarUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Şifre Değiştirme
  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();

    if (newPassword.isEmpty) {
      _showSnackBar(Localization.t('common.field_required'), Colors.orangeAccent);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        _showSnackBar(Localization.t('auth.password_changed'), Colors.greenAccent);
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    // Canlı Önizleme URL'i
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
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Stack(
        children: [
          // 1. ARKA PLAN (Gradient & Blobs)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Login sayfasıyla uyumlu koyu tema
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 50, color: Colors.blueAccent.withOpacity(0.3))],
              ),
            ),
          ),

          // 2. İÇERİK
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
                      // --- AVATAR ÖNİZLEME ---
                      Hero(
                        tag: 'profile_avatar',
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.purpleAccent]),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey[900],
                                backgroundImage: CachedNetworkImageProvider(previewUrl),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.edit, color: Colors.purpleAccent, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- KİŞİSEL BİLGİLER KARTI (Glass) ---
                      _buildGlassSection(
                        title: Localization.t('edit_profile.personal_info'),
                        icon: Icons.person_pin_circle_outlined,
                        children: [
                          _buildGlassTextField(
                            controller: _nameController,
                            hintText: Localization.t('edit_profile.display_name'),
                            icon: Icons.person_outline_rounded,
                            onChanged: (val) => setState(() {}),
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

                      // --- GÜVENLİK KARTI (Glass) ---
                      _buildGlassSection(
                        title: Localization.t('auth.security'),
                        icon: Icons.security_rounded,
                        children: [
                          _buildGlassTextField(
                            controller: _passwordController,
                            hintText: Localization.t('auth.new_password'),
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                          ),
                          const SizedBox(height: 25),
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

  // --- REUSABLE WIDGETS ---

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(color: Colors.white10, height: 1),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}