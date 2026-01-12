import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game/guess_result.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/custom_notification.dart';

class DistanceGameController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<GuessResultModel> guesses = [];

  List<Color> getBackgroundColors() {
    return AppState.settings.darkTheme
        ? [const Color(0xFF0D47A1), const Color(0xFF000000)]
        : [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)];
  }

  Color get cardBg =>
      AppState.settings.darkTheme ? const Color(0xFF1E2746) : Colors.white;

  Color get textColor =>
      AppState.settings.darkTheme ? Colors.white : Colors.black87;

  Color get accentColor => Colors.blueAccent;

  bool get isDark => AppState.settings.darkTheme;

  Future<void> initializeGame() async {
    await GameService.initializeGame(GameType.distance);
  }

  Future<GuessResultModel?> checkAnswer() async {
    String inputText = textController.text.trim();
    if (inputText.isEmpty) return null;

    GuessResultModel? result =
        await GameService.processDistanceGuess(inputText);
    textController.clear();
    return result;
  }

  void addGuess(GuessResultModel result) {
    if (result.isCorrect) {
      guesses.clear();
    } else {
      guesses.insert(0, result);
    }
  }

  void clearGuesses() {
    guesses.clear();
  }

  Future<String> handlePass() async {
    String passCountry = await GameService.handlePass();
    textController.clear();
    guesses.clear();
    return passCountry;
  }

  void showPassDialog(BuildContext context, String passCountry) {
    showDialog(
      context: context,
      builder: (context) => CustomNotification(
        baslik: Localization.t('game_common.passed_msg', args: [""]),
        metin: passCountry,
      ),
    );
  }

  void showWinDialog(BuildContext context, String countryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(Localization.t('game_common.congratulations')),
          ],
        ),
        content: Text(
            Localization.t('game_common.correct_msg', args: [countryName])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Localization.t('common.ok'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  void showNotFoundSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Localization.t('game_common.not_found')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Widget> getRules() {
    return [
      _buildRuleItem(
          Icons.save, Localization.t('game_common.save_points_warning')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.map, Localization.t('game_distance.rule_welcome')),
      const SizedBox(height: 10),
      _buildRuleItem(
          Icons.straighten, Localization.t('game_distance.rule_score')),
    ];
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void dispose() {
    textController.dispose();
    scrollController.dispose();
  }
}
