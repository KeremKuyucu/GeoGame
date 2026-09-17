import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/custom_notification.dart';

class CoatOfArmsGameController {
  final TextEditingController textController = TextEditingController();

  List<Color> getBackgroundColors() {
    return SettingsController.settings.darkTheme
        ? [const Color(0xFF311B92), const Color(0xFF12005E)]
        : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)];
  }

  Color get cardBg => SettingsController.settings.darkTheme
      ? const Color(0xFF1F1A30)
      : Colors.white;

  Color get textColor =>
      SettingsController.settings.darkTheme ? Colors.white : Colors.black87;

  Color get accentColor => const Color(0xFF7B1FA2);

  String get targetCoatOfArmsUrl => AppState.targetCountry.coatOfArmsUrl;
  String get targetCountryName =>
      AppState.targetCountry.getLocalizedName(SettingsController.settings.language);

  bool get isButtonMode => SettingsController.gameFilter.isButtonMode;

  Future<void> initializeGame() async {
    await GameService.initializeGame(GameType.coatofarms);
  }

  Future<bool> checkAnswer(int index) async {
    String answer = textController.text;
    if (SettingsController.gameFilter.isButtonMode && index < 4) {
      answer = GameService.buttonAt(index).label;
    }

    final isCorrect = await GameService.checkStandardAnswer(
        answer, GameType.coatofarms, index);
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
          Icons.shield, Localization.t('game_coatofarms.rule_welcome')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.videogame_asset,
          Localization.t('game_coatofarms.rule_how_to_play')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.star_border,
          Localization.t('game_common.score_system_generic')),
      const SizedBox(height: 10),
      _buildRuleItem(
          Icons.lightbulb_outline, Localization.t('game_coatofarms.rule_tip')),
    ];
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7B1FA2)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void dispose() {
    textController.dispose();
  }
}
