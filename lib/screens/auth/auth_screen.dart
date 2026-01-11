// lib/screens/auth/auth_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_ui_service.dart';
import 'package:geogame/services/localization_service.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const AuthPage({super.key, this.onLoginSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _confirmPasswordController;

  // Focus Nodes
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  // Animations
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  // Colors
  static const Color _primaryColor = Color(0xFF4A00E0);
  static const Color _secondaryColor = Color(0xFF8E2DE2);

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
  }

  void _initControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ============================================================================
  // İŞLEMLER
  // ============================================================================

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext(shouldSave: true);

    setState(() => _isLoading = true);

    final result = await AuthUIService.performLogin(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _showSnackBar(result.message, Colors.greenAccent);
      widget.onLoginSuccess?.call();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _navigateToHome();
    } else {
      _showSnackBar(result.message, Colors.redAccent);
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final result = await AuthUIService.performRegister(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _showSnackBar(result.message, Colors.greenAccent);
      widget.onLoginSuccess?.call();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _navigateToHome();
    } else {
      _showSnackBar(result.message, Colors.redAccent);
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    resetEmailController.text = _emailController.text;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Localization.t('auth.reset_password_title'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localization.t('auth.reset_password_desc'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildGlassTextField(
              controller: resetEmailController,
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
            child: Text(Localization.t('common.cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0072FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);

              final result = await AuthUIService.sendPasswordReset(email);

              if (!mounted) return;
              setState(() => _isLoading = false);

              if (result.isSuccess) {
                _showSnackBar(result.message, Colors.greenAccent);
              } else {
                _showSnackBar(result.message, Colors.redAccent);
              }
            },
            child: Text(Localization.t('auth.send_link'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    AppState.selectedIndex = 0;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _toggleMode() {
    setState(() => _isLoginMode = !_isLoginMode);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (color == Colors.redAccent) const Icon(Icons.error_outline, color: Colors.white),
            if (color == Colors.greenAccent) const Icon(Icons.check_circle_outline, color: Colors.white),
            if (color != Colors.redAccent && color != Colors.greenAccent) const SizedBox(),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
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

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildDecorativeCircles(),
          _buildContent(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
    );
  }

  Widget _buildBackground() {
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

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.4),
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
              color: _secondaryColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildAuthCard(),
                const SizedBox(height: 30),
                _buildModeToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
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
          'assets/images/logo.png',
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'GEOGAME',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
            shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(0, 2))],
          ),
        ),
        Text(
          _isLoginMode
              ? Localization.t('auth.login_subtitle')
              : Localization.t('auth.register_subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
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
          child: AutofillGroup(
            child: Column(
              children: [
                _buildCardTitle(),
                const SizedBox(height: 30),
                _buildFormFields(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTitle() {
    return Text(
      _isLoginMode ? Localization.t('auth.login') : Localization.t('auth.signup'),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Name field (only for register)
        if (!_isLoginMode) ...[
          _buildGlassTextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            icon: Icons.person_rounded,
            hintText: Localization.t('auth.name'),
            autofillHints: [AutofillHints.name],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
          ),
          const SizedBox(height: 20),
        ],

        // Email
        _buildGlassTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          icon: Icons.email_rounded,
          hintText: Localization.t('auth.email'),
          autofillHints: [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
        ),
        const SizedBox(height: 20),

        // Password
        _buildGlassTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          icon: Icons.lock_rounded,
          hintText: Localization.t('auth.password'),
          obscureText: true,
          autofillHints: [AutofillHints.password],
          textInputAction: _isLoginMode ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) {
            if (_isLoginMode) {
              _handleLogin();
            } else {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            }
          },
        ),

        // Forgot Password (login mode only)
        if (_isLoginMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                Localization.t('auth.forgot_password'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Confirm Password (register mode only)
        if (!_isLoginMode) ...[
          const SizedBox(height: 20),
          _buildGlassTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            icon: Icons.lock_outline_rounded,
            hintText: Localization.t('auth.confirm_password'),
            obscureText: true,
            autofillHints: [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleRegister(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isLoginMode ? _handleLogin : _handleRegister),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    (_isLoginMode ? Localization.t('auth.login') : Localization.t('auth.register')).toUpperCase(),
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

  Widget _buildModeToggle() {
    return Column(
      children: [
        Text(
          _isLoginMode ? Localization.t('auth.no_account') : Localization.t('auth.have_account'),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _toggleMode,
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
                  _isLoginMode ? Localization.t('auth.signup') : Localization.t('auth.login'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // YARDIMCI WIDGETLAR
  // ============================================================================

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText ? _obscurePassword : false,
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
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
