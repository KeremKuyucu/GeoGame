import 'dart:ui'; // Glassmorphism için gerekli
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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  // Animasyon için (Girişte hafif yukarı kayma efekti)
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    // Giriş Animasyonu
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(Localization.t('common.field_required'), Colors.orangeAccent);
      return;
    }

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext(shouldSave: true);

    setState(() => _isLoading = true);

    final String? error = await AuthService.signIn(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      // Başarılı giriş
      _showSnackBar(Localization.t('auth.login_success'), Colors.greenAccent);
      widget.onLoginSuccess?.call();

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      AppState.selectedIndex = 0;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
            (Route<dynamic> route) => false,
      );
    } else {
      _showSnackBar(error, Colors.redAccent);
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
        _showSnackBar(Localization.t('common.site_error', args: [url.toString()]), Colors.red);
      }
    }
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
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    // Koyu tema veya harita teması renkleri
    const Color primaryColor = Color(0xFF4A00E0); // Morumsu
    const Color secondaryColor = Color(0xFF8E2DE2); // Pembeleşen Mor

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
          // 1. KATMAN: ARKA PLAN (Gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                // Alternatif Mor Tema: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]
              ),
            ),
          ),

          // Dekoratif Arka Plan Daireleri (Blur efektini güçlendirmek için)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.4),
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
                color: secondaryColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 2. KATMAN: İÇERİK
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
                      // LOGO
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'GEOGAME',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(0, 2))]
                        ),
                      ),

                      Text(
                        Localization.t('auth.login_subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // GLASSMORPHISM LOGIN CARD
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: AutofillGroup(
                              child: Column(
                                children: [
                                  Text(
                                    Localization.t('auth.login'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Email Input
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

                                  // Password Input
                                  _buildGlassTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    icon: Icons.lock_rounded,
                                    hintText: Localization.t('auth.password'),
                                    obscureText: true,
                                    autofillHints: [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleLogin(),
                                  ),

                                  const SizedBox(height: 30),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // Canlı Mavi Gradient
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF0072FF).withOpacity(0.4),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              )
                                            ]
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: _isLoading
                                              ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                              : Text(
                                            Localization.t('auth.login').toUpperCase(),
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Register / Sign Up Section
                      Column(
                        children: [
                          Text(
                            Localization.t('auth.no_account'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: _openWebAuth,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white.withOpacity(0.05),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    Localization.t('auth.web_signup'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
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

  // Özel Tasarım Input Widget'ı
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
        color: Colors.black.withOpacity(0.2), // Hafif koyu zemin, beyaz yazı için
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}