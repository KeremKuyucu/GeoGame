import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/profile_view_widget.dart';
import 'package:geogame/widgets/profile_guest_view.dart';
import 'package:geogame/widgets/profile_offline_view.dart';

import 'package:geogame/screens/profiles/profiles_controller.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final ProfilesController _controller = ProfilesController();

  @override
  void initState() {
    super.initState();
    AppState.userNotifier.addListener(_onUserChanged);
    _controller.fetchUserProfile().then((_) {
      if (!mounted) return;
      setState(() {});
      if (_controller.errorMessage != null && !_controller.isOffline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    AppState.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    PreferredSizeWidget buildCustomAppBar({List<Widget>? actions}) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFFFF2A6D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6200EE).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              Localization.t('profile.title').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : const Color(0xFF2C2C3E),
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
      );
    }

    Widget buildRefreshAction() {
      return Container(
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          tooltip: Localization.t('common.refresh'),
          onPressed: () => _controller.fetchUserProfile().then((_) {
            if (mounted) setState(() {});
          }),
        ),
      );
    }

    if (_controller.isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: buildCustomAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _controller.getBackgroundColors(isDark),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
            ),
          ),
        ),
      );
    }

    if (!_controller.isAuthenticated) {
      return ProfilesGuestView(controller: _controller);
    }

    if (_controller.isOffline) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: buildCustomAppBar(actions: [buildRefreshAction()]),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _controller.getBackgroundColors(isDark),
            ),
          ),
          child: RefreshIndicator(
            color: const Color(0xFFFF2A6D),
            backgroundColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
            onRefresh: () async {
              await _controller.fetchUserProfile();
              if (mounted) setState(() {});
            },
            child: ProfileOfflineView(
              name: _controller.userName,
              avatarUrl: _controller.userAvatar,
              onRetry: () => _controller.fetchUserProfile().then((_) {
                if (mounted) setState(() {});
              }),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildCustomAppBar(actions: [buildRefreshAction()]),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _controller.getBackgroundColors(isDark),
          ),
        ),
        child: RefreshIndicator(
          color: const Color(0xFFFF2A6D),
          backgroundColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
          onRefresh: () async {
            await _controller.fetchUserProfile();
            if (mounted) setState(() {});
          },
          child: ProfileViewWidget(
            name: _controller.userName,
            avatarUrl: _controller.userAvatar,
            totalScore: _controller.totalScore,
            stats: _controller.statsData,
            isOwnProfile: true,
          ),
        ),
      ),
    );
  }
}
