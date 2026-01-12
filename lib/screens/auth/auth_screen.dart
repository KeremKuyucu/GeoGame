import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/auth_widgets.dart';

import 'auth_controller.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const AuthPage({super.key, this.onLoginSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final AuthController _controller = AuthController();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _confirmPasswordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          const AuthDecorativeCircles(),
          Center(
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
                      const AuthLogo(),
                      const SizedBox(height: 20),
                      AuthTitle(subtitle: _controller.getSubtitle()),
                      const SizedBox(height: 40),
                      AuthGlassCard(
                        children: [
                          Text(
                            _controller.getCardTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          AutofillGroup(child: _buildFormFields()),
                          const SizedBox(height: 30),
                          AuthSubmitButton(
                            label: _controller.getSubmitButtonText(),
                            isLoading: _controller.isLoading,
                            onPressed: () => _controller.isLoginMode
                                ? _handleLogin()
                                : _handleRegister(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      AuthModeToggle(
                        message: _controller.getModeToggleText(),
                        buttonText: _controller.getModeToggleButtonText(),
                        onToggle: () =>
                            setState(() => _controller.toggleMode()),
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

  Widget _buildFormFields() {
    return Column(
      children: [
        if (!_controller.isLoginMode) ...[
          AuthGlassTextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            icon: Icons.person_rounded,
            hintText: Localization.t('auth.name'),
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocusNode),
          ),
          const SizedBox(height: 20),
        ],
        AuthGlassTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          icon: Icons.email_rounded,
          hintText: Localization.t('auth.email'),
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_passwordFocusNode),
        ),
        const SizedBox(height: 20),
        AuthGlassTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          icon: Icons.lock_rounded,
          hintText: Localization.t('auth.password'),
          obscureText: true,
          obscurePassword: _controller.obscurePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: _controller.isLoginMode
              ? TextInputAction.done
              : TextInputAction.next,
          onTogglePassword: () =>
              setState(() => _controller.togglePasswordVisibility()),
          onSubmitted: (_) {
            if (_controller.isLoginMode) {
              _handleLogin();
            } else {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            }
          },
        ),
        if (_controller.isLoginMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
        if (!_controller.isLoginMode) ...[
          const SizedBox(height: 20),
          AuthGlassTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            icon: Icons.lock_outline_rounded,
            hintText: Localization.t('auth.confirm_password'),
            obscureText: true,
            obscurePassword: _controller.obscurePassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onTogglePassword: () =>
                setState(() => _controller.togglePasswordVisibility()),
            onSubmitted: (_) => _handleRegister(),
          ),
        ],
      ],
    );
  }

  Future<void> _handleLogin() async {
    _controller.unfocusAndFinishAutofill(context);
    setState(() => _controller.isLoading = true);

    final result = await _controller.handleLogin(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _controller.isLoading = false);

    if (result.isSuccess) {
      _controller.showSnackBar(context, result.message, Colors.greenAccent);
      widget.onLoginSuccess?.call();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _controller.navigateToHome(context);
    } else {
      _controller.showSnackBar(context, result.message, Colors.redAccent);
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() => _controller.isLoading = true);

    final result = await _controller.handleRegister(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _controller.isLoading = false);

    if (result.isSuccess) {
      _controller.showSnackBar(context, result.message, Colors.greenAccent);
      widget.onLoginSuccess?.call();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _controller.navigateToHome(context);
    } else {
      _controller.showSnackBar(context, result.message, Colors.redAccent);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (dialogContext) => AuthForgotPasswordDialog(
        emailController: resetEmailController,
        onSend: () async {
          final email = resetEmailController.text.trim();
          if (email.isEmpty) return;

          Navigator.pop(dialogContext);
          setState(() => _controller.isLoading = true);

          final result = await _controller.sendPasswordReset(email);

          if (!mounted) return;
          setState(() => _controller.isLoading = false);

          if (result.isSuccess) {
            _controller.showSnackBar(
                context, result.message, Colors.greenAccent);
          } else {
            _controller.showSnackBar(context, result.message, Colors.redAccent);
          }
        },
      ),
    );
  }
}
