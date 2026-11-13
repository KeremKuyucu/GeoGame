import 'package:flutter/material.dart';

import 'package:geogame/widgets/leaderboard_widgets.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/leaderboard/leaderboard_controller.dart';

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
      if (!mounted) return;
      setState(() {});
      if (_controller.errorMessage != null && !_controller.isOffline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF2A6D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              Localization.t('leaderboard.title').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : const Color(0xFF2C2C3E),
                fontSize: 18,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
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
              onPressed: () => _controller.fetchLeaderboard().then((_) {
                if (mounted) setState(() {});
              }),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _controller.getBackgroundColors(isDark),
          ),
        ),
        child: _controller.isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? const Color(0xFF6200EE) : Colors.pink)
                            .withValues(alpha: 0.15),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2A6D)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      Localization.t('common.loading'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: const Color(0xFFFF2A6D),
                backgroundColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
                onRefresh: () async {
                  await _controller.fetchLeaderboard();
                  if (mounted) setState(() {});
                },
                child: _controller.isOffline && _controller.users.isEmpty
                    ? LeaderboardOfflineView(
                        onRetry: () => _controller.fetchLeaderboard().then((_) {
                          if (mounted) setState(() {});
                        }),
                      )
                    : _controller.users.isEmpty
                        ? const LeaderboardEmptyState()
                        : Stack(
                            children: [
                              CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                slivers: [
                                  // AppBar boşluğu
                                  SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: kToolbarHeight +
                                          MediaQuery.of(context).padding.top +
                                          8,
                                    ),
                                  ),

                                  // Şampiyonluk Podyumu (İlk 3 sıra)
                                  if (_controller.hasPodium)
                                    SliverToBoxAdapter(
                                      child: LeaderboardPodium(
                                          controller: _controller),
                                    ),

                                  // Liste Başlığı (Zirvedekiler)
                                  if (_controller.listUserCount > 0)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 14, 22, 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF7C4DFF)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.format_list_numbered_rounded,
                                                size: 16,
                                                color: Color(0xFF9E7BFF),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              Localization.t('leaderboard.top_players'),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                                color: isDark
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade800,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.white.withValues(alpha: 0.08)
                                                    : Colors.black.withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${_controller.users.length} ${Localization.t('nav.rank')}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // 4. sıra ve sonrası oyuncu kartları
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      4,
                                      16,
                                      _controller.currentUserRank != null
                                          ? 175
                                          : 105,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final listIndex =
                                              _controller.getActualIndex(index);
                                          if (listIndex >=
                                              _controller.users.length) {
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

                              // Kullanıcının Kendi Sıralaması (Yüzen Alt Bar)
                              if (_controller.currentUserRank != null)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 92,
                                  child: LeaderboardMyRankBar(
                                    controller: _controller,
                                  ),
                                ),
                            ],
                          ),
              ),
      ),
    );
  }
}
