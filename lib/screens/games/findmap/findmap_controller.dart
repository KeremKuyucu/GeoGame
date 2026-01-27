import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/services/geojson_service.dart';
import 'package:geogame/services/game_log_service.dart';

class FindMapGameController {
  bool isLoading = true;
  
  // Harita verileri
  Map<String, Path> countryPaths = {};
  
  // UI tarafından erişilecek aktif ülke listesi
  List<Country> countries = []; 
  
  // Küçük ülkeler için özel liste (Marker çizimi için)
  List<Country> smallCountries = [];
  
  // Küçük ülkelerin HAM merkez noktaları (Transform edilmemiş)
  Map<String, Offset> smallCountryCenters = {};
  
  Country? targetCountry;

  // Hit test optimizasyonu için bounds cache'i
  final Map<String, Rect> _pathBounds = {};

  // Sabitler
  static const double _smallCountryAreaThreshold = 2000.0;

  // UI Yardımcıları
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

    // 1. Path'leri yükle
    countryPaths = await GeoJsonService.loadWorldMapSimplified();

    // 2. Verileri hazırla (Bounds ve Küçük Ülke Analizi)
    _prepareData();

    startNewRound();
    isLoading = false;
  }

  void _prepareData() {
    _pathBounds.clear();
    countries.clear();
    smallCountries.clear();
    smallCountryCenters.clear();

    for (var entry in countryPaths.entries) {
      final iso = entry.key;
      final path = entry.value;

      // Bounds cache
      final bounds = path.getBounds();
      _pathBounds[iso] = bounds;

      // Ülke modelini bul ve listeye ekle
      try {
        final country = AppState.allCountries.firstWhere(
          (c) => c.iso3 == iso,
        );
        countries.add(country);

        // Küçük ülke kontrolü (Area < 2000)
        // Eğer area verisi null ise varsayılan olarak büyük kabul et (hata önleme)
        if ((country.area ?? 999999) < _smallCountryAreaThreshold) {
          smallCountries.add(country);
          // Merkez noktasını BİR KEZ hesapla ve sakla.
          // Bu, her karede (frame) hesaplama yapmayı önler.
          smallCountryCenters[iso] = bounds.center;
        }
      } catch (_) {
        // AppState içinde olmayan bir ISO kodu varsa (örn: disputed territories), atla.
        continue;
      }
    }
  }

  void startNewRound() {
    if (countryPaths.isEmpty) return;

    // Aktif havuzdan (Ayarlarda seçili kıtalar vs.) bir ülke seç
    final possibleTargets = AppState.activePool
        .where((c) => countryPaths.containsKey(c.iso3))
        .toList();

    if (possibleTargets.isEmpty) {
      // Fallback
      if (countries.isNotEmpty) {
        targetCountry = countries[Random().nextInt(countries.length)];
      } else {
        targetCountry = null;
      }
    } else {
      targetCountry = possibleTargets[Random().nextInt(possibleTargets.length)];
    }
  }

  Matrix4 mapMatrix = Matrix4.identity();

  void prepareMapMatrix(Size size) {
    if (countryPaths.isEmpty) return;

    Rect? combinedBounds;
    for (final bounds in _pathBounds.values) {
      if (bounds.isEmpty || bounds.width == 0 || bounds.height == 0) continue;
      if (bounds.width > 10000 || bounds.height > 10000) continue;

      combinedBounds = combinedBounds == null
          ? bounds
          : combinedBounds.expandToInclude(bounds);
    }

    if (combinedBounds == null || combinedBounds.isEmpty) return;

    final double scaleX = size.width / combinedBounds.width;
    final double scaleY = size.height / combinedBounds.height;
    final double scale = min(scaleX, scaleY) * 0.95; 

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

  /// Tıklanan konumu kontrol eder ve ülkeyi döner (Normal Path Hit Test)
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
            return countries.firstWhere((c) => c.iso3 == iso);
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
