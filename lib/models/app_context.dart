import 'package:flutter/material.dart';
import 'package:geogame/models/countries.dart'; // Country modelinin burada olduğundan emin ol
import 'package:uuid/uuid.dart';

enum GameType { flag, capital, distance, borderline, borderpath }
// --- 1. ANA DURUM YÖNETİCİSİ (AppState) ---
class AppState {
  static int selectedIndex = 0;
  static String version = "";

  // Modeller
  static UserProfile user = UserProfile.anonymous();
  static GameFilter filter = GameFilter();
  static AppSettings settings = AppSettings();
  static GameSession session = GameSession();

  // Oyun Verileri
  static Country targetCountry = Country.empty();
  static Country tempCountry = Country.empty();

  static List<Country> allCountries = [];
  static List<Country> activePool = [];

  static List<GameButton> buttons = [];

  static String getGameModeKey(GameType type) {
    return switch (type) {
      GameType.flag => "flag",
      GameType.capital => "capital",
      GameType.distance => "distance",
      GameType.borderline => "borderline",
      GameType.borderpath => "borderpath",
    };
  }

  static List<Country> get filteredCountries {
    final f = AppState.filter;

    // Hiçbir veri yoksa boş dön
    if (allCountries.isEmpty) return [];

    // Hiçbir kıta seçili değilse boş dön (Hızlı çıkış)
    if (!f.northAmerica && !f.southAmerica && !f.asia && !f.africa &&
        !f.europe && !f.oceania && !f.antarctic) {
      return [];
    }

    return allCountries.where((c) {
      // 1. BM Üyeliği Filtresi (En hızlı eleme yöntemi, başa koydum)
      if (!f.includeNonUN && !c.isUNMember) return false;

      // 2. Kıta Filtresi
      // contains metodu string karşılaştırması yaptığı için maliyetlidir.
      // Ancak 250 eleman için bu maliyet mikrosaniyeler sürer.
      if (f.europe && c.continents.contains("Europe")) return true;
      if (f.asia && c.continents.contains("Asia")) return true;
      if (f.africa && c.continents.contains("Africa")) return true;
      if (f.oceania && c.continents.contains("Oceania")) return true;
      if (f.northAmerica && c.continents.contains("North America")) return true;
      if (f.southAmerica && c.continents.contains("South America")) return true;
      if (f.antarctic && c.continents.contains("Antarctic")) return true;

      return false;
    }).toList();
  }
}

class GameButton {
  final Country country;
  bool isActive;
  Color color;

  GameButton({
    required this.country,
    this.isActive = true,
    required this.color,
  });

  // Sabit renk paleti
  static const List<Color> _palette = [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
  ];

  // Buton oluşturucu fabrika metodu
  static List<GameButton> createButtons(List<Country> options) {
    return List.generate(options.length, (i) => GameButton(
      country: options[i],
      color: _palette[i % _palette.length],
      isActive: true,
    ));
  }

  // UI etiketi
  String get label => country.getLocalizedName(AppState.settings.language);
}

class UserProfile {
  String name;
  String avatarUrl;

  UserProfile({required this.name, required this.avatarUrl});

  factory UserProfile.anonymous() {
    return UserProfile(
      name: 'Misafir',
      avatarUrl: 'https://geogame-cdn.keremkk.com.tr/anon.png',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'avatarUrl': avatarUrl};

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Misafir',
      avatarUrl: map['avatarUrl'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
    );
  }
}

class GameFilter {
  bool northAmerica, southAmerica, asia, africa, europe, oceania, antarctic;
  bool includeNonUN;
  bool isButtonMode;

  GameFilter({
    this.northAmerica = true, this.southAmerica = true, this.asia = true,
    this.africa = true, this.europe = true, this.oceania = true,
    this.antarctic = true, this.isButtonMode = true, this.includeNonUN = false,
  });

  factory GameFilter.fromMap(Map<String, dynamic> map) {
    return GameFilter(
      northAmerica: map['northAmerica'] ?? true,
      southAmerica: map['southAmerica'] ?? true,
      asia: map['asia'] ?? true,
      africa: map['africa'] ?? true,
      europe: map['europe'] ?? true,
      oceania: map['oceania'] ?? true,
      antarctic: map['antarctic'] ?? true,
      isButtonMode: map['isButtonMode'] ?? true,
      includeNonUN: map['includeNonUN'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'northAmerica': northAmerica, 'southAmerica': southAmerica, 'asia': asia,
      'africa': africa, 'europe': europe, 'oceania': oceania,
      'antarctic': antarctic, 'isButtonMode': isButtonMode, 'includeNonUN': includeNonUN,
    };
  }
}

class AppSettings {
  bool darkTheme;
  String language;

  AppSettings({this.darkTheme = true, this.language = 'eng'});

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      darkTheme: map['darkTheme'] ?? true,
      language: (map['language'] != null && map['language'].toString().isNotEmpty)
          ? map['language'] : 'eng',
    );
  }

  Map<String, dynamic> toMap() => {'darkTheme': darkTheme, 'language': language};
}

class GameSession {
  static const _uuid = Uuid();
  int totalScore = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int passCount = 0;
  String sessionId = "";

  int _startScore = 50;
  int _minScore = 20;
  int currentQuestionScore = 50;

  void reset({required int startScore, required int minScore}) {
    totalScore = 0; correctCount = 0; wrongCount = 0; passCount = 0;
    sessionId = _uuid.v4();
    _startScore = startScore; _minScore = minScore; currentQuestionScore = _startScore;
  }

  void nextQuestion() => currentQuestionScore = _startScore;

  void submitCorrect() {
    correctCount++;
    totalScore += currentQuestionScore;
    nextQuestion();
  }

  void submitWrong() {
    wrongCount++;
    currentQuestionScore -= 10;
    if (currentQuestionScore < _minScore) currentQuestionScore = _minScore;
  }

  void submitPass() {
    passCount++;
    nextQuestion();
  }
}