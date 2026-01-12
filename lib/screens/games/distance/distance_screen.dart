import 'package:flutter/material.dart';

import 'package:geogame/widgets/distance_widgets.dart';
import 'package:geogame/widgets/game_widgets.dart';
import 'package:geogame/services/localization_service.dart';

import 'distance_controller.dart';

class DistanceGame extends StatefulWidget {
  const DistanceGame({super.key});

  @override
  State<DistanceGame> createState() => _DistanceGameState();
}

class _DistanceGameState extends State<DistanceGame> {
  final DistanceGameController _controller = DistanceGameController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGameRulesDialog(context: context, rules: _controller.getRules());
    });
  }

  Future<void> _checkAnswer() async {
    final result = await _controller.checkAnswer();
    if (!mounted) return;

    if (result == null) {
      _controller.showNotFoundSnackBar(context);
      return;
    }

    setState(() {
      _controller.addGuess(result);
      if (result.isCorrect) {
        _controller.showWinDialog(context, result.countryName);
      }
    });
  }

  Future<void> _handlePass() async {
    String passCountry = await _controller.handlePass();
    if (!mounted) return;
    _controller.showPassDialog(context, passCountry);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: Localization.t('game_distance.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: Column(
        children: [
          // Input dashboard
          DistanceInputDashboard(
            controller: _controller,
            onAnswerSubmit: _checkAnswer,
            onPass: _handlePass,
            onClearGuesses: () => setState(() => _controller.clearGuesses()),
          ),

          // Tahmin listesi
          Expanded(
            child: _controller.guesses.isEmpty
                ? DistanceEmptyState(isDark: _controller.isDark)
                : ListView.builder(
                    controller: _controller.scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: _controller.guesses.length,
                    itemBuilder: (context, index) {
                      final guess = _controller.guesses[index];
                      return DistanceGuessCard(
                        guess: guess,
                        cardBg: _controller.cardBg,
                        textColor: _controller.textColor,
                        isFirst: index == 0,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
