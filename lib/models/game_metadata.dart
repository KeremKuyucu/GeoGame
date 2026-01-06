import 'package:flutter/material.dart';

enum GameType { flag, capital, distance, borderline, borderpath }

class GameMetadata {
  final GameType type;
  final String titleKey;
  final String descKey;
  final String img;
  final Color color;
  final String route;

  const GameMetadata({
    required this.type,
    required this.titleKey,
    required this.descKey,
    required this.img,
    required this.color,
    required this.route,
  });
}

final List<GameMetadata> gameMetadataList = [
  const GameMetadata(
    type: GameType.capital,
    titleKey: 'game_capital',
    descKey: 'game_capital',
    img: 'assets/images/capital.webp',
    color: Color(0xFF6A1B9A),
    route: '/game/capital',
  ),
  const GameMetadata(
    type: GameType.flag,
    titleKey: 'game_flag',
    descKey: 'game_flag',
    img: 'assets/images/flag.webp',
    color: Color(0xFF2E7D32),
    route: '/game/flag',
  ),
  const GameMetadata(
    type: GameType.distance,
    titleKey: 'game_distance',
    descKey: 'game_distance',
    img: 'assets/images/distance.webp',
    color: Color(0xFF1565C0),
    route: '/game/distance',
  ),
  const GameMetadata(
    type: GameType.borderline,
    titleKey: 'game_borderline',
    descKey: 'game_borderline',
    img: 'assets/images/borderline.webp',
    color: Color(0xFF283593),
    route: '/game/borderline',
  ),
  const GameMetadata(
    type: GameType.borderpath,
    titleKey: 'game_borderpath',
    descKey: 'game_borderpath',
    img: 'assets/images/borderpath.webp',
    color: Color(0xFFD84315),
    route: '/game/borderpath',
  ),
];