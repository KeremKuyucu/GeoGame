class GuessResultModel {
  final String countryName;
  final double distanceKm;
  final String directionText;
  final double bearing;
  final bool isCorrect;

  const GuessResultModel({
    required this.countryName,
    required this.distanceKm,
    required this.directionText,
    required this.bearing,
    required this.isCorrect,
  });
}