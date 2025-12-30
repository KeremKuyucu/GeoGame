import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/localization_service.dart';

// Oyun tiplerini ayırt etmek için Enum
enum GameType { flag, capital, distance, borderline }

// Mesafe oyunu sonucu için model
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

class GameService {
  // Random nesnesi math kütüphanesinden geldiği için math.Random dedik
  static final math.Random random = math.Random();

  // --- 1. BAŞLATMA VE YÖNETİM ---

  /// Oyunu başlatır, puanları ayarlar ve ilk soruyu seçer
  static Future<void> initializeGame(GameType type) async {
    int startScore = 50;
    int minScore = 20;

    // Mesafe oyunu daha zor olduğu için puanları farklı olabilir
    if (type == GameType.distance) {
      startScore = 300;
      minScore = 100;
    }

    AppState.session.reset(startScore: startScore, minScore: minScore);
    await startNewRound(); // İlk soruyu getir
  }

  /// Yeni soru seçer
  static Future<void> startNewRound() async {
    debugPrint("🔄 Yeni soru seçiliyor...");

    // Eğer ülke listesi boşsa yükle (Bu metodun AppState içinde veya burada tanımlı olması gerekir)
    if (AppState.allCountries.isEmpty) {
      // Eğer loadCountries global bir fonksiyon ise direkt çağır,
      // değilse buraya kendi yükleme mantığını ekle.
      // Örnek: await AppState.loadCountries();
      debugPrint("⚠️ Ülkeler yüklü değil, yükleniyor varsayılıyor...");
    }

    final List<Country> available = AppState.activePool;

    // Oyunun devam edebilmesi için en az 1 hedef + 3 çeldirici = 4 ülke lazım
    if (available.length < 4) {
      debugPrint("⚠️ Yeterli ülke yok! Oyun döngüsü başlatılamıyor.");
      return;
    }

    // 1. Hedef ülkeyi seç
    AppState.targetCountry = available[random.nextInt(available.length)];

    // 2. Aynı kıtadan olan adayları bul (Hedef ülke hariç)
    List<Country> sameContinentOptions = available.where((c) {
      if (c.englishName == AppState.targetCountry.englishName) return false;
      // Ortak en az bir kıtası var mı?
      return c.continents.any((cont) => AppState.targetCountry.continents.contains(cont));
    }).toList();

    sameContinentOptions.shuffle();

    List<Country> distractors = [];

    // 3. HİBRİT DOLDURMA MANTIĞI
    // Önce eldeki aynı kıta ülkelerini ekle (Maksimum 3 tane)
    distractors.addAll(sameContinentOptions.take(3));

    // Eğer hala 3 çeldiriciye ulaşamadıysak, havuzdaki diğer ülkelerden rastgele tamamla.
    if (distractors.length < 3) {
      int needed = 3 - distractors.length;

      // Zaten seçilmiş olanlar (hedef + şu anki çeldiriciler) hariç diğerleri
      final otherOptions = available.where((c) {
        bool isTarget = c.englishName == AppState.targetCountry.englishName;
        bool isAlreadyDistractor = distractors.any((d) => d.englishName == c.englishName);
        return !isTarget && !isAlreadyDistractor;
      }).toList();

      otherOptions.shuffle();
      distractors.addAll(otherOptions.take(needed));
    }

    // 4. Hedef ve çeldiricileri birleştirip karıştır
    final List<Country> finalOptions = [AppState.targetCountry, ...distractors];
    finalOptions.shuffle();

    // 5. Butonları oluştur
    AppState.buttons = GameButton.createButtons(finalOptions);

    debugPrint("🎯 Hedef: ${AppState.targetCountry.englishName} (Kıta: ${AppState.targetCountry.continents})");
  }

  /// Pas geçme işlemi (Tüm oyunlar için ortak)
  static Future<String> handlePass() async {
    AppState.session.submitPass();
    String passCountryName = AppState.targetCountry.getLocalizedName(AppState.settings.language);
    await startNewRound();
    return passCountryName;
  }

  // --- 2. STANDART OYUN KONTROLÜ (Bayrak, Başkent, Sınır Komşusu) ---

  /// Cevap kontrolü ve veritabanına kayıt işlemi
  static Future<bool> checkStandardAnswer(String answer, GameType type, int? buttonIndex) async {
    bool isCorrect = AppState.targetCountry.checkAnswer(answer.trim(), AppState.settings.language);

    if (isCorrect) {
      AppState.session.submitCorrect();

      final String gameModeKey = switch (type) {
        GameType.flag       => "flag",
        GameType.capital    => "capital",
        GameType.distance   => "distance",
        GameType.borderline => "borderline",
      };

      GameLogService.saveProgress(gameModeKey);
      await startNewRound();
      return true;
    } else {
      AppState.session.submitWrong();

      // Buton modundaysak yanlış basılan butonu pasif yap
      if (buttonIndex != null && buttonIndex >= 0 && buttonIndex < 4) {
        AppState.buttons[buttonIndex].isActive = false;
      }
      return false;
    }
  }

  // --- 3. MESAFE OYUNU KONTROLÜ (Distance) ---

  /// Mesafe oyunu için tahmin işleme
  static Future<GuessResultModel?> processDistanceGuess(String inputText) async {
    if (inputText.isEmpty) return null;

    // A. Girilen metne göre tahmin edilen ülkeyi bul
    Country? guessedCountry;
    try {
      guessedCountry = AppState.allCountries.firstWhere(
              (u) => u.checkAnswer(inputText, AppState.settings.language)
      );
    } catch (e) {
      debugPrint("Ülke bulunamadı: $inputText");
      return null;
    }

    AppState.tempCountry = guessedCountry; // Son tahmini kaydet

    // B. Hesaplamalar
    double distance = _calculateDistance(
        guessedCountry.latitude, guessedCountry.longitude,
        AppState.targetCountry.latitude, AppState.targetCountry.longitude
    );

    var directionData = _calculateBearing(
        guessedCountry.latitude, guessedCountry.longitude,
        AppState.targetCountry.latitude, AppState.targetCountry.longitude
    );

    // C. Kontrol
    bool isCorrect = guessedCountry.englishName == AppState.targetCountry.englishName;

    if (isCorrect) {
      AppState.session.submitCorrect();
      GameLogService.saveProgress("distance");
    } else {
      AppState.session.submitWrong();
    }

    return GuessResultModel(
      countryName: guessedCountry.getLocalizedName(AppState.settings.language),
      distanceKm: distance,
      directionText: directionData['text'] as String,
      bearing: directionData['bearing'] as double,
      isCorrect: isCorrect,
    );
  }

  // --- 4. MATEMATİKSEL YARDIMCILAR (Private) ---

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // Dünya yarıçapı (km)
    double toRad(double degree) => degree * math.pi / 180.0;

    double dLat = toRad(lat2 - lat1);
    double dLon = toRad(lon2 - lon1);

    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(lat1)) * math.cos(toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (R * c).roundToDouble();
  }

  static Map<String, dynamic> _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double toRad(double deg) => deg * math.pi / 180.0;
    double toDeg(double rad) => rad * 180.0 / math.pi;

    final double phi1 = toRad(lat1);
    final double phi2 = toRad(lat2);
    double dLon = toRad(lon2 - lon1);

    final double y = math.sin(dLon) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);

    double bearing = toDeg(math.atan2(y, x));
    bearing = (bearing + 360) % 360; // 0-360 arası normalize et

    const List<String> directionKeys = [
      "north", "north_east", "east", "south_east",
      "south", "south_west", "west", "north_west"
    ];

    // 8 ana yöne böl
    int index = ((bearing + 22.5) / 45.0).floor() % 8;

    return {
      'text': Localization.t("directions.${directionKeys[index]}"), // Lokalize yön ismi
      'bearing': bearing,
    };
  }
}