import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

class GameButton {
  final Country country;
  bool isActive;
  Color color;

  GameButton({
    required this.country,
    this.isActive = true,
    required this.color,
  });

  static const List<Color> _palette = [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
  ];

  static List<GameButton> createButtons(List<Country> options) => List.generate(
        options.length,
        (i) => GameButton(
          country: options[i],
          color: _palette[i % _palette.length],
        ),
      );

  String get label => country.getLocalizedName(SettingsController.language);
}
