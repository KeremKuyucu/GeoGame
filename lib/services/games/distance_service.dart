// lib/services/games/distance_game_manager.dart

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';



class GuessResultModel {
  final String countryName;
  final double distanceKm;
  final String directionText;
  final double bearing;
  final bool isCorrect;

  GuessResultModel({
    required this.countryName,
    required this.distanceKm,
    required this.directionText,
    required this.bearing,
    required this.isCorrect,
  });
}

class DistanceGameService {

  void initializeGame() {
    AppState.session.reset(
      startScore: 300,
      minScore: 100,
    );
    selectNewCountry();
  }

  /// Tahmini işler ve sonucu döndürür
  GuessResultModel? processGuess(String inputText) {
    if (inputText.isEmpty) return null;

    Country guessedCountry;

    try {
      // 1. Kullanıcının girdiği metne göre ülkeyi bul
      guessedCountry = allCountries.firstWhere(
              (u) => u.checkAnswer(inputText, Localization.currentLanguage)
      );
    } catch (e) {
      debugPrint("Böyle bir ülke bulunamadı: $inputText");
      return null;
    }

    // 2. DÜZELTME: Mesafe (Tahmin Edilen -> Hedef Ülke)
    double distance = _calculateDistance(
        guessedCountry.latitude, guessedCountry.longitude,
        targetCountry.latitude, targetCountry.longitude
    );

    // 3. DÜZELTME: Yön (Tahmin Edilen -> Hedef Ülke)
    var directionData = _pusula(
        guessedCountry.latitude, guessedCountry.longitude,
        targetCountry.latitude, targetCountry.longitude
    );

    // 4. DÜZELTME: Kazanma Kontrolü (Tahmin == Hedef mi?)
    // Eşsiz bir alan üzerinden kontrol etmek en iyisidir (örn: englishName)
    bool isCorrect = guessedCountry.englishName == targetCountry.englishName;

    // 5. YENİ YAPI: İsmi dile göre dinamik al
    String countryName = guessedCountry.getLocalizedName(Localization.currentLanguage);

    if (isCorrect) {
      AppState.session.submitCorrect();
      GameLogService.saveToStorage("distance");
      selectNewCountry();
    } else {
      AppState.session.submitWrong();
      AppState.stats.distanceWrongCount++;
    }

    return GuessResultModel(
      countryName: countryName,
      distanceKm: distance,
      directionText: directionData['text'] as String,
      bearing: directionData['bearing'] as double,
      isCorrect: isCorrect,
    );
  }

  String handlePass() {
    AppState.session.submitPass();

    // YENİ YAPI: Pas geçilen ülkenin ismini dinamik al
    String pasCountryName = targetCountry.getLocalizedName(Localization.currentLanguage);

    selectNewCountry();
    return pasCountryName;
  }

  // --- Matematiksel Fonksiyonlar ---

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0;
    double toRad(double degree) => degree * math.pi / 180.0;

    double dLat = toRad(lat2 - lat1);
    double dLon = toRad(lon2 - lon1);

    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(lat1)) * math.cos(toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (R * c).roundToDouble();
  }

  Map<String, dynamic> _pusula(double lat1, double lon1, double lat2, double lon2) {
    // Radyan dönüşümü
    double toRad(double deg) => deg * math.pi / 180.0;
    // Derece dönüşümü
    double toDeg(double rad) => rad * 180.0 / math.pi;

    final double phi1 = toRad(lat1); // Başlangıç Enlem (Tahmin)
    final double phi2 = toRad(lat2); // Hedef Enlem (Target)
    double dLon = toRad(lon2 - lon1); // Boylam farkı

    // Boylam farkı çok büyükse (Örn: -170 ile +170 arası), ters taraftan gitmeyi önlemek için
    // (Gerçi sinüs/cosinüs bunu genelde halleder ama matematiksel netlik için):
    /* Bu blok dart math kütüphanesinde sin/cos periyodik olduğu için zorunlu değil
     ama mantığı anlaman için not düşüyorum. Senin kodun çalışır. */

    final double y = math.sin(dLon) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

    double bearing = toDeg(math.atan2(y, x));

    // Açıyı 0-360 arasına normalize et
    bearing = (bearing + 360) % 360;

    // Yön İsimleri (Senin listen)
    const List<String> directionKeys = [
      "north", "north_east", "east", "south_east",
      "south", "south_west", "west", "north_west"
    ];

    // Açıyı 8 ana yöne böl (45 derecelik dilimler)
    // +22.5 eklememizin sebebi dilimi ortalamak (Örn: 337.5 ile 22.5 arası Kuzeydir)
    int index = ((bearing + 22.5) / 45.0).floor() % 8;

    return {
      'text': Localization.t("directions.${directionKeys[index]}"),
      'bearing': bearing, // Okun dönmesi gereken açı
      'icon': directionKeys[index] // İstersen ikon adı olarak da dönebilirsin
    };
  }
}