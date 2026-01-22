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
    if (mounted) setState(() {});
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
      builder: (context) => BorderPathVictoryDialog(
        score: score,
        performance: performance,
        movesCount: _controller.movesCount,
        optimalPathLength: _controller.optimalPathLength,
        performanceColor: _controller.getPerformanceColor(),
        onMainMenu: () {
          Navigator.of(context).pop();
          _controller.navigateHome(context);
        },
        onNewGame: () {
          Navigator.of(context).pop();
          _startNextRound(passMode: true);
        },
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
