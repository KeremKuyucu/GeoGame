import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/localization_service.dart';

// --- Extension: GameType'a Görsel ve Tema Özellikleri Ekliyoruz ---
extension GameTypeUI on GameType {
  IconData get icon {
    return switch (this) {
      GameType.flag => Icons.flag_rounded,
      GameType.capital => Icons.location_city_rounded,
      GameType.distance => Icons.straighten_rounded,
      GameType.borderline => Icons.border_all_rounded,
      GameType.borderpath => Icons.route_rounded,
      GameType.findmap => Icons.explore_rounded,
      GameType.coatofarms => Icons.shield_rounded,
    };
  }

  Color get color {
    return switch (this) {
      GameType.flag => const Color(0xFFFF9800),
      GameType.capital => const Color(0xFF9C27B0),
      GameType.distance => const Color(0xFF00BCD4),
      GameType.borderline => const Color(0xFFE91E63),
      GameType.borderpath => const Color(0xFF2196F3),
      GameType.findmap => const Color(0xFF4CAF50),
      GameType.coatofarms => const Color(0xFFFFC107),
    };
  }

  List<Color> get gradient {
    return switch (this) {
      GameType.flag => const [Color(0xFFFFB74D), Color(0xFFFF9800)],
      GameType.capital => const [Color(0xFFBA68C8), Color(0xFF8E24AA)],
      GameType.distance => const [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
      GameType.borderline => const [Color(0xFFF06292), Color(0xFFD81B60)],
      GameType.borderpath => const [Color(0xFF64B5F6), Color(0xFF1E88E5)],
      GameType.findmap => const [Color(0xFF81C784), Color(0xFF43A047)],
      GameType.coatofarms => const [Color(0xFFFFD54F), Color(0xFFFFB300)],
    };
  }
}

class _CountryStatItem {
  final String iso3;
  final String name;
  final String flagEmoji;
  final String flagUrl;
  final int score;
  final int correct;
  final int wrong;
  final int total;
  final double accuracy;

  _CountryStatItem({
    required this.iso3,
    required this.name,
    required this.flagEmoji,
    required this.flagUrl,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.accuracy,
  });
}

class ProfileViewWidget extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final int totalScore;
  final Map<String, dynamic> stats;
  final bool isOwnProfile;

  const ProfileViewWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.totalScore,
    required this.stats,
    this.isOwnProfile = true,
  });

  @override
  State<ProfileViewWidget> createState() => _ProfileViewWidgetState();
}

class _ProfileViewWidgetState extends State<ProfileViewWidget> {
  int _selectedTabIndex = 0; // 0: Oyun Modları, 1: Ülke Analizi
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortType = 'score'; // 'score', 'correct', 'wrong', 'name'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CountryStatItem> _extractCountryStats() {
    if (!widget.isOwnProfile) return [];
    final raw = widget.stats['country_stats'];
    final Map<String, dynamic> rawMap =
        raw is Map ? Map<String, dynamic>.from(raw) : {};

    if (rawMap.isEmpty) return [];

    final countryMap = {for (var c in AppState.allCountries) c.iso3: c};
    final currentLang = SettingsController.settings.language;

    final List<_CountryStatItem> items = [];
    rawMap.forEach((iso3, val) {
      if (val is Map) {
        final int score = (val['score'] as num?)?.toInt() ?? 0;
        final int correct = (val['correct'] as num?)?.toInt() ?? 0;
        final int wrong = (val['wrong'] as num?)?.toInt() ?? 0;
        final int total = correct + wrong;
        final double accuracy = total > 0 ? (correct / total) * 100 : 0.0;

        final Country? country = countryMap[iso3];
        final String name = country?.getLocalizedName(currentLang) ??
            country?.englishName ??
            iso3;
        final String flagEmoji = country?.flagEmoji ?? '';
        final String flagUrl = country?.flagUrl ?? '';

        items.add(_CountryStatItem(
          iso3: iso3,
          name: name,
          flagEmoji: flagEmoji,
          flagUrl: flagUrl,
          score: score,
          correct: correct,
          wrong: wrong,
          total: total,
          accuracy: accuracy,
        ));
      }
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final int totalCorrect =
        (widget.stats['total_correct'] as num?)?.toInt() ?? 0;
    final int totalWrong = (widget.stats['total_wrong'] as num?)?.toInt() ?? 0;
    final int totalQuestions = totalCorrect + totalWrong;
    final double overallAccuracy =
        totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    final bool showCountrySection = widget.isOwnProfile;
    final allCountryStats =
        showCountrySection ? _extractCountryStats() : <_CountryStatItem>[];
    final int discoveredCount = allCountryStats.length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        16.0,
        kToolbarHeight + MediaQuery.of(context).padding.top + 10.0,
        16.0,
        110.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profil Başlık Hero Kartı (Canlı Cam Efektli & Şampiyonluk Rozetli)
          _buildHeaderCard(isDark),
          const SizedBox(height: 16),

          // 2. Özet İstatistik Kartları (KPI Gridi)
          _buildQuickKpiGrid(
            totalCorrect: totalCorrect,
            totalWrong: totalWrong,
            overallAccuracy: overallAccuracy,
            discoveredCount: discoveredCount,
            isDark: isDark,
            showDiscoveredCount: showCountrySection,
          ),
          const SizedBox(height: 18),

          // 3. Sekme Seçici & İçerik
          if (showCountrySection) ...[
            _buildTabSelector(discoveredCount, isDark),
            const SizedBox(height: 16),
            if (_selectedTabIndex == 0)
              _buildDetailedStatsCard(isDark)
            else
              _buildCountryAnalysisTab(allCountryStats, isDark),
          ] else ...[
            _buildDetailedStatsCard(isDark),
          ],
        ],
      ),
    );
  }

  /// Profil Başlık Kartı (Ana Temayla Uyumlu Canlı Hero Kart)
  Widget _buildHeaderCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6200EE).withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF38146E).withValues(alpha: 0.90),
                        const Color(0xFF1B1138).withValues(alpha: 0.95),
                        const Color(0xFF100B22).withValues(alpha: 0.98),
                      ]
                    : [
                        const Color(0xFF6200EE),
                        const Color(0xFF7C4DFF),
                        const Color(0xFF9038FF),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Avatar & Parıldayan Çerçeve
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFB300),
                          Color(0xFFFF2A6D),
                          Color(0xFFBB86FC),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: widget.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.avatarUrl)
                          : null,
                      onBackgroundImageError: widget.avatarUrl.isNotEmpty
                          ? (_, __) {}
                          : null,
                      backgroundColor: isDark
                          ? const Color(0xFF261845)
                          : Colors.white,
                      child: widget.avatarUrl.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: isDark ? Colors.white70 : const Color(0xFF6200EE),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // İsim & Puan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name.trim().isNotEmpty
                            ? widget.name
                            : Localization.t('settings.guest'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTotalScoreBadge(),
                          if (widget.isOwnProfile) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                Localization.t('profile.title').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Toplam Puan Rozeti
  Widget _buildTotalScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            '${widget.totalScore} ${Localization.t('leaderboard.score')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// KPI Kartları Gridi
  Widget _buildQuickKpiGrid({
    required int totalCorrect,
    required int totalWrong,
    required double overallAccuracy,
    required int discoveredCount,
    required bool isDark,
    required bool showDiscoveredCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.total_correct'),
            value: totalCorrect.toString(),
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF00E676),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.total_wrong'),
            value: totalWrong.toString(),
            icon: Icons.cancel_rounded,
            color: const Color(0xFFFF5252),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.accuracy'),
            value: '%${overallAccuracy.toStringAsFixed(1)}',
            icon: Icons.pie_chart_rounded,
            color: const Color(0xFF00E5FF),
            isDark: isDark,
          ),
        ),
        if (showDiscoveredCount) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildKpiCard(
              label: Localization.t('profile.discovered_countries'),
              value: '$discoveredCount',
              icon: Icons.public_rounded,
              color: const Color(0xFFFFB300),
              isDark: isDark,
            ),
          ),
        ],
      ],
    );
  }

  /// Tekil KPI Kartı
  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark
                  ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.88),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.28 : 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sekme Seçici Kapsül Bar
  Widget _buildTabSelector(int discoveredCount, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C2A).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: Icons.sports_esports_rounded,
              title: Localization.t('profile.tab_modes'),
              isSelected: _selectedTabIndex == 0,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: Icons.public_rounded,
              title:
                  '${Localization.t('profile.tab_countries')} ($discoveredCount)',
              isSelected: _selectedTabIndex == 1,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Sekme Butonu
  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (_selectedTabIndex != index) {
          setState(() => _selectedTabIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6200EE).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Oyun Modları Detaylı İstatistik Kartı
  Widget _buildDetailedStatsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark
                  ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.90),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6200EE), Color(0xFFFF2A6D)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Localization.t('profile.stats_title'),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F1F2C),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...GameType.values.map((type) {
                  final isLast = type == GameType.values.last;
                  final prefix = AppState.getGameModeKey(type);

                  return Column(
                    children: [
                      _buildSection(prefix, type.icon, type.color, isDark),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                            height: 1,
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Oyun Modu Satırı
  Widget _buildSection(String prefix, IconData icon, Color color, bool isDark) {
    final int score = (widget.stats['score_$prefix'] ?? 0).toInt();
    final int correct = (widget.stats['${prefix}_correct'] ?? 0).toInt();
    final int wrong = (widget.stats['${prefix}_wrong'] ?? 0).toInt();
    final int total = correct + wrong;
    final double successRate = total > 0 ? (correct / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 12),
                Text(
                  Localization.t('profile.$prefix'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.blueGrey.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                '$score P',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: successRate,
            backgroundColor:
                isDark ? Colors.black38 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSmallStatBadge(
              icon: Icons.check_rounded,
              label: Localization.t('profile.correct_label', args: [correct]),
              color: const Color(0xFF00E676),
              isDark: isDark,
            ),
            _buildSmallStatBadge(
              icon: Icons.close_rounded,
              label: Localization.t('profile.wrong_label', args: [wrong]),
              color: const Color(0xFFFF5252),
              isDark: isDark,
            ),
            _buildSmallStatBadge(
              icon: Icons.percent_rounded,
              label: '${(successRate * 100).toStringAsFixed(1)}%',
              color: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6200EE),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// Küçük İstatistik Hapı
  Widget _buildSmallStatBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Ülke Analizi Sekmesi
  Widget _buildCountryAnalysisTab(
      List<_CountryStatItem> allCountryStats, bool isDark) {
    if (allCountryStats.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isDark
              ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.90),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6200EE).withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.public_off_rounded,
                size: 46,
                color: Color(0xFFBB86FC),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              Localization.t('profile.no_country_stats'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    // 1. En Başarılı 5 Ülke
    final topMastered = List<_CountryStatItem>.from(allCountryStats)
      ..sort((a, b) {
        final scoreComp = b.score.compareTo(a.score);
        if (scoreComp != 0) return scoreComp;
        return b.correct.compareTo(a.correct);
      });
    final top5 = topMastered.take(5).toList();

    // 2. Geliştirilmesi Gereken 5 Ülke
    final needsPracticeList = allCountryStats.where((c) => c.wrong > 0).toList()
      ..sort((a, b) {
        final wrongComp = b.wrong.compareTo(a.wrong);
        if (wrongComp != 0) return wrongComp;
        return a.accuracy.compareTo(b.accuracy);
      });
    final weak5 = needsPracticeList.take(5).toList();

    // 3. Arama ve Filtreleme
    final filteredList = allCountryStats.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      return item.name.toLowerCase().contains(q) ||
          item.iso3.toLowerCase().contains(q);
    }).toList();

    switch (_sortType) {
      case 'correct':
        filteredList.sort((a, b) => b.correct.compareTo(a.correct));
        break;
      case 'wrong':
        filteredList.sort((a, b) => b.wrong.compareTo(a.wrong));
        break;
      case 'name':
        filteredList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'score':
      default:
        filteredList.sort((a, b) => b.score.compareTo(a.score));
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En Başarılı Ülkeler
        if (top5.isNotEmpty) ...[
          _buildHighlightCountrySection(
            title: Localization.t('profile.top_countries'),
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFFFB300),
            items: top5,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
        ],

        // Geliştirilmesi Gereken Ülkeler
        if (weak5.isNotEmpty) ...[
          _buildHighlightCountrySection(
            title: Localization.t('profile.weak_countries'),
            icon: Icons.trending_down_rounded,
            iconColor: const Color(0xFFFF5252),
            items: weak5,
            isDark: isDark,
            isWeakSection: true,
          ),
          const SizedBox(height: 16),
        ],

        // Tüm Ülkeler Kartı & Arama
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark
                      ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.90),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Localization.t('profile.all_countries')} (${filteredList.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Arama Girişi
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: Localization.t('profile.search_country'),
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF7C4DFF),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C4DFF),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),

                    // Sıralama Çipleri
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortChip(
                            'score',
                            Localization.t('leaderboard.score'),
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            'correct',
                            Localization.t('profile.total_correct'),
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            'wrong',
                            Localization.t('profile.total_wrong'),
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip('name', 'A-Z'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ülke Listesi
                    if (filteredList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            Localization.t('profile.no_country_stats'),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildCountryTile(item, isDark);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Öne Çıkan Ülkeler Yatay Kaydırılabilir Kartı
  Widget _buildHighlightCountrySection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_CountryStatItem> items,
    required bool isDark,
    bool isWeakSection = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark
                  ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.90),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items.map((c) {
                      return Container(
                        width: 135,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (isWeakSection
                                  ? const Color(0xFFFF5252).withValues(alpha: 0.12)
                                  : const Color(0xFF6200EE).withValues(alpha: 0.14))
                              : (isWeakSection
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFF3E8FF)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWeakSection
                                ? const Color(0xFFFF5252).withValues(alpha: 0.35)
                                : const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              c.flagEmoji.isNotEmpty ? c.flagEmoji : '🌐',
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isWeakSection
                                  ? '${c.wrong} ${Localization.t('profile.total_wrong')}'
                                  : '${c.score} P',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isWeakSection
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF6200EE),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '%${c.accuracy.toStringAsFixed(0)} ${Localization.t('profile.accuracy')}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sıralama Seçim Çipi
  Widget _buildSortChip(String type, String label) {
    final isSelected = _sortType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6200EE),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF6200EE)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _sortType = type);
      },
    );
  }

  /// Ülke Satır Öğesi
  Widget _buildCountryTile(_CountryStatItem item, bool isDark) {
    final accuracyColor = item.accuracy >= 80
        ? const Color(0xFF00E676)
        : (item.accuracy >= 50
            ? const Color(0xFFFFB300)
            : const Color(0xFFFF5252));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // Bayrak Squircle
          Container(
            width: 40,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Text(
              item.flagEmoji.isNotEmpty ? item.flagEmoji : '🌐',
              style: const TextStyle(fontSize: 19),
            ),
          ),
          const SizedBox(width: 12),

          // Ülke Adı ve İstatistikler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${item.correct} D',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E676),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.wrong} Y',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '%${item.accuracy.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: accuracyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Puan Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6200EE), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${item.score} P',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
