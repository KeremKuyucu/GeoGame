// lib/services/games/distance_game_manager.dart

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart'; // tumUlkeler, kalici, gecici, yeniulkesec buradan geliyor varsayiyoruz
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';

class DistanceGameResult {
  final bool isCorrect;
  final String? messagePart;
  final bool countryFound;

  DistanceGameResult({
    required this.isCorrect,
    this.messagePart,
    required this.countryFound,
  });
}

class DistanceGameManager {

  /// Oyunu başlatır ve ayarları sıfırlar
  void initializeGame() {
    AppState.session.reset(
      startScore: 300,
      minScore: 100,
    );
    yeniulkesec(); // countries.dart'tan gelen global fonksiyon
  }

  /// Tahmini kontrol eder, hesaplamaları yapar ve skoru günceller
  DistanceGameResult processGuess(String girilenMetin) {
    if (girilenMetin.isEmpty) {
      return DistanceGameResult(isCorrect: false, countryFound: false);
    }

    try {
      // Global 'gecici' değişkenini güncelliyoruz
      gecici = tumUlkeler.firstWhere((u) => u.ks(girilenMetin));
    } catch (e) {
      debugPrint("Böyle bir ülke bulunamadı: $girilenMetin");
      return DistanceGameResult(isCorrect: false, countryFound: false);
    }

    // Matematiksel hesaplamalar
    double distance = _mesafeHesapla(
        gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam);
    String direction = _pusula(
        gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam);

    // Mesaj parçasını oluştur
    String ulkeIsmi = AppState.settings.isEnglish ? gecici.enisim : gecici.isim;

    String resultString = "";
    resultString += "${Localization.get('tahminmetin')}$ulkeIsmi    ";
    resultString += "${Localization.get('mesafe')}$distance Km   ";
    resultString += "${Localization.get('yon')}$direction\n";

    // Doğru cevap kontrolü
    if (kalici.ks(girilenMetin)) {
      AppState.session.submitCorrect();
      GameLogService.saveToStorage("distance");
      yeniulkesec(); // Yeni soruya geç
      return DistanceGameResult(
          isCorrect: true, messagePart: resultString, countryFound: true);
    } else {
      AppState.session.submitWrong();
      AppState.stats.distanceWrongCount++;
      return DistanceGameResult(
          isCorrect: false, messagePart: resultString, countryFound: true);
    }
  }

  /// Pas geçme işlemlerini yürütür
  String handlePass() {
    AppState.session.submitPass();
    String pasUlkeIsmi = (AppState.settings.isEnglish ? kalici.enisim : kalici.isim);
    yeniulkesec(); // Yeni soruya geç
    return pasUlkeIsmi;
  }

  // --- Matematiksel Fonksiyonlar (Private) ---

  double _mesafeHesapla(double latitude1, double longitude1, double latitude2,
      double longitude2) {
    const double PI = 3.14159265358979323846264338327950288;
    double theta = longitude1 - longitude2;
    double distance = acos(
        sin(latitude1 * PI / 180.0) * sin(latitude2 * PI / 180.0) +
            cos(latitude1 * PI / 180.0) *
                cos(latitude2 * PI / 180.0) *
                cos(theta * PI / 180.0)) *
        180.0 /
        PI;
    distance *= 60 * 1.1515 * 1.609344;
    return distance.roundToDouble();
  }

  String _pusula(double lat1, double lon1, double lat2, double lon2) {
    const double PI = 3.14159265358979323846264338327950288;
    lat1 *= PI / 180.0;
    lon1 *= PI / 180.0;
    lat2 *= PI / 180.0;
    lon2 *= PI / 180.0;
    double brng = atan2(sin(lon2 - lon1) * cos(lat2),
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)) *
        180 /
        PI;
    brng = (brng + 360) % 360;

    const List<String> yonlerTR = [
      "Kuzey", "Kuzeydoğu", "Doğu", "Güneydoğu",
      "Güney", "Güneybatı", "Batı", "Kuzeybatı"
    ];
    const List<String> yonlerEN = [
      "North", "Northeast", "East", "Southeast",
      "South", "Southwest", "West", "Northwest"
    ];
    List<String> yonler = AppState.settings.isEnglish ? yonlerEN : yonlerTR;
    return yonler[((brng + 22.5) / 45.0).floor() % 8];
  }
}