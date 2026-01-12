import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/edit_profile_widgets.dart';

import 'edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final EditProfileController _controller = EditProfileController();

  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );

    _controller
        .loadUserProfile(
            _nameController, _avatarUrlController, _emailController)
        .then((_) {
      if (!_controller.isUserAvailable && mounted) {
        Navigator.pop(context);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final previewUrl = _controller.getPreviewUrl(
      _avatarUrlController.text,
      _nameController.text,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('edit_profile.edit_title'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const EditProfileBackground(),
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      EditProfileAvatarHeader(previewUrl: previewUrl),
                      const SizedBox(height: 40),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 30),
                      _buildSecuritySection(),
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

  Widget _buildPersonalInfoSection() {
    return EditProfileGlassSection(
      title: Localization.t('edit_profile.personal_info'),
      icon: Icons.person_pin_circle_outlined,
      children: [
        EditProfileGlassTextField(
          controller: _nameController,
          hintText: Localization.t('edit_profile.display_name'),
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 15),
        EditProfileGlassTextField(
          controller: _avatarUrlController,
          hintText: Localization.t('edit_profile.avatar_url'),
          icon: Icons.link_rounded,
          onChanged: (val) => setState(() {}),
        ),
        const SizedBox(height: 25),
        EditProfileGradientButton(
          label: Localization.t('common.save'),
          onPressed: _updateProfile,
          isLoading: _controller.isLoading,
          colors: [Colors.cyanAccent, Colors.blueAccent],
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return EditProfileGlassSection(
      title: Localization.t('auth.security'),
      icon: Icons.security_rounded,
      children: [
        EditProfileGlassTextField(
          controller: _emailController,
          hintText: Localization.t('auth.email'),
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 10),
        EditProfileGradientButton(
          label: Localization.t('auth.update_email'),
          onPressed: _changeEmail,
          isLoading: _controller.isLoading,
          colors: [Colors.blueGrey, Colors.indigo],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: Colors.white10),
        ),
        EditProfileGlassTextField(
          controller: _passwordController,
          hintText: Localization.t('auth.new_password'),
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 15),
        EditProfileGradientButton(
          label: Localization.t('auth.update_password'),
          onPressed: _changePassword,
          isLoading: _controller.isLoading,
          colors: [Colors.orangeAccent, Colors.deepOrange],
        ),
      ],
    );
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _controller.isLoading = true);

    final error = await _controller.updateProfile(
      _nameController.text,
      _avatarUrlController.text,
    );

    if (mounted) {
      setState(() => _controller.isLoading = false);
      if (error == null) {
        _controller.showSnackBar(
          context,
          Localization.t('edit_profile.update_success'),
          Colors.greenAccent,
        );
        setState(() {});
      } else {
        _controller.showSnackBar(context, error, Colors.redAccent);
      }
    }
  }

  Future<void> _changeEmail() async {
    FocusScope.of(context).unfocus();
    setState(() => _controller.isLoading = true);

    final error = await _controller.changeEmail(_emailController.text.trim());

    if (mounted) {
      setState(() => _controller.isLoading = false);
      if (error == null) {
        _controller.showSnackBar(
          context,
          Localization.t('auth.check_email_confirmation'),
          Colors.blueAccent,
        );
      } else {
        _controller.showSnackBar(context, error, Colors.redAccent);
      }
    }
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    setState(() => _controller.isLoading = true);

    final error =
        await _controller.changePassword(_passwordController.text.trim());

    if (mounted) {
      setState(() => _controller.isLoading = false);
      if (error == null) {
        _controller.showSnackBar(
          context,
          Localization.t('auth.password_changed'),
          Colors.greenAccent,
        );
        _passwordController.clear();
      } else {
        _controller.showSnackBar(context, error, Colors.redAccent);
      }
    }
  }
}
