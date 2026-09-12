import 'package:flutter/material.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/leaderboard_widgets.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/screens/leaderboard/leaderboard_controller.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final LeaderboardController _controller = LeaderboardController();

  @override
  void initState() {
    super.initState();
    if (!SettingsController.isChildMode) {
      _controller.fetchLeaderboard().then((_) {
        if (!mounted) return;
        setState(() {});
        if (_controller.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_controller.errorMessage!)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (SettingsController.isChildMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            Localization.t('leaderboard.title').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.pink,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 64,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  Localization.t(
                      'settings.child_mode_leaderboard_disabled_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  Localization.t(
                      'settings.child_mode_leaderboard_disabled_desc'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('leaderboard.title').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.pink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.fetchLeaderboard().then((_) {
              if (mounted) setState(() {});
            }),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _controller.fetchLeaderboard();
                if (mounted) setState(() {});
              },
              child: _controller.users.isEmpty
                  ? const LeaderboardEmptyState()
                  : CustomScrollView(
                      slivers: [
                        if (_controller.hasPodium)
                          SliverToBoxAdapter(
                            child: LeaderboardPodium(controller: _controller),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final listIndex =
                                    _controller.getActualIndex(index);
                                if (listIndex >= _controller.users.length) {
                                  return null;
                                }
                                return LeaderboardUserCard(
                                  controller: _controller,
                                  index: listIndex,
                                );
                              },
                              childCount: _controller.listUserCount,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
