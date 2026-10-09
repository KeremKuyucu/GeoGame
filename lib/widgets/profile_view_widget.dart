import 'package:flutter/material.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/services/localization_service.dart';

// --- Extension: GameType'a Görsel Özellikler Ekliyoruz ---
extension GameTypeUI on GameType {
  IconData get icon {
    return switch (this) {
      GameType.flag => Icons.flag,
      GameType.capital => Icons.location_city,
      GameType.distance => Icons.straighten,
      GameType.borderline => Icons.border_all,
      GameType.borderpath => Icons.route,
      GameType.findmap => Icons.explore,
      GameType.coatofarms => Icons.shield,
    };
  }

  Color get color {
    return switch (this) {
      GameType.flag => Colors.orangeAccent,
      GameType.capital => Colors.purpleAccent,
      GameType.distance => Colors.tealAccent,
      GameType.borderline => Colors.pinkAccent,
      GameType.borderpath => Colors.blueAccent,
      GameType.findmap => Colors.greenAccent,
      GameType.coatofarms => Colors.amberAccent,
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

  const ProfileViewWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.totalScore,
    required this.stats,
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

    final allCountryStats = _extractCountryStats();
    final int discoveredCount = allCountryStats.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profil Başlık Kartı (Avatar, İsim, Toplam Puan)
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // 2. 4'lü Özet İstatistik Kartları (KPI)
          _buildQuickKpiGrid(
            totalCorrect: totalCorrect,
            totalWrong: totalWrong,
            overallAccuracy: overallAccuracy,
            discoveredCount: discoveredCount,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 3. Sekme Seçici (Oyun Modları & Ülke Analizi)
          _buildTabSelector(discoveredCount, isDark),
          const SizedBox(height: 18),

          // 4. Seçili Sekme İçeriği
          if (_selectedTabIndex == 0)
            _buildDetailedStatsCard(isDark)
          else
            _buildCountryAnalysisTab(allCountryStats, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, const Color(0xFF0F3D35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'profile_avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.tealAccent, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: widget.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.avatarUrl)
                      : null,
                  backgroundColor: Colors.teal.shade800,
                  child: widget.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white70)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name.trim().isNotEmpty
                        ? widget.name
                        : Localization.t('settings.guest'),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _buildTotalScoreBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech_rounded,
              color: Colors.amberAccent, size: 18),
          const SizedBox(width: 6),
          Text(
            '${widget.totalScore} ${Localization.t('leaderboard.score')}',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickKpiGrid({
    required int totalCorrect,
    required int totalWrong,
    required double overallAccuracy,
    required int discoveredCount,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.total_correct'),
            value: totalCorrect.toString(),
            icon: Icons.check_circle_rounded,
            color: Colors.greenAccent.shade400,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.total_wrong'),
            value: totalWrong.toString(),
            icon: Icons.cancel_rounded,
            color: Colors.redAccent.shade200,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.accuracy'),
            value: '%${overallAccuracy.toStringAsFixed(1)}',
            icon: Icons.pie_chart_rounded,
            color: Colors.tealAccent.shade400,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: Localization.t('profile.discovered_countries'),
            value: '$discoveredCount',
            icon: Icons.public_rounded,
            color: Colors.amberAccent.shade400,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: isDark ? 0.2 : 0.3),
        ),
      ),
      color: isDark ? const Color(0xFF162321) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
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
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(int discoveredCount, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142220) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
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
              title: '${Localization.t('profile.tab_countries')} ($discoveredCount)',
              isSelected: _selectedTabIndex == 1,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_selectedTabIndex != index) {
          setState(() => _selectedTabIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.teal
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
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
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

  Widget _buildDetailedStatsCard(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: isDark ? const Color(0xFF162321) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.t('profile.stats_title'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.blueGrey.shade900,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 22),
            ...GameType.values.map((type) {
              final isLast = type == GameType.values.last;
              final prefix = AppState.getGameModeKey(type);

              return Column(
                children: [
                  _buildSection(prefix, type.icon, type.color, isDark),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Divider(
                        color: isDark ? Colors.white10 : Colors.black12,
                        height: 1,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  Localization.t('profile.$prefix'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              score.toString(),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: successRate,
            backgroundColor: isDark ? Colors.black26 : Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSmallStat(
                Localization.t('profile.correct_label', args: [correct]),
                Colors.green.shade400),
            _buildSmallStat(
                Localization.t('profile.wrong_label', args: [wrong]),
                Colors.red.shade400),
            _buildSmallStat('${(successRate * 100).toStringAsFixed(1)}%',
                isDark ? Colors.white54 : Colors.blueGrey),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryAnalysisTab(
      List<_CountryStatItem> allCountryStats, bool isDark) {
    if (allCountryStats.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: isDark ? const Color(0xFF162321) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.public_off_rounded,
                  size: 54, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                Localization.t('profile.no_country_stats'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 1. En Başarılı 5 Ülke (Top Mastered)
    final topMastered = List<_CountryStatItem>.from(allCountryStats)
      ..sort((a, b) {
        final scoreComp = b.score.compareTo(a.score);
        if (scoreComp != 0) return scoreComp;
        return b.correct.compareTo(a.correct);
      });
    final top5 = topMastered.take(5).toList();

    // 2. Geliştirilmesi Gereken 5 Ülke (En çok hata yapılanlar)
    final needsPracticeList = allCountryStats.where((c) => c.wrong > 0).toList()
      ..sort((a, b) {
        final wrongComp = b.wrong.compareTo(a.wrong);
        if (wrongComp != 0) return wrongComp;
        return a.accuracy.compareTo(b.accuracy);
      });
    final weak5 = needsPracticeList.take(5).toList();

    // 3. Arama ve Sıralama Filtresi
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
        // En Başarılı Ülkeler Kartı
        if (top5.isNotEmpty) ...[
          _buildHighlightCountrySection(
            title: Localization.t('profile.top_countries'),
            icon: Icons.emoji_events_rounded,
            iconColor: Colors.amberAccent,
            items: top5,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
        ],

        // Geliştirilmesi Gereken Ülkeler Kartı
        if (weak5.isNotEmpty) ...[
          _buildHighlightCountrySection(
            title: Localization.t('profile.weak_countries'),
            icon: Icons.trending_down_rounded,
            iconColor: Colors.deepOrangeAccent,
            items: weak5,
            isDark: isDark,
            isWeakSection: true,
          ),
          const SizedBox(height: 16),
        ],

        // Tüm Ülkeler Başlığı & Arama / Sıralama Kartı
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: isDark ? const Color(0xFF162321) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Localization.t('profile.all_countries')} (${filteredList.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Arama Kutusu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Localization.t('profile.search_country'),
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
                    fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),

                // Sıralama Butonları
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('score', Localization.t('leaderboard.score')),
                      const SizedBox(width: 6),
                      _buildSortChip(
                          'correct', Localization.t('profile.total_correct')),
                      const SizedBox(width: 6),
                      _buildSortChip(
                          'wrong', Localization.t('profile.total_wrong')),
                      const SizedBox(width: 6),
                      _buildSortChip('name', 'A-Z'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Ülke Listesi
                if (filteredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'Eşleşen ülke bulunamadı.',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                      color: isDark ? Colors.white10 : Colors.black12,
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
      ],
    );
  }

  Widget _buildHighlightCountrySection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_CountryStatItem> items,
    required bool isDark,
    bool isWeakSection = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF162321) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                    width: 130,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal.shade900.withValues(alpha: 0.25)
                          : Colors.teal.shade50.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isWeakSection
                            ? Colors.redAccent.withValues(alpha: 0.3)
                            : Colors.teal.withValues(alpha: 0.3),
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
                            fontWeight: FontWeight.w700,
                            color: isWeakSection
                                ? Colors.redAccent
                                : Colors.teal,
                          ),
                        ),
                        Text(
                          '%${c.accuracy.toStringAsFixed(0)} ${Localization.t('profile.accuracy')}',
                          style: TextStyle(
                            fontSize: 10.5,
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
    );
  }

  Widget _buildSortChip(String type, String label) {
    final isSelected = _sortType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _sortType = type);
      },
    );
  }

  Widget _buildCountryTile(_CountryStatItem item, bool isDark) {
    final accuracyColor = item.accuracy >= 80
        ? Colors.greenAccent.shade400
        : (item.accuracy >= 50 ? Colors.amberAccent.shade400 : Colors.redAccent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // Bayrak
          Container(
            width: 36,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            child: Text(
              item.flagEmoji.isNotEmpty ? item.flagEmoji : '🌐',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Ülke Adı ve Doğru/Yanlış
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${item.correct} D',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.wrong} Y',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '%${item.accuracy.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
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
              color: Colors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '${item.score} P',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
