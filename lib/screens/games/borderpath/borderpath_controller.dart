import 'dart:math';
import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game/border_path_data.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/geojson_service.dart';
import 'package:geogame/services/localization_service.dart';

class BorderPathGameController {
  final TextEditingController textController = TextEditingController();

  Country? startCountry;
  Country? targetCountry;
  List<Country> currentPath = [];
  List<Country> availableNeighbors = [];
  int movesCount = 0;
  int optimalPathLength = 0;
  bool gameWon = false;

  Map<String, Path> countryPaths = {};
  bool isLoadingMaps = true;

  List<Color> getBackgroundColors() {
    return AppState.settings.darkTheme
        ? [const Color(0xFF1A237E), Colors.black]
        : [const Color(0xFFE8EAF6), const Color(0xFF9FA8DA)];
  }

  Color get cardBg => AppState.settings.darkTheme
      ? const Color(0xFF283593).withValues(alpha: 0.5)
      : Colors.white;

  Color get textColor =>
      AppState.settings.darkTheme ? Colors.white : Colors.black87;

  bool get isDark => AppState.settings.darkTheme;
  bool get isButtonMode => AppState.filter.isButtonMode;

  Future<void> initializeGame() async {
    isLoadingMaps = true;
    GameService.initializeGame(GameType.borderpath);
    final data = GameService.createBorderPathGame();
    await loadLevel(data);
  }

  Future<void> loadLevel(BorderPathGameData? gameData) async {
    if (gameData == null) {
      debugPrint("⚠️ Oyun verisi oluşturulamadı!");
      isLoadingMaps = false;
      return;
    }

    isLoadingMaps = true;
    countryPaths = {};
    availableNeighbors = [];

    startCountry = gameData.startCountry;
    targetCountry = gameData.targetCountry;
    optimalPathLength = gameData.optimalPathLength;

    currentPath = [startCountry!];
    movesCount = 0;
    gameWon = false;

    final List<Path?> results = await Future.wait([
      GeoJsonService.loadCountryPathSimplified(startCountry!.iso3),
      GeoJsonService.loadCountryPathSimplified(targetCountry!.iso3),
    ]);

    final newPaths = Map<String, Path>.from(countryPaths);
    if (results[0] != null) newPaths[startCountry!.iso3] = results[0]!;
    if (results[1] != null) newPaths[targetCountry!.iso3] = results[1]!;
    countryPaths = newPaths;

    updateAvailableNeighbors();
    isLoadingMaps = false;
  }

  Future<void> startNextRound({bool passMode = false}) async {
    isLoadingMaps = true;
    if (passMode) AppState.session.submitPass();
    final data = GameService.createBorderPathGame();
    await loadLevel(data);
  }

  Future<void> loadCountryPath(Country country) async {
    if (countryPaths.containsKey(country.iso3)) return;

    final path = await GeoJsonService.loadCountryPathSimplified(country.iso3);
    if (path != null) {
      final newPaths = Map<String, Path>.from(countryPaths);
      newPaths[country.iso3] = path;
      countryPaths = newPaths;
    }
  }

  void updateAvailableNeighbors() {
    if (currentPath.isEmpty) return;

    availableNeighbors = GameService.getAvailableNeighbors(currentPath);

    for (Country neighbor in availableNeighbors) {
      loadCountryPath(neighbor);
    }
  }

  bool selectCountry(Country country) {
    if (gameWon) return false;

    currentPath = [...currentPath, country];
    movesCount++;

    if (country.iso3 == targetCountry!.iso3) {
      gameWon = true;
      return true;
    } else {
      updateAvailableNeighbors();
      textController.clear();
      return false;
    }
  }

  void undoLastMove() {
    if (currentPath.length <= 1 || gameWon) return;

    final newPath = List<Country>.from(currentPath);
    newPath.removeLast();
    currentPath = newPath;

    movesCount = max(0, movesCount - 1);
    updateAvailableNeighbors();
    textController.clear();
  }

  void completeGame() {
    GameService.completeBorderPathGame(movesCount, optimalPathLength);
  }

  int getScore() {
    int wrongCount = (movesCount - optimalPathLength).clamp(0, 1000);
    return (100 - wrongCount * 10).clamp(20, 100);
  }

  String getPerformanceText() {
    int score = AppState.session.totalScore;
    if (score == 100) return Localization.t('game_borderpath.perf_perfect');
    if (score >= 80) return Localization.t('game_borderpath.perf_great');
    if (score >= 60) return Localization.t('game_borderpath.perf_good');
    return Localization.t('game_borderpath.perf_try_harder');
  }

  Color getPerformanceColor() {
    int score = AppState.session.totalScore;
    if (score == 100) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.grey;
  }

  List<Widget> getRules() {
    return [
      _buildRuleItem(Icons.flag, Localization.t('game_borderpath.rule_1')),
      const SizedBox(height: 10),
      _buildRuleItem(
          Icons.swap_horiz, Localization.t('game_borderpath.rule_2')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.route, Localization.t('game_borderpath.rule_3')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.map, Localization.t('game_borderpath.rule_4')),
    ];
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void navigateHome(BuildContext context) {
    GameLogService.syncPendingLogs();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void dispose() {
    textController.dispose();
  }
}
