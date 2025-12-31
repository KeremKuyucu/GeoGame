import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_context.dart';

// lib/models/country.dart

class Country {
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
  });

  factory Country.empty() => Country(
    iso3: '', iso2: '',
    englishName: '', translations: {}, flagEmoji: '', flagUrl: '',
    capital: '', continents: [], isUNMember: false, latitude: 0.0,
    longitude: 0.0, borders: [], area: 0.0,
  );

  factory Country.fromJson(Map<String, dynamic> json) {
    String capitalData = "";
    if (json['capital'] is List && (json['capital'] as List).isNotEmpty) {
      capitalData = json['capital'][0].toString();
    } else if (json['capital'] is String) {
      capitalData = json['capital'];
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

      // ✅ GÜNCELLENEN KISIM
      latitude: (json['detailed_lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['detailed_lng'] as num?)?.toDouble() ?? 0.0,

      borders: List<String>.from(json['borders'] ?? []),
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // --- Yardımcı Metodlar ---
  String getLocalizedName(String languageCode) {
    // translations map'inde dil kodu anahtar olarak var mı?
    if (translations.containsKey(languageCode)) {
      return translations[languageCode]['common'] ?? englishName;
    }
    return englishName;
  }
  bool checkAnswer(String guess, String languageCode) {
    final String localized = getLocalizedName(languageCode).toLowerCase().trim();
    final String english = englishName.toLowerCase().trim();
    final String input = guess.toLowerCase().trim();

    // Hem yerel dildeki isme hem de İngilizce isme göre doğru kabul eder
    return input == localized || input == english;
  }
}

Future<void> loadCountries() async {
  try {
    final String response = await rootBundle.loadString('assets/countries.json');
    final List<dynamic> data = json.decode(response);

    AppState.allCountries = data.map((item) => Country.fromJson(item)).toList();

    debugPrint("✅ Countries Loaded Successfully: ${AppState.allCountries.length}");
  } catch (e) {
    debugPrint("❌ CRITICAL ERROR: Could not load countries! $e");
    AppState.allCountries = [];
  }
}
