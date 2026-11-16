import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// lib/models/countries.dart

class GameFilter {
  bool northAmerica,
      southAmerica,
      asia,
      africa,
      europe,
      oceania,
      antarctic,
      includeNonUN,
      isButtonMode;

  GameFilter({
    this.northAmerica = true,
    this.southAmerica = true,
    this.asia = true,
    this.africa = true,
    this.europe = true,
    this.oceania = true,
    this.antarctic = true,
    this.isButtonMode = true,
    this.includeNonUN = false,
  });

  factory GameFilter.fromMap(Map<String, dynamic> map) => GameFilter(
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

  Map<String, dynamic> toMap() => {
        'northAmerica': northAmerica,
        'southAmerica': southAmerica,
        'asia': asia,
        'africa': africa,
        'europe': europe,
        'oceania': oceania,
        'antarctic': antarctic,
        'isButtonMode': isButtonMode,
        'includeNonUN': includeNonUN,
      };
}

class Country {
  // --- Global Ülke Durumu (State) ---
  static List<Country> all = [];
  static List<Country> activePool = [];
  static Country targetCountry = Country.empty();
  static Country tempCountry = Country.empty();

  /// Geriye dönük uyumluluk için getter & setter
  static List<Country> get allCountries => all;
  static set allCountries(List<Country> value) => all = value;

  // --- Ülke Özellikleri ---
  final String iso3;
  final String iso2;
  final String englishName;
  final Map<String, dynamic> translations;
  final String flagEmoji;
  final String flagUrl;
  final String capital;
  final List<String> continents;
  final bool isUNMember;
  final double latitude;
  final double longitude;
  final List<String> borders;
  final double area;
  final String coatOfArmsUrl;
  final int population;

  Country({
    required this.iso3,
    required this.iso2,
    required this.englishName,
    required this.translations,
    required this.flagEmoji,
    required this.flagUrl,
    required this.capital,
    required this.continents,
    required this.isUNMember,
    required this.latitude,
    required this.longitude,
    required this.borders,
    required this.area,
    this.coatOfArmsUrl = '',
    this.population = 0,
  });

  factory Country.empty() => Country(
        iso3: '',
        iso2: '',
        englishName: '',
        translations: {},
        flagEmoji: '',
        flagUrl: '',
        capital: '',
        continents: [],
        isUNMember: false,
        latitude: 0.0,
        longitude: 0.0,
        borders: [],
        area: 0.0,
        coatOfArmsUrl: '',
        population: 0,
      );

  factory Country.fromJson(Map<String, dynamic> json) {
    String capitalData = '';
    if (json['capital'] is List && (json['capital'] as List).isNotEmpty) {
      capitalData = json['capital'][0].toString();
    } else if (json['capital'] is String) {
      capitalData = json['capital'];
    }

    final coatOfArmsData = json['coatOfArms'];
    String coatUrl = '';
    if (coatOfArmsData is Map<String, dynamic>) {
      coatUrl = (coatOfArmsData['png'] ?? coatOfArmsData['svg'] ?? '').toString();
    }

    return Country(
      iso2: json['cca2'] ?? '',
      iso3: json['cca3'] ?? '',
      englishName: json['name']?['common'] ?? 'Unknown',
      translations: json['translations'] ?? {},
      flagEmoji: json['flag'] ?? '',
      flagUrl: json['flags']?['png'] ?? '',
      capital: capitalData,
      continents: List<String>.from(json['continents'] ?? []),
      isUNMember: json['unMember'] ?? false,
      latitude: (json['detailed_lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['detailed_lng'] as num?)?.toDouble() ?? 0.0,
      borders: List<String>.from(json['borders'] ?? []),
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      coatOfArmsUrl: coatUrl,
      population: (json['population'] as num?)?.toInt() ?? 0,
    );
  }

  // --- Yardımcı Metodlar ---
  String getLocalizedName(String languageCode) {
    if (translations.containsKey(languageCode)) {
      return translations[languageCode]['common'] ?? englishName;
    }
    return englishName;
  }

  bool checkAnswer(String guess, String languageCode) {
    final String localized =
        getLocalizedName(languageCode).toLowerCase().trim();
    final String english = englishName.toLowerCase().trim();
    final String input = guess.toLowerCase().trim();

    return input == localized || input == english;
  }

  /// Kıta ve BM filtrelerine göre ülkeleri filtreler
  static List<Country> filter(GameFilter f) {
    if (all.isEmpty ||
        (!f.northAmerica &&
            !f.southAmerica &&
            !f.asia &&
            !f.africa &&
            !f.europe &&
            !f.oceania &&
            !f.antarctic)) {
      debugPrint('🌍 [Country] Hiçbir kıta seçili değil veya ülke listesi boş (0 ülke).');
      return [];
    }
    return all.where((c) {
      if (!f.includeNonUN && !c.isUNMember) return false;
      return (f.europe && c.continents.contains('Europe')) ||
          (f.asia && c.continents.contains('Asia')) ||
          (f.africa && c.continents.contains('Africa')) ||
          (f.oceania && c.continents.contains('Oceania')) ||
          (f.northAmerica && c.continents.contains('North America')) ||
          (f.southAmerica && c.continents.contains('South America')) ||
          (f.antarctic &&
              (c.continents.contains('Antarctica') ||
                  c.continents.contains('Antarctic')));
    }).toList();
  }

  /// Aktif soru havuzunu filtreye göre günceller
  static void updateActivePool(GameFilter f) {
    activePool = filter(f);
  }

  static Future<void> loadCountries([GameFilter? initialFilter]) async {
    try {
      final String response =
          await rootBundle.loadString('assets/countries.json');
      final List<dynamic> data = json.decode(response);

      all = data.map((item) => Country.fromJson(item)).toList();
      debugPrint('✅ Countries Loaded Successfully: ${all.length}');

      if (initialFilter != null) {
        updateActivePool(initialFilter);
      }
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR: Could not load countries! $e');
      all = [];
      activePool = [];
    }
  }
}
