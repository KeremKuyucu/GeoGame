// lib/screens/games/borderpath/borderpath_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class BorderPathGame extends StatefulWidget {
  const BorderPathGame({super.key});

  @override
  State<BorderPathGame> createState() => _BorderPathGameState();
}

class _BorderPathGameState extends State<BorderPathGame> {
  final TextEditingController _controller = TextEditingController();

  // Oyun değişkenleri
  Country? startCountry;
  Country? targetCountry;
  List<Country> currentPath = [];
  List<Country> availableNeighbors = [];
  int movesCount = 0;
  int optimalPathLength = 0;
  bool gameWon = false;

  // Harita için
  Map<String, Path> countryPaths = {};
  bool isLoadingMaps = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLevel(BorderPathGameData? gameData) async {
    if (!mounted) return;

    if (gameData == null) {
      debugPrint("⚠️ Oyun verisi oluşturulamadı!");
      setState(() => isLoadingMaps = false);
      return;
    }

    // 1. Önce değişkenleri sıfırla ve loading'i aç
    setState(() {
      isLoadingMaps = true;
      countryPaths = {}; // Yeni referans
      availableNeighbors = [];

      startCountry = gameData.startCountry;
      targetCountry = gameData.targetCountry;
      optimalPathLength = gameData.optimalPathLength;

      currentPath = [startCountry!];
      movesCount = 0;
      gameWon = false;
    });

    // 2. İki ülkeyi de PARALEL (aynı anda) yükle ve bekle
    final List<Path?> results = await Future.wait([
      _loadAndParseGeoJson(startCountry!.iso3),
      _loadAndParseGeoJson(targetCountry!.iso3),
    ]);

    if (!mounted) return;

    // 3. İkisi de hazır olduğunda TEK SEFERDE state güncelle
    setState(() {
      final newPaths = Map<String, Path>.from(countryPaths);
      if (results[0] != null) newPaths[startCountry!.iso3] = results[0]!;
      if (results[1] != null) newPaths[targetCountry!.iso3] = results[1]!;
      countryPaths = newPaths;

      _updateAvailableNeighbors();

      isLoadingMaps = false;
    });
  }

  Future<void> _initializeGame() async {
    setState(() => isLoadingMaps = true);

    GameService.initializeGame(GameType.borderpath);
    final data = GameService.createBorderPathGame();

    await _loadLevel(data);

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRulesDialog();
      });
    }
  }

  Future<void> _startNextRound({bool passMode = false}) async {
    setState(() => isLoadingMaps = true);

    if (passMode) AppState.session.submitPass();
    final data = GameService.createBorderPathGame();

    await _loadLevel(data);
  }

  Future<void> _loadCountryPath(Country country) async {
    if (countryPaths.containsKey(country.iso3)) return;

    final path = await _loadAndParseGeoJson(country.iso3);
    if (path != null) {
      if (!mounted) return;
      setState(() {
        // shouldRepaint tetiklensin diye yeni map oluşturuyoruz
        final newPaths = Map<String, Path>.from(countryPaths);
        newPaths[country.iso3] = path;
        countryPaths = newPaths;
      });
    }
  }

  /// GeoJSON dosyasını okuyup Flutter Path nesnesine çeviren fonksiyon
  Future<Path?> _loadAndParseGeoJson(String isoCode) async {
    Path path = Path();

    // 1. Yerelden dene
    try {
      final String jsonString =
      await rootBundle.loadString('assets/geojson/${isoCode.toLowerCase()}.geo.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      _parseGeoJsonToPath(jsonData, path);
      return path;
    } catch (e) {
      debugPrint("Local GeoJSON upload error ($isoCode): $e");
    }

    // 2. Network fallback
    try {
      final Uri url = Uri.parse(
          'https://raw.githubusercontent.com/mledoze/countries/master/data/${isoCode.toLowerCase()}.geo.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        _parseGeoJsonToPath(jsonData, path);
        return path;
      } else {
        debugPrint("GeoJSON network hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("GeoJSON Network Hatası ($isoCode): $e");
    }

    return null;
  }

  /// GeoJSON yapısını ayrıştırır
  void _parseGeoJsonToPath(Map<String, dynamic> json, Path path) {
    if (json.isEmpty || json['type'] == null) return;

    final String type = json['type'];

    switch (type) {
      case 'FeatureCollection':
        final features = json['features'] as List<dynamic>? ?? [];
        for (var feature in features) {
          if (feature is Map<String, dynamic>) {
            _parseGeoJsonToPath(feature, path);
          }
        }
        break;
      case 'Feature':
        final geometry = json['geometry'] as Map<String, dynamic>?;
        if (geometry != null) _parseGeoJsonToPath(geometry, path);
        break;
      case 'Polygon':
        final coordinates = json['coordinates'] as List<dynamic>? ?? [];
        _addPolygonToPath(path, coordinates);
        break;
      case 'MultiPolygon':
        final polygons = json['coordinates'] as List<dynamic>? ?? [];
        for (var polygon in polygons) {
          _addPolygonToPath(path, polygon as List<dynamic>);
        }
        break;
      default:
        debugPrint("Bilinmeyen GeoJSON tipi: $type");
    }
  }

  /// Koordinat listesini Path'e ekleyen yardımcı metod
  void _addPolygonToPath(Path path, List polygonCoords) {
    for (var ring in polygonCoords) {
      if (ring.isEmpty) continue;

      if (ring.length < 5) continue;

      final start = ring[0] as List<dynamic>;
      double startX = (start[0] as num).toDouble();
      double startY = -(start[1] as num).toDouble();
      path.moveTo(startX, startY);

      for (int i = 1; i < ring.length; i++) {
        if (ring.length > 100 && i % 2 != 0) continue;

        final point = ring[i] as List<dynamic>;
        double x = (point[0] as num).toDouble();
        double y = -(point[1] as num).toDouble();
        path.lineTo(x, y);
      }
      path.close();
    }
  }

  void _updateAvailableNeighbors() {
    if (currentPath.isEmpty) return;

    Country lastCountry = currentPath.last;
    availableNeighbors = [];

    for (String borderIso3 in lastCountry.borders) {
      Country? neighbor = AppState.allCountries
          .where((c) => c.iso3 == borderIso3)
          .firstOrNull;

      if (neighbor != null && !currentPath.contains(neighbor)) {
        availableNeighbors.add(neighbor);
        _loadCountryPath(neighbor);
      }
    }

    availableNeighbors.sort((a, b) => a
        .getLocalizedName(Localization.currentLanguage)
        .compareTo(b.getLocalizedName(Localization.currentLanguage)));
  }

  void _selectCountry(Country country) {
    if (gameWon) return;

    setState(() {
      currentPath = [...currentPath, country];
      movesCount++;

      if (country.iso3 == targetCountry!.iso3) {
        gameWon = true;
        _showVictoryDialog();
      } else {
        _updateAvailableNeighbors();
        _controller.clear();
      }
    });
  }

  void _undoLastMove() {
    if (currentPath.length <= 1 || gameWon) return;

    setState(() {
      final newPath = List<Country>.from(currentPath);
      newPath.removeLast();
      currentPath = newPath;

      movesCount = max(0, movesCount - 1);
      _updateAvailableNeighbors();
      _controller.clear();
    });
  }

  // --- Helpers for Keyboard Mode ---
  Future<Widget> _loadOptionFlag(String iso2, String flagUrl) async {
    try {
      return ClipOval(
        child: Image.network(
          flagUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.flag, color: Colors.grey),
        ),
      );
    } catch (e) {
      return const Icon(Icons.flag, color: Colors.grey);
    }
  }
  // ---------------------------------

  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(Localization.t('game_common.rules')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRuleItem(Icons.flag,
                  Localization.t('game_borderpath.rule_1')),
              const SizedBox(height: 10),
              _buildRuleItem(Icons.swap_horiz,
                  Localization.t('game_borderpath.rule_2')),
              const SizedBox(height: 10),
              _buildRuleItem(Icons.route,
                  Localization.t('game_borderpath.rule_3')),
              const SizedBox(height: 10),
              _buildRuleItem(Icons.map,
                  Localization.t('game_borderpath.rule_4')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              Localization.t('common.ok'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    GameService.completeBorderPathGame(movesCount, optimalPathLength);
    int wrongCount = (movesCount - optimalPathLength).clamp(0, 1000);
    int score = (100 - wrongCount * 10).clamp(20, 100);
    String performance = _getPerformanceText();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 30),
            const SizedBox(width: 10),
            Text(Localization.t('game_common.congratulations')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localization.t('game_borderpath.victory_msg'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatRow(Localization.t('game_borderpath.stat_moves'), "$movesCount"),
            _buildStatRow(Localization.t('game_borderpath.stat_optimal'), "$optimalPathLength"),
            _buildStatRow(Localization.t('game_common.score'), "$score"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPerformanceColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                performance,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getPerformanceColor(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNextRound(passMode: true);
            },
            child: Text(Localization.t('game_common.new_game')),
          ),
          TextButton(
            onPressed: () {
              GameLogService.syncPendingLogs();
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            },
            child: Text(Localization.t('game_common.main_menu')),
          ),
        ],
      ),
    );
  }

  String _getPerformanceText() {
    int score = AppState.session.totalScore;
    if (score == 100) return Localization.t('game_borderpath.perf_perfect');
    if (score >= 80) return Localization.t('game_borderpath.perf_great');
    if (score >= 60) return Localization.t('game_borderpath.perf_good');
    return Localization.t('game_borderpath.perf_try_harder');
  }

  Color _getPerformanceColor() {
    int score = AppState.session.totalScore;
    if (score == 100) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (startCountry == null || targetCountry == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isDark = AppState.settings.darkTheme;
    final Color bgStart = isDark ? const Color(0xFF1A237E) : const Color(0xFFE8EAF6);
    final Color bgEnd = isDark ? Colors.black : const Color(0xFF9FA8DA);
    final Color cardBg = isDark
        ? const Color(0xFF283593).withValues(alpha: 0.5)
        : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('game_borderpath.title'),
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _startNextRound,
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              GameLogService.syncPendingLogs();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStartEndCard(cardBg, textColor),
                const SizedBox(height: 20),
                _buildMapArea(cardBg, textColor, isDark),
                const SizedBox(height: 20),
                _buildPathCard(cardBg, textColor),
                const SizedBox(height: 20),
                if (!gameWon) _buildNeighborsSection(cardBg, textColor),
                const SizedBox(height: 20),
                if (currentPath.length > 1 && !gameWon)
                  ElevatedButton.icon(
                    onPressed: _undoLastMove,
                    icon: const Icon(Icons.undo),
                    label: Text(Localization.t('game_borderpath.undo_move')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapArea(Color cardBg, Color textColor, bool isDark) {
    return Container(
      // EKRANIN %45'İ KADAR YÜKSEKLİK (Daha büyük alan)
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.indigo.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: isLoadingMaps
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: isDark ? Colors.white : Colors.indigo,
              ),
              const SizedBox(height: 10),
              Text(
                Localization.t('game_borderpath.loading_map'),
                style: TextStyle(color: textColor.withValues(alpha: 0.7)),
              ),
            ],
          ),
        )
            : InteractiveViewer( // <--- ZOOM ve PAN ÖZELLİĞİ EKLENDİ
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: PathMapPainter(
                paths: countryPaths,
                currentPath: currentPath,
                targetCountry: targetCountry!,
                isDark: isDark,
              ),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartEndCard(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCountryInfo(
                  Localization.t('game_borderpath.label_start'),
                  startCountry!,
                  Colors.green,
                  textColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward,
                  color: textColor.withValues(alpha: 0.5),
                  size: 30,
                ),
              ),
              Expanded(
                child: _buildCountryInfo(
                  Localization.t('game_borderpath.label_target'),
                  targetCountry!,
                  Colors.red,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Localization.t('game_borderpath.label_moves'), "$movesCount", Icons.numbers),
                _buildInfoChip(Localization.t('game_borderpath.label_optimal'), "$optimalPathLength", Icons.route),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryInfo(String label, Country country, Color color, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          country.getLocalizedName(Localization.currentLanguage),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 5),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPathCard(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.indigo),
              const SizedBox(width: 10),
              Text(
                Localization.t('game_borderpath.current_path'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentPath.asMap().entries.map((entry) {
              int index = entry.key;
              Country country = entry.value;
              bool isStart = index == 0;
              bool isEnd = country.iso3 == targetCountry!.iso3;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isEnd
                      ? Colors.red.withValues(alpha: 0.2)
                      : isStart
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isEnd
                        ? Colors.red
                        : isStart
                        ? Colors.green
                        : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${index + 1}.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      country.getLocalizedName(Localization.currentLanguage),
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNeighborsSection(Color cardBg, Color textColor) {
    final bool isButtonMode = AppState.filter.isButtonMode;

    if (!isButtonMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              Localization.t('game_borderpath.neighbors_label'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          _buildKeyboardModeUI(context, cardBg, textColor, Colors.indigo),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: Colors.indigo),
              const SizedBox(width: 10),
              Text(
                "${Localization.t('game_borderpath.neighbors_label')} (${availableNeighbors.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (availableNeighbors.isEmpty)
            Center(
              child: Text(
                Localization.t('game_borderpath.no_neighbors_left'),
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableNeighbors.map((country) {
                bool isTarget = country.iso3 == targetCountry!.iso3;
                return ElevatedButton(
                  onPressed: () => _selectCountry(country),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTarget ? Colors.red : Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTarget)
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(Icons.flag, size: 16),
                        ),
                      Text(
                        country.getLocalizedName(Localization.currentLanguage),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyboardModeUI(BuildContext context, Color cardBg, Color textColor, Color accentColor) {
    final bool isDark = AppState.settings.darkTheme;

    return LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<Country>(
            displayStringForOption: (Country option) =>
                option.getLocalizedName(Localization.currentLanguage),

            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Country>.empty();
              }
              return AppState.allCountries.where((Country ulke) {
                final String currentName = ulke.getLocalizedName(Localization.currentLanguage);
                return currentName.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },

            onSelected: (Country secilenUlke) {
              _controller.text = secilenUlke.getLocalizedName(Localization.currentLanguage);
              FocusScope.of(context).unfocus();

              bool isNeighbor = availableNeighbors.any((c) => c.iso3 == secilenUlke.iso3);

              if (isNeighbor) {
                _selectCountry(secilenUlke);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.clear();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${secilenUlke.getLocalizedName(Localization.currentLanguage)} ${Localization.t('game_borderpath.not_a_neighbor')}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
                _controller.clear();
              }
            },

            fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
              if (_controller.text.isEmpty && fieldTextEditingController.text.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  fieldTextEditingController.clear();
                });
              }
              return Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    hintText: Localization.t('game_common.input_hint'),
                    hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: accentColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              );
            },

            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                      itemBuilder: (BuildContext context, int index) {
                        final Country option = options.elementAt(index);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                            child: FutureBuilder<Widget>(
                              future: _loadOptionFlag(option.iso2, option.flagUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                } else if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else {
                                  return const Icon(Icons.flag);
                                }
                              },
                            ),
                          ),
                          title: Text(
                            option.getLocalizedName(Localization.currentLanguage),
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }
}

class PathMapPainter extends CustomPainter {
  final Map<String, Path> paths;
  final List<Country> currentPath;
  final Country targetCountry;
  final bool isDark;

  PathMapPainter({
    required this.paths,
    required this.currentPath,
    required this.targetCountry,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    Rect? combinedBounds;
    for (var path in paths.values) {
      final bounds = path.getBounds();
      if (bounds.isEmpty) continue;

      if (combinedBounds == null) {
        combinedBounds = bounds;
      } else {
        combinedBounds = Rect.fromLTRB(
          min(combinedBounds.left, bounds.left),
          min(combinedBounds.top, bounds.top),
          max(combinedBounds.right, bounds.right),
          max(combinedBounds.bottom, bounds.bottom),
        );
      }
    }

    if (combinedBounds == null || combinedBounds.isEmpty) return;

    final double scaleX = size.width / combinedBounds.width;
    final double scaleY = size.height / combinedBounds.height;
    final double scale = min(scaleX, scaleY) * 0.9;

    final double offsetX = (size.width - (combinedBounds.width * scale)) / 2;
    final double offsetY = (size.height - (combinedBounds.height * scale)) / 2;

    final Matrix4 matrix = Matrix4.identity();
    matrix.translate(offsetX, offsetY);
    matrix.scale(scale, scale);
    matrix.translate(-combinedBounds.left, -combinedBounds.top);

    // 1. Hedef ülke (Hayalet)
    if (paths.containsKey(targetCountry.iso3) &&
        (currentPath.isEmpty || currentPath.last.iso3 != targetCountry.iso3)) {
      final tPath = paths[targetCountry.iso3]!;
      final transformedTarget = tPath.transform(matrix.storage);

      final Paint targetGhostFill = Paint()
        ..color = Colors.red.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      final Paint targetGhostStroke = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(transformedTarget, targetGhostFill);
      canvas.drawPath(transformedTarget, targetGhostStroke);
    }

    // 2. Mevcut Yol
    for (int i = 0; i < currentPath.length; i++) {
      final country = currentPath[i];
      final path = paths[country.iso3];
      if (path == null) continue;

      final transformedPath = path.transform(matrix.storage);

      Color fillColor;
      Color strokeColor;

      if (i == 0) {
        fillColor = Colors.green.withValues(alpha: 0.6);
        strokeColor = Colors.green.shade700;
      } else if (country.iso3 == targetCountry.iso3) {
        fillColor = Colors.red.withValues(alpha: 0.6);
        strokeColor = Colors.red.shade700;
      } else {
        fillColor = Colors.blue.withValues(alpha: 0.5);
        strokeColor = Colors.blue.shade700;
      }

      canvas.drawShadow(transformedPath, Colors.black, 3.0, true);

      final Paint fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(transformedPath, fillPaint);

      final Paint strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(transformedPath, strokePaint);

      if (i >= 0) {
        final center = transformedPath.getBounds().center;
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - textPainter.width / 2,
            center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathMapPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.targetCountry != targetCountry;
  }
}