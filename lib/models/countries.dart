import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Dosya okuma (rootBundle) için şart

import 'app_context.dart';

List<Ulkeler> tumUlkeler = [];

final Random random = Random();

List<bool> butontiklama = [true, true, true, true];
List<String> butonAnahtarlar = ['', '', '', ''];
final List<Color> buttonColors = [Colors.green, Colors.yellow, Colors.blue, Colors.red];

Ulkeler kalici = Ulkeler.bos();
Ulkeler gecici = Ulkeler.bos();

class Ulkeler {
  final String url;      // İnternet Bayrak URL
  final String bayrak;   // Yerel Bayrak Yolu (assets/...)
  final String enisim;   // İngilizce İsim
  final String isim;     // Türkçe İsim
  final String baskent;
  final String kita;     // Kıta Bilgisi
  final bool bm;         // Birleşmiş Milletler Üyesi mi?
  final double enlem;
  final double boylam;

  Ulkeler({
    required this.bayrak,
    required this.enisim,
    required this.isim,
    required this.baskent,
    required this.kita,
    required this.url,
    required this.bm,
    required this.enlem,
    required this.boylam,
  });

  factory Ulkeler.bos() {
    return Ulkeler(
        bayrak: '', enisim: '', isim: '', baskent: '',
        kita: '', url: '', bm: false, enlem: 0, boylam: 0
    );
  }

  factory Ulkeler.fromJson(Map<String, dynamic> json) {
    List<dynamic> latlng = json['latlng'] ?? [0.0, 0.0];

    // Kıta verisi JSON'da liste olarak gelir: ["Europe"]
    String kitaVerisi = (json['continents'] != null && json['continents'].isNotEmpty)
        ? json['continents'][0]
        : 'Unknown';

    // Başkent verisi JSON'da liste olarak gelir: ["Ankara"]
    String baskentVerisi = (json['capital'] != null && json['capital'].isNotEmpty)
        ? json['capital'][0]
        : 'Yok';

    // Türkçe isim kontrolü
    String trIsim = json['name']['common'];
    if (json['translations'] != null && json['translations']['tur'] != null) {
      trIsim = json['translations']['tur']['common'];
    }

    return Ulkeler(
      url: json['flags']['png'] ?? '',
      bayrak: "assets/bayraklar/${json['name']['common'].toString().toLowerCase().replaceAll(' ', '')}.png",
      enisim: json['name']['common'] ?? '',
      isim: trIsim,
      baskent: baskentVerisi,
      kita: kitaVerisi,
      bm: json['unMember'] ?? false,
      enlem: latlng.isNotEmpty ? (latlng[0] as num).toDouble() : 0.0,
      boylam: latlng.length > 1 ? (latlng[1] as num).toDouble() : 0.0,
    );
  }

  bool ks(String yapilantahmin) {
    return yapilantahmin == isim || yapilantahmin == enisim;
  }
}

Future<void> verileriYukle() async {
  try {
    // 1. Dosyayı string olarak oku
    final String response = await rootBundle.loadString('assets/countries.json');

    // 2. JSON olarak decode et (List<dynamic> döner)
    final List<dynamic> data = json.decode(response);

    // 3. Her bir elemanı Ulkeler nesnesine çevirip listeye at
    tumUlkeler = data.map((item) => Ulkeler.fromJson(item)).toList();

    debugPrint("✅ Veriler Başarıyla Yüklendi: ${tumUlkeler.length} ülke.");
  } catch (e) {
    debugPrint("❌ KRİTİK HATA: Veriler yüklenemedi! Hata: $e");
    // Hata durumunda listeyi boş bırakmayalım ki app çökmesin
    tumUlkeler = [];
  }
}

List<Ulkeler> getFilteredCountries() {
  if (!AppState.filter.northAmerica &&
      !AppState.filter.southAmerica &&
      !AppState.filter.Asia &&
      !AppState.filter.Africa &&
      !AppState.filter.Europe &&
      !AppState.filter.Oceania &&
      !AppState.filter.Antarctic) {
    return [];
  }

  if (tumUlkeler.isEmpty) return [];

  List<Ulkeler> filteredList = [];

  for (var u in tumUlkeler) {
    bool kitaSuitable = false;

    if (AppState.filter.Europe && u.kita.contains("Europe")) kitaSuitable = true;
    else if (AppState.filter.Asia && u.kita.contains("Asia")) kitaSuitable = true;
    else if (AppState.filter.Africa && u.kita.contains("Africa")) kitaSuitable = true;
    else if (AppState.filter.Oceania && u.kita.contains("Oceania")) kitaSuitable = true;
    else if (AppState.filter.Antarctic && u.kita.contains("Antarctic")) kitaSuitable = true;
    else if (AppState.filter.northAmerica && u.kita.contains("North America")) kitaSuitable = true;
    else if (AppState.filter.southAmerica && u.kita.contains("South America")) kitaSuitable = true;

    if (!kitaSuitable) continue;

    // BM Üyeliği Kontrolü
    bool bmSuitable = AppState.filter.includeNonUN || u.bm;
    if (!bmSuitable) continue;

    filteredList.add(u);
  }

  return filteredList;
}
Future<void> yeniulkesec() async {
  if (tumUlkeler.isEmpty) {
    await verileriYukle();
  }

  final List<Ulkeler> uygunUlkeler = getFilteredCountries();

  if (uygunUlkeler.length < 4) {
    debugPrint("⚠️ UYARI: Filtrelere uygun yeterli ülke yok! (${uygunUlkeler.length})");
    return;
  }

  final List<Ulkeler> secenekler = (List<Ulkeler>.from(uygunUlkeler)..shuffle()).take(4).toList();

  kalici = secenekler[random.nextInt(4)];

  for (int i = 0; i < 4; i++) {
    butontiklama[i] = true;
    butonAnahtarlar[i] = AppState.settings.isEnglish ? secenekler[i].enisim : secenekler[i].isim;
  }

  debugPrint("🎯 Yeni Hedef: ${kalici.isim}");
}