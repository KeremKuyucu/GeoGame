import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// Kendi proje yollarını kontrol et
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(Localization.t('common.field_required'), Colors.orange);
      return;
    }

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext(shouldSave: true);

    setState(() => _isLoading = true);

    final String? error = await AuthService.signIn(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      _showSnackBar(Localization.t('auth.login_success'), Colors.green);
      widget.onLoginSuccess?.call();

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      AppState.selectedIndex = 0;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
            (Route<dynamic> route) => false,
      );
    } else {
      _showSnackBar(error, Theme.of(context).colorScheme.error);
    }
  }

  Future<void> _openWebAuth() async {
    final Uri url = Uri.parse('https://auth.keremkk.com.tr');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(Localization.t('common.site_error', args: [url.toString()]), Theme.of(context).colorScheme.error);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/logo.png',
                    height: 120, // 1018px resmi 120px yüksekliğe indirir, oran korunur
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'GeoGame',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localization.t('auth.login_subtitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLoginCard(theme, isDark),
                  const SizedBox(height: 30),
                  _buildRegisterSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(ThemeData theme, bool isDark) {
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
        padding: const EdgeInsets.all(32.0),
        child: AutofillGroup(
          key: const ValueKey('login_form_group'),
          onDisposeAction: AutofillContextAction.commit,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Localization.t('auth.login'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                theme: theme,
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: Localization.t('auth.email'),
                icon: Icons.email_outlined,
                obscure: false,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                theme: theme,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: Localization.t('auth.password'),
                icon: Icons.lock_outline,
                obscure: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                    : Text(
                  Localization.t('auth.login'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          Localization.t('auth.no_account'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _openWebAuth,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Localization.t('auth.web_signup'),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    FocusNode? focusNode,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: autofillHints?.contains(AutofillHints.email) == true
          ? TextInputType.emailAddress
          : TextInputType.text,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
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
}