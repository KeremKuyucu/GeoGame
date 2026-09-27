import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/drawer_widget.dart';
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
    if (_controller.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            Localization.t('profile.title').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.teal,
            ),
          ),
          centerTitle: true,
        ),
        drawer: const DrawerWidget(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.isOffline) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            Localization.t('profile.title').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.teal,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _controller.fetchUserProfile().then((_) {
                if (mounted) setState(() {});
              }),
            ),
          ],
        ),
        drawer: const DrawerWidget(),
        body: RefreshIndicator(
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
      );
    }

    if (!_controller.isAuthenticated) {
      return ProfilesGuestView(controller: _controller);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.fetchUserProfile().then((_) {
              if (mounted) setState(() {});
            }),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.fetchUserProfile();
          if (mounted) setState(() {});
        },
        child: ProfileViewWidget(
          name: _controller.userName,
          avatarUrl: _controller.userAvatar,
          totalScore: _controller.totalScore,
          stats: _controller.statsData,
        ),
      ),
    );
  }
}
