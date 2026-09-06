import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/auth_widgets.dart';
import 'package:geogame/screens/auth/auth_controller.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const AuthPage({super.key, this.onLoginSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final AuthController _controller = AuthController();
  StreamSubscription<AuthState>? _authSub;
  bool _isHandlingAuth = false;
  bool _hasNavigated = false;

  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );

    // Harici OAuth deep link dönüşlerini dinle
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn && mounted && !_hasNavigated) {
        final user = data.session?.user;
        if (user != null) {
          _hasNavigated = true;
          await AuthService.syncUserData(user);
          if (!mounted) return;

          _controller.showSnackBar(
            context,
            Localization.t('auth.google_login_success'),
            Colors.greenAccent,
          );
          widget.onLoginSuccess?.call();
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;
          _controller.navigateToHome(context);
        }
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    if (_isHandlingAuth || _hasNavigated) return;
    _isHandlingAuth = true;
    setState(() => _controller.isGoogleLoading = true);

    try {
      final result = await _controller.handleGoogleLogin();

      if (!mounted) return;
      setState(() => _controller.isGoogleLoading = false);

      if (result.isSuccess) {
        if (AuthService.isAuthenticated) {
          if (!_hasNavigated) {
            _hasNavigated = true;
            _controller.showSnackBar(context, result.message, Colors.greenAccent);
            widget.onLoginSuccess?.call();
            await Future.delayed(const Duration(milliseconds: 300));
            if (!mounted) return;
            _controller.navigateToHome(context);
          }
        } else {
          // Harici OAuth tarayıcı akışı başlatıldı, deep link bekleniyor
          _isHandlingAuth = false;
        }
      } else {
        _isHandlingAuth = false;
        if (result.message != Localization.t('auth.error_google_cancelled')) {
          _controller.showSnackBar(context, result.message, Colors.redAccent);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _controller.isGoogleLoading = false);
        _isHandlingAuth = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AuthLogo(),
                      const SizedBox(height: 16),
                      AuthTitle(subtitle: Localization.t('auth.login_subtitle')),
                      const SizedBox(height: 32),
                      AuthGlassCard(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                Localization.t('auth.login'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            Localization.t('auth.login_prompt'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _AuthFeatureItem(
                            icon: Icons.emoji_events_rounded,
                            iconColor: const Color(0xFFFFB74D),
                            title: Localization.t('auth.feature_leaderboard_title'),
                            description: Localization.t('auth.feature_leaderboard_desc'),
                          ),
                          _AuthFeatureItem(
                            icon: Icons.cloud_done_rounded,
                            iconColor: const Color(0xFF4FC3F7),
                            title: Localization.t('auth.feature_cloud_sync_title'),
                            description: Localization.t('auth.feature_cloud_sync_desc'),
                          ),
                          _AuthFeatureItem(
                            icon: Icons.bolt_rounded,
                            iconColor: const Color(0xFF81C784),
                            title: Localization.t('auth.feature_instant_title'),
                            description: Localization.t('auth.feature_instant_desc'),
                          ),
                          const SizedBox(height: 24),
                          AuthGoogleButton(
                            isLoading: _controller.isGoogleLoading,
                            onPressed: _handleGoogleLogin,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            _controller.navigateToHome(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Localization.t('auth.continue_as_guest'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ],
                        ),
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
}

class _AuthFeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _AuthFeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
