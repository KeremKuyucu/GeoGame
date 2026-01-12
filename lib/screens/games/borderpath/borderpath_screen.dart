import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/borderpath_widgets.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'borderpath_controller.dart';

class BorderPathGame extends StatefulWidget {
  const BorderPathGame({super.key});

  @override
  State<BorderPathGame> createState() => _BorderPathGameState();
}

class _BorderPathGameState extends State<BorderPathGame> {
  final BorderPathGameController _controller = BorderPathGameController();

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

  Future<void> _initializeGame() async {
    await _controller.initializeGame();
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameRulesDialog(context: context, rules: _controller.getRules());
      });
    }
  }

  void _selectCountry(Country country) {
    final won = _controller.selectCountry(country);
    setState(() {});
    if (won) {
      _showVictoryDialog();
    }
  }

  void _undoLastMove() {
    _controller.undoLastMove();
    setState(() {});
  }

  Future<void> _startNextRound({bool passMode = false}) async {
    await _controller.startNextRound(passMode: passMode);
    if (mounted) setState(() {});
  }

  void _showVictoryDialog() {
    _controller.completeGame();
    int score = _controller.getScore();
    String performance = _controller.getPerformanceText();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
            const SizedBox(width: 10),
            Text(Localization.t('game_common.congratulations')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localization.t('game_borderpath.victory_msg'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatRow(Localization.t('game_borderpath.stat_moves'),
                "${_controller.movesCount}"),
            _buildStatRow(Localization.t('game_borderpath.stat_optimal'),
                "${_controller.optimalPathLength}"),
            _buildStatRow(Localization.t('game_common.score'), "$score"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _controller.getPerformanceColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                performance,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _controller.getPerformanceColor(),
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
              Navigator.of(context).pop();
              _controller.navigateHome(context);
            },
            child: Text(Localization.t('game_common.main_menu')),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_controller.startCountry == null || _controller.targetCountry == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GameScaffold(
      title: Localization.t('game_borderpath.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BorderPathStartEndCard(controller: _controller),
            const SizedBox(height: 20),
            BorderPathMapArea(controller: _controller),
            const SizedBox(height: 20),
            BorderPathCurrentPath(controller: _controller),
            const SizedBox(height: 20),
            if (!_controller.gameWon)
              BorderPathNeighborsSection(
                controller: _controller,
                onCountrySelected: _selectCountry,
              ),
            const SizedBox(height: 20),
            if (_controller.currentPath.length > 1 && !_controller.gameWon)
              ElevatedButton.icon(
                onPressed: _undoLastMove,
                icon: const Icon(Icons.undo),
                label: Text(Localization.t('game_borderpath.undo_move')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
