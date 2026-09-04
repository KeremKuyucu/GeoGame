import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/custom_notification.dart';

class CapitalGameController {
  final TextEditingController textController = TextEditingController();

  List<Color> getBackgroundColors() {
    return SettingsController.settings.darkTheme
        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
        : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)];
  }

  Color get cardBg => SettingsController.settings.darkTheme
      ? const Color(0xFF252538)
      : Colors.white;

  Color get textColor =>
      SettingsController.settings.darkTheme ? Colors.white : Colors.black87;

  Color get accentColor => const Color(0xFF673AB7);

  String get targetCapital => AppState.targetCountry.capital;

  bool get isButtonMode => SettingsController.gameFilter.isButtonMode;
  bool get isDark => SettingsController.settings.darkTheme;

  Future<void> initializeGame() async {
    await GameService.initializeGame(GameType.capital);
  }

  Future<bool> checkAnswer(int index) async {
    String answer = textController.text;
    if (SettingsController.gameFilter.isButtonMode && index < 4) {
      answer = GameService.buttonAt(index).label;
    }

    final isCorrect =
        await GameService.checkStandardAnswer(answer, GameType.capital, index);
    textController.clear();
    return isCorrect;
  }

  Future<String> handlePass() async {
    final passCountry = await GameService.handlePass();
    textController.clear();
    return passCountry;
  }

  void showPassDialog(BuildContext context, String passCountry) {
    showDialog(
      context: context,
      builder: (context) => CustomNotification(
        baslik: Localization.t('game_common.passed_msg'),
        metin: passCountry,
      ),
    );
  }

  List<Widget> getRules() {
    return [
      _buildRuleItem(
          Icons.save, Localization.t('game_common.save_points_warning')),
      const SizedBox(height: 10),
      _buildRuleItem(
          Icons.info_outline, Localization.t('game_capital.rule_welcome')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.star_border,
          Localization.t('game_common.score_system_generic')),
    ];
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void dispose() {
    textController.dispose();
  }
}
