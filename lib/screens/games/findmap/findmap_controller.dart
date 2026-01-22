import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/geojson_service.dart';
import 'package:geogame/services/game_log_service.dart';

class FindMapGameController {
  bool isLoading = true;
  Map<String, Path> countryPaths = {};
  Country? targetCountry;

  // Cache bounds for hit testing optimization
  final Map<String, Rect> _pathBounds = {};

  // UI Helpers
  Color get backgroundColor => AppState.settings.darkTheme
      ? const Color(0xFF1E2746)
      : Colors.blue.shade50;
  Color get cardBg =>
      AppState.settings.darkTheme ? Colors.black45 : Colors.white;
  Color get textColor =>
      AppState.settings.darkTheme ? Colors.white : Colors.black87;

  bool get isDark => AppState.settings.darkTheme;
  int get correctAnswers => AppState.session.correctCount;
  int get wrongAnswers => AppState.session.wrongCount;

  Future<void> initializeGame() async {
    isLoading = true;
    GameService.initializeGame(GameType.findmap);

    // Tek dosyadan tüm dünyayı yükle
    countryPaths = await GeoJsonService.loadWorldMapSimplified();

    // Bounds hesapla ve cache'le
    _pathBounds.clear();
    for (var entry in countryPaths.entries) {
      _pathBounds[entry.key] = entry.value.getBounds();
    }

    startNewRound();
    isLoading = false;
  }

  void startNewRound() {
    if (countryPaths.isEmpty) return;

    // Aktif havuzdan (Ayarlarda seçili kıtalar vs.) bir ülke seç
    final possibleTargets = AppState.activePool
        .where((c) => countryPaths.containsKey(c.iso3))
        .toList();

    if (possibleTargets.isEmpty) {
      // Fallback: Tüm haritadan seç (eğer havuz pathlerle eşleşmezse)
      final keys = countryPaths.keys.toList();
      final randomIso = keys[Random().nextInt(keys.length)];
      // Bu ISO'ya sahip ülkeyi bulmaya çalış, yoksa hata
      try {
        targetCountry =
            AppState.allCountries.firstWhere((c) => c.iso3 == randomIso);
      } catch (_) {
        // Modelde yoksa (örn: disputed territories), pas geç ve tekrar dene veya ilkini al
        targetCountry = AppState.allCountries.isNotEmpty
            ? AppState.allCountries.first
            : null;
      }
    } else {
      targetCountry = possibleTargets[Random().nextInt(possibleTargets.length)];
    }
  }

  Matrix4 mapMatrix = Matrix4.identity();

  void prepareMapMatrix(Size size) {
    if (countryPaths.isEmpty) return;

    Rect? combinedBounds;
    for (final path in countryPaths.values) {
      final bounds = path.getBounds();
      if (bounds.isEmpty || bounds.width == 0 || bounds.height == 0) continue;

      // Sanity check for bounds (sometimes artifacts create huge bounds)
      if (bounds.width > 10000 || bounds.height > 10000) continue;

      combinedBounds = combinedBounds == null
          ? bounds
          : combinedBounds.expandToInclude(bounds);
    }

    if (combinedBounds == null || combinedBounds.isEmpty) return;

    // Calculate scale to fit
    final double scaleX = size.width / combinedBounds.width;
    final double scaleY = size.height / combinedBounds.height;
    final double scale = min(scaleX, scaleY) * 0.95; // %5 padding

    // Center filtering:
    // Move data center to (0,0) -> Scale -> Move to screen center
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double dataCenterX = combinedBounds.center.dx;
    final double dataCenterY = combinedBounds.center.dy;

    mapMatrix = Matrix4.identity()
      ..translateByVector3(
        vector.Vector3(centerX, centerY, 0.0),
      )
      ..scaleByVector3(
        vector.Vector3(scale, scale, 1.0),
      )
      ..translateByVector3(
        vector.Vector3(-dataCenterX, -dataCenterY, 0.0),
      );
  }

  /// Tıklanan konumu kontrol eder ve ülkeyi döner
  Country? handleTap(Offset localPosition) {
    try {
      final Matrix4 inverse =
          Matrix4.tryInvert(mapMatrix) ?? Matrix4.identity();
      final vector.Vector3 pointVec = inverse.perspectiveTransform(
          vector.Vector3(localPosition.dx, localPosition.dy, 0));
      final Offset point = Offset(pointVec.x, pointVec.y);

      // Hit test
      for (final entry in countryPaths.entries) {
        final iso = entry.key;
        final path = entry.value;

        // Bounds check optimization
        if (_pathBounds[iso]?.contains(point) == true) {
          if (path.contains(point)) {
            return AppState.allCountries.firstWhere((c) => c.iso3 == iso);
          }
        }
      }
    } catch (e) {
      debugPrint("Hit test error: $e");
    }
    return null;
  }

  Future<void> handleCorrectAnswer({bool hintUsed = false}) async {
    if (!hintUsed) {
      AppState.session.submitCorrect();
    }
    await GameLogService.saveProgress("findmap");
    startNewRound();
  }

  void handleWrongAnswer() {
    AppState.session.submitWrong();
  }

  void dispose() {
    // cleanup if needed
  }
}
