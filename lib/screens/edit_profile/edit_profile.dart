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

class _EditProfilePageState extends State<EditProfilePage> {
  final _supabase = Supabase.instance.client;

  // Controller'lar
  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  String? _uid;
  String? _email;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Mevcut kullanıcı verilerini yükle
  Future<void> _loadUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.id;
        _email = user.email;
        // Metadata'dan verileri çek
        _nameController.text = user.userMetadata?['full_name'] ?? '';
        _avatarUrlController.text = user.userMetadata?['avatar_url'] ?? '';
      });
    }
  }

  /// Profil Bilgilerini Güncelle (İsim ve Avatar)
  Future<void> _updateProfile() async {
    if (_uid == null) return;
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    String finalAvatarUrl = _avatarUrlController.text.trim();

    // Eğer avatar boşsa Dicebear (Varsayılan Avatar) kullan
    if (finalAvatarUrl.isEmpty) {
      finalAvatarUrl = "https://api.dicebear.com/8.x/initials/png?seed=$name";
    }

    try {
      // 1. Auth User Metadata güncelleme
      final UserResponse res = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'avatar_url': finalAvatarUrl,
          },
        ),
      );

      if (res.user == null) throw "Kullanıcı güncellenemedi.";

      // 2. Profiles tablosunu güncelleme (Veritabanı yedeği)
      await _supabase.from('profiles').upsert({
        'uid': _uid,
        'email': _email,
        'full_name': name,
        'avatar_url': finalAvatarUrl,
      }, onConflict: 'uid');

      if (mounted) {
        _showSnackBar(Localization.t('edit_profile.update_success'), Colors.green);
        // Inputu da güncelle ki kullanıcı değişikliği görsün
        setState(() {
          _avatarUrlController.text = finalAvatarUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Theme.of(context).colorScheme.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Şifre Değiştirme
  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();

    if (newPassword.isEmpty) {
      _showSnackBar(Localization.t('common.field_required'), Colors.orange);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        _showSnackBar(Localization.t('auth.password_changed'), Colors.green);
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), Theme.of(context).colorScheme.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Canlı Önizleme URL'i
    final previewUrl = _avatarUrlController.text.isNotEmpty
        ? _avatarUrlController.text
        : "https://api.dicebear.com/8.x/initials/png?seed=${_nameController.text}";

    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.t('edit_profile.edit_title')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- AVATAR ÖNİZLEME ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            // CachedNetworkImageProvider kullanımı
                            backgroundImage: CachedNetworkImageProvider(previewUrl),
                            onBackgroundImageError: (_, __) {},
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- KİŞİSEL BİLGİLER KARTI ---
                  _buildSectionCard(
                    theme: theme,
                    title: Localization.t('edit_profile.personal_info'),
                    children: [
                      _buildTextField(
                        theme: theme,
                        controller: _nameController,
                        label: Localization.t('edit_profile.display_name'),
                        icon: Icons.person_outline_rounded,
                        onChanged: (val) => setState(() {}), // Önizlemeyi güncelle
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        theme: theme,
                        controller: _avatarUrlController,
                        label: Localization.t('edit_profile.avatar_url'),
                        icon: Icons.image_outlined,
                        onChanged: (val) => setState(() {}), // Önizlemeyi güncelle
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        theme: theme,
                        label: Localization.t('common.save'),
                        onPressed: _updateProfile,
                        isLoading: _isLoading,
                        isPrimary: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- GÜVENLİK (ŞİFRE) KARTI ---
                  _buildSectionCard(
                    theme: theme,
                    title: Localization.t('auth.security'),
                    children: [
                      _buildTextField(
                        theme: theme,
                        controller: _passwordController,
                        label: Localization.t('auth.new_password'),
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        theme: theme,
                        label: Localization.t('auth.update_password'),
                        onPressed: _changePassword,
                        isLoading: _isLoading,
                        isPrimary: false, // İkincil stil
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Function(String)? onChanged,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface;

    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildButton({
    required ThemeData theme,
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
    bool isPrimary = true,
  }) {
    final backgroundColor = isPrimary ? theme.colorScheme.primary : Colors.orange.shade700;
    final foregroundColor = theme.colorScheme.onPrimary;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: foregroundColor,
        ),
      )
          : Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}