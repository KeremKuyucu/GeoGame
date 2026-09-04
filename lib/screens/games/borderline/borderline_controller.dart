import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/geojson_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/custom_notification.dart';

class BorderLineGameController {
  final TextEditingController textController = TextEditingController();
  Future<Path?>? countryShapePathFuture;

  List<Color> getBackgroundColors() {
    return SettingsController.settings.darkTheme
        ? [const Color(0xFF1A237E), const Color(0xFF000000)]
        : [const Color(0xFFE8EAF6), const Color(0xFF9FA8DA)];
  }

  Color get cardBg => SettingsController.settings.darkTheme
      ? const Color(0xFF283593).withValues(alpha: 0.5)
      : Colors.white;

  Color get textColor =>
      SettingsController.settings.darkTheme ? Colors.white : Colors.black87;

  Color get accentColor => const Color(0xFF536DFE);

  bool get isButtonMode => SettingsController.gameFilter.isButtonMode;
  bool get isDark => SettingsController.settings.darkTheme;

  String get targetIso3 => AppState.targetCountry.iso3;

  Future<void> initializeGame() async {
    await GameService.initializeGame(GameType.borderline);
    countryShapePathFuture =
        GeoJsonService.loadCountryPath(AppState.targetCountry.iso3);
  }

  Future<bool> checkAnswer(int index) async {
    String answer = textController.text;
    if (SettingsController.gameFilter.isButtonMode && index < 4) {
      answer = GameService.buttonAt(index).label;
    }

    final bool isCorrect = await GameService.checkStandardAnswer(
        answer, GameType.borderline, index);
    textController.clear();

    if (isCorrect) {
      countryShapePathFuture =
          GeoJsonService.loadCountryPath(AppState.targetCountry.iso3);
    }

    return isCorrect;
  }

  Future<String> handlePass() async {
    final String passCountry = await GameService.handlePass();
    textController.clear();
    countryShapePathFuture =
        GeoJsonService.loadCountryPath(AppState.targetCountry.iso3);
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
          Icons.public, Localization.t('game_borderline.rule_welcome')),
      const SizedBox(height: 10),
      _buildRuleItem(
          Icons.zoom_in, Localization.t('game_borderline.hint_scale')),
      const SizedBox(height: 10),
      _buildRuleItem(Icons.star_border,
          Localization.t('game_common.score_system_generic')),
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

  void dispose() {
    textController.dispose();
  }
}
