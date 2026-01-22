// lib/services/geojson_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geogame/models/app_context.dart';

/// GeoJSON dosyalarını yükleme ve Flutter Path'e dönüştürme işlemlerini
/// yöneten servis. Tüm oyunlarda ortak olarak kullanılır.
class GeoJsonService {
  /// GeoJSON dosyasını okuyup Flutter Path nesnesine çevirir.
  /// Önce assets'ten, başarısız olursa network'ten yükler.
  static Future<Path?> loadCountryPath(String isoCode) async {
    Path path = Path();

    // 1. Yerelden dene
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/geojson/${isoCode.toLowerCase()}.geojson',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      _parseGeoJsonToPath(jsonData, path);
      return path;
    } catch (e) {
      debugPrint("Local GeoJSON upload error ($isoCode): $e");
    }

    // 2. Network fallback
    try {
      final Uri url = Uri.parse(
        'https://raw.githubusercontent.com/mledoze/countries/master/data/${isoCode.toLowerCase()}.geo.json',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        _parseGeoJsonToPath(jsonData, path);
        return path;
      } else {
        debugPrint("GeoJSON network error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("GeoJSON Network Error ($isoCode): $e");
    }

    return null;
  }

  /// Birden fazla ülke path'ini paralel olarak yükler.
  /// Verilen ISO kodları için path'leri Map olarak döner.
  static Future<Map<String, Path>> loadCountryPaths(
      List<String> isoCodes) async {
    final results = await Future.wait(
      isoCodes.map((iso) => loadCountryPath(iso)),
    );

    final Map<String, Path> pathMap = {};
    for (int i = 0; i < isoCodes.length; i++) {
      if (results[i] != null) {
        pathMap[isoCodes[i]] = results[i]!;
      }
    }
    return pathMap;
  }

  /// GeoJSON yapısını ayrıştırır ve Path nesnesine ekler.
  static void _parseGeoJsonToPath(Map<String, dynamic> json, Path path) {
    if (json.isEmpty || json['type'] == null) return;

    final String type = json['type'];

    switch (type) {
      case 'FeatureCollection':
        final features = json['features'] as List<dynamic>? ?? [];
        for (var feature in features) {
          if (feature is Map<String, dynamic>) {
            _parseGeoJsonToPath(feature, path);
          }
        }
        break;
      case 'Feature':
        final geometry = json['geometry'] as Map<String, dynamic>?;
        if (geometry != null) _parseGeoJsonToPath(geometry, path);
        break;
      case 'Polygon':
        final coordinates = json['coordinates'] as List<dynamic>? ?? [];
        _addPolygonToPath(path, coordinates);
        break;
      case 'MultiPolygon':
        final polygons = json['coordinates'] as List<dynamic>? ?? [];
        for (var polygon in polygons) {
          _addPolygonToPath(path, polygon as List<dynamic>);
        }
        break;
      default:
        debugPrint("Unknown GeoJSON type: $type");
    }
  }

  /// Koordinat listesini Path'e ekler.
  /// [simplify] true ise büyük poligonları basitleştirir.
  static void _addPolygonToPath(Path path, List polygonCoords,
      {bool simplify = false}) {
    for (var ring in polygonCoords) {
      if (ring.isEmpty) continue;

      // Çok küçük poligonları atla (Gürültüyü azaltır)
      if (simplify && ring.length < 10) continue;

      // Dinamik basitleştirme faktörü
      int skipFactor = 1;
      if (simplify) {
        if (ring.length > 10000) {
          skipFactor = 50; // Rusya gibi devasa sınırlar için çok agresif
        } else if (ring.length > 5000) {
          skipFactor = 20;
        } else if (ring.length > 1000) {
          skipFactor = 10;
        } else if (ring.length > 200) {
          skipFactor = 3;
        }
      }

      // İlk nokta
      final start = ring[0] as List<dynamic>;
      double startX = (start[0] as num).toDouble();
      double startY = -(start[1] as num).toDouble(); // Y ekseni ters çevrildi
      path.moveTo(startX, startY);

      for (int i = 1; i < ring.length; i++) {
        // Büyük poligonlarda basitleştirme
        if (simplify && i % skipFactor != 0 && i != ring.length - 1) continue;

        final point = ring[i] as List<dynamic>;
        double x = (point[0] as num).toDouble();
        double y = -(point[1] as num).toDouble();
        path.lineTo(x, y);
      }
      path.close();
    }
  }

  /// GeoJSON Path'ini basitleştirilmiş modda yükler.
  /// Border Path oyunu gibi çok fazla ülke çizilecek durumlarda kullanılır.
  static Future<Path?> loadCountryPathSimplified(String isoCode) async {
    Path path = Path();

    // 1. Yerelden dene
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/geojson/${isoCode.toLowerCase()}.geojson',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      _parseGeoJsonToPath(jsonData, path);
      return path;
    } catch (e) {
      debugPrint("Local GeoJSON upload error ($isoCode): $e");
    }

    // 2. Network fallback
    try {
      final Uri url = Uri.parse(
        'https://raw.githubusercontent.com/mledoze/countries/master/data/${isoCode.toLowerCase()}.geo.json',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        _parseGeoJsonToPath(jsonData, path);
        return path;
      }
    } catch (e) {
      debugPrint("GeoJSON Network Error ($isoCode): $e");
    }

    return null;
  }

  /// Tüm dünya haritasını tek dosyadan yükler (Simplified).
  /// AppState.allCountries listesini kullanarak tüm ülkeleri tek tek yükler.
  static Future<Map<String, Path>> loadWorldMapSimplified() async {
    final Map<String, Path> result = {};

    // AppState'deki kayıtlı ülkeler üzerinden gidiyoruz
    if (AppState.allCountries.isEmpty) {
      debugPrint("Warning: AppState.allCountries is empty during map load.");
      return result;
    }

    final futures = AppState.allCountries.map((country) async {
      try {
        final iso = country.iso3;
        final pathStr = 'assets/geojson/${iso.toLowerCase()}.geojson';

        final String jsonString = await rootBundle.loadString(pathStr);
        final Map<String, dynamic> json = jsonDecode(jsonString);

        final Path p = Path();
        _parseGeoJsonToPath(json, p);

        return MapEntry(iso, p);
      } catch (e) {
        // debugPrint("Error loading $iso: $e");
        return null;
      }
    });

    final entries = await Future.wait(futures);
    for (var entry in entries) {
      if (entry != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}
