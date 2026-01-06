import 'package:geogame/models/countries.dart';

class BorderPathGameData {
  final Country startCountry;
  final Country targetCountry;
  final int optimalPathLength;

  const BorderPathGameData({
    required this.startCountry,
    required this.targetCountry,
    required this.optimalPathLength,
  });
}