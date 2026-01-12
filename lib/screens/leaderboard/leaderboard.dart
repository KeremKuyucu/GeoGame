import 'package:flutter/material.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/leaderboard_widgets.dart';
import 'package:geogame/services/localization_service.dart';

import 'leaderboard_controller.dart';

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
    _controller.fetchLeaderboard().then((_) {
      if (mounted) setState(() {});
      if (_controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.errorMessage!)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                if (listIndex >= _controller.users.length)
                                  return null;
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
