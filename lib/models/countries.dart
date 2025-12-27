import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle için

import 'app_context.dart';

// --- GLOBAL VARIABLES (Clean Naming) ---
List<Country> allCountries = [];
final Random random = Random();

// UI State Variables
List<bool> isButtonActive = [true, true, true, true];
List<String> buttonLabels = ['', '', '', ''];
final List<Color> buttonColors = [Colors.green, Colors.yellow, Colors.blue, Colors.red];

// Game State
Country targetCountry = Country.empty(); // Sorulan Ülke (Eski: kalici)
Country tempCountry = Country.empty(); // Gerekirse kullanılır (Eski: gecici)

class Country {
  final String flagUrl;          // API'den gelen PNG URL
  final String englishName;      // Fallback için İngilizce isim
  final Map<String, dynamic> translations; // Tüm dillerin listesi
  final String capital;
  final String continent;
  final bool isUNMember;         // BM Üyesi mi?
  final double latitude;
  final double longitude;

  Country({
    required this.flagUrl,
    required this.englishName,
    required this.translations,
    required this.capital,
    required this.continent,
    required this.isUNMember,
    required this.latitude,
    required this.longitude,
  });

  // Boş başlatıcı (Null safety için)
  factory Country.empty() {
    return Country(
      flagUrl: '',
      englishName: '',
      translations: {},
      capital: '',
      continent: '',
      isUNMember: false,
      latitude: 0,
      longitude: 0,
    );
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final List<dynamic> latlng = json['latlng'] ?? [0.0, 0.0];

    // Kıta verisi güvenli çekim
    String continentData = (json['continents'] != null && json['continents'].isNotEmpty)
        ? json['continents'][0]
        : 'Unknown';

    // Başkent verisi güvenli çekim
    String capitalData = (json['capital'] != null && json['capital'].isNotEmpty)
        ? json['capital'][0]
        : 'Unknown';

    return Country(
      flagUrl: json['flags']['png'] ?? '',
      englishName: json['name']['common'] ?? 'Unknown',
      translations: json['translations'] ?? {},
      capital: capitalData,
      continent: continentData,
      isUNMember: json['unMember'] ?? false,
      latitude: latlng.isNotEmpty ? (latlng[0] as num).toDouble() : 0.0,
      longitude: latlng.length > 1 ? (latlng[1] as num).toDouble() : 0.0,
    );
  }

  /// 🌍 Dinamik Dil Çevirisi
  /// [langCode]: 'tr', 'en', 'de', 'fr' gibi uygulama dili.
  /// JSON'daki karşılıkları: 'tur', 'eng', 'deu', 'fra' vb.
  String getLocalizedName(String langCode) {
    // 1. Dil kodunu JSON formatına (ISO 639-3) çevir
    String jsonKey = _mapLangCodeToIso3(langCode);

    // 2. Eğer o dilde çeviri varsa döndür
    if (translations.containsKey(jsonKey) && translations[jsonKey]['common'] != null) {
      return translations[jsonKey]['common'];
    }

    // 3. Bulunamazsa varsayılan olarak İngilizce ismini döndür
    return englishName;
  }

  /// 'tr' -> 'tur' dönüşümü yapan yardımcı metod
  String _mapLangCodeToIso3(String code) {
    switch (code.toLowerCase()) {
      case 'tr': return 'tur';
      case 'de': return 'deu';
      case 'fr': return 'fra';
      case 'es': return 'spa';
      case 'it': return 'ita';
      case 'ru': return 'rus';
      case 'ja': return 'jpn';
      case 'zh': return 'zho';
      case 'ar': return 'ara';
      case 'pt': return 'por';
    // Diğer diller eklenebilir
      default: return 'eng'; // Varsayılan İngilizce
    }
  }

  /// Cevap Kontrolü
  /// Hem seçili dildeki ismini hem de İngilizce ismini kabul eder.
  bool checkAnswer(String guess, String currentLangCode) {
    final String localizedName = getLocalizedName(currentLangCode);
    return guess == localizedName || guess == englishName;
  }
}

// --- DATA LOADING & LOGIC ---

Future<void> loadCountries() async {
  try {
    final String response = await rootBundle.loadString('assets/countries.json');
    final List<dynamic> data = json.decode(response);

    allCountries = data.map((item) => Country.fromJson(item)).toList();

    debugPrint("✅ Countries Loaded Successfully: ${allCountries.length}");
  } catch (e) {
    debugPrint("❌ CRITICAL ERROR: Could not load countries! $e");
    allCountries = [];
  }
}

List<Country> getFilteredCountries() {
  // Hiçbir filtre seçili değilse boş dön
  if (!AppState.filter.northAmerica &&
      !AppState.filter.southAmerica &&
      !AppState.filter.asia &&
      !AppState.filter.africa &&
      !AppState.filter.europe &&
      !AppState.filter.oceania &&
      !AppState.filter.antarctic) {
    return [];
  }

  if (allCountries.isEmpty) return [];

  return allCountries.where((c) {
    bool isContinentMatch = false;

    // Kıta kontrolü (String içeriyor mu?)
    if (AppState.filter.europe && c.continent.contains("Europe")) isContinentMatch = true;
    else if (AppState.filter.asia && c.continent.contains("Asia")) isContinentMatch = true;
    else if (AppState.filter.africa && c.continent.contains("Africa")) isContinentMatch = true;
    else if (AppState.filter.oceania && c.continent.contains("Oceania")) isContinentMatch = true;
    else if (AppState.filter.antarctic && c.continent.contains("Antarctic")) isContinentMatch = true;
    else if (AppState.filter.northAmerica && c.continent.contains("North America")) isContinentMatch = true;
    else if (AppState.filter.southAmerica && c.continent.contains("South America")) isContinentMatch = true;

    if (!isContinentMatch) return false;

    // BM Üyeliği Kontrolü
    if (!AppState.filter.includeNonUN && !c.isUNMember) return false;

    return true;
  }).toList();
}

Future<void> selectNewCountry() async {
  if (allCountries.isEmpty) {
    await loadCountries();
  }

  final List<Country> availableCountries = getFilteredCountries();

  if (availableCountries.length < 4) {
    debugPrint("⚠️ WARNING: Not enough countries for current filters! (${availableCountries.length})");
    return;
  }

  // Listeyi karıştır ve ilk 4 tanesini al
  final List<Country> options = (List<Country>.from(availableCountries)..shuffle()).take(4).toList();

  // Rastgele birini doğru cevap olarak seç (0-3 arası index)
  targetCountry = options[random.nextInt(4)];

  // Butonları güncelle
  // AppState.settings.language: 'tr', 'en', 'de' vb. döndürdüğünü varsayıyoruz.
  String currentLang = AppState.settings.language;

  for (int i = 0; i < 4; i++) {
    isButtonActive[i] = true;
    // Buton metinlerini seçili dile göre ayarla
    buttonLabels[i] = options[i].getLocalizedName(currentLang);
  }

  debugPrint("🎯 New Target: ${targetCountry.englishName} (Local: ${targetCountry.getLocalizedName(currentLang)})");
}