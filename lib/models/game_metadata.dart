import 'package:flutter/material.dart';

enum GameType { flag, capital, distance, borderline, borderpath }

/// Oyun kural bilgilerini tutan sınıf
class GameRule {
  final IconData icon;
  final String textKey;

  const GameRule({required this.icon, required this.textKey});
}

class GameMetadata {
  final GameType type;
  final String titleKey;
  final String descKey;
  final String img;
  final Color color;
  final String route;
  final IconData iconData;
  final List<GameRule> rules;

  const GameMetadata({
    required this.type,
    required this.titleKey,
    required this.descKey,
    required this.img,
    required this.color,
    required this.route,
    required this.iconData,
    required this.rules,
  });
}

final List<GameMetadata> gameMetadataList = [
  GameMetadata(
    type: GameType.capital,
    titleKey: 'game_capital',
    descKey: 'game_capital',
    img: 'assets/images/capital.webp',
    color: const Color(0xFF6A1B9A),
    route: '/game/capital',
    iconData: Icons.location_city,
    rules: const [
      GameRule(icon: Icons.info_outline, textKey: 'game_capital.rule_welcome'),
      GameRule(
          icon: Icons.videogame_asset,
          textKey: 'game_capital.rule_how_to_play'),
      GameRule(
          icon: Icons.star_border, textKey: 'game_common.score_system_generic'),
      GameRule(icon: Icons.lightbulb_outline, textKey: 'game_capital.rule_tip'),
    ],
  ),
  GameMetadata(
    type: GameType.flag,
    titleKey: 'game_flag',
    descKey: 'game_flag',
    img: 'assets/images/flag.webp',
    color: const Color(0xFF2E7D32),
    route: '/game/flag',
    iconData: Icons.flag,
    rules: const [
      GameRule(icon: Icons.flag, textKey: 'game_flag.rule_welcome'),
      GameRule(
          icon: Icons.videogame_asset, textKey: 'game_flag.rule_how_to_play'),
      GameRule(
          icon: Icons.star_border, textKey: 'game_common.score_system_generic'),
      GameRule(icon: Icons.lightbulb_outline, textKey: 'game_flag.rule_tip'),
    ],
  ),
  GameMetadata(
    type: GameType.distance,
    titleKey: 'game_distance',
    descKey: 'game_distance',
    img: 'assets/images/distance.webp',
    color: const Color(0xFF1565C0),
    route: '/game/distance',
    iconData: Icons.straighten,
    rules: const [
      GameRule(icon: Icons.map, textKey: 'game_distance.rule_welcome'),
      GameRule(
          icon: Icons.videogame_asset,
          textKey: 'game_distance.rule_how_to_play'),
      GameRule(icon: Icons.star_border, textKey: 'game_distance.rule_score'),
      GameRule(
          icon: Icons.lightbulb_outline, textKey: 'game_distance.rule_tip'),
    ],
  ),
  GameMetadata(
    type: GameType.borderline,
    titleKey: 'game_borderline',
    descKey: 'game_borderline',
    img: 'assets/images/borderline.webp',
    color: const Color(0xFF283593),
    route: '/game/borderline',
    iconData: Icons.public,
    rules: const [
      GameRule(icon: Icons.public, textKey: 'game_borderline.rule_welcome'),
      GameRule(
          icon: Icons.videogame_asset,
          textKey: 'game_borderline.rule_how_to_play'),
      GameRule(
          icon: Icons.star_border, textKey: 'game_common.score_system_generic'),
      GameRule(
          icon: Icons.lightbulb_outline, textKey: 'game_borderline.rule_tip'),
    ],
  ),
  GameMetadata(
    type: GameType.borderpath,
    titleKey: 'game_borderpath',
    descKey: 'game_borderpath',
    img: 'assets/images/borderpath.webp',
    color: const Color(0xFFD84315),
    route: '/game/borderpath',
    iconData: Icons.route,
    rules: const [
      GameRule(icon: Icons.flag, textKey: 'game_borderpath.rule_1'),
      GameRule(icon: Icons.swap_horiz, textKey: 'game_borderpath.rule_2'),
      GameRule(icon: Icons.star_border, textKey: 'game_borderpath.rule_3'),
      GameRule(icon: Icons.map, textKey: 'game_borderpath.rule_4'),
    ],
  ),
];
