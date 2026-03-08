import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/models/countries.dart';

void main() {
  // ===========================================================================
  // COUNTRY MODEL TESTLERİ
  // ===========================================================================

  group('Country', () {
    late Country turkey;
    late Country germany;

    setUp(() {
      turkey = Country(
        iso3: 'TUR',
        iso2: 'TR',
        englishName: 'Turkey',
        translations: {
          'tur': {'common': 'Türkiye'},
          'deu': {'common': 'Türkei'},
        },
        flagEmoji: '🇹🇷',
        flagUrl: 'https://flagcdn.com/w320/tr.png',
        capital: 'Ankara',
        continents: ['Asia', 'Europe'],
        isUNMember: true,
        latitude: 39.0,
        longitude: 35.0,
        borders: ['ARM', 'AZE', 'BGR', 'GEO', 'GRC', 'IRN', 'IRQ', 'SYR'],
        area: 783562,
      );

      germany = Country(
        iso3: 'DEU',
        iso2: 'DE',
        englishName: 'Germany',
        translations: {
          'tur': {'common': 'Almanya'},
          'deu': {'common': 'Deutschland'},
        },
        flagEmoji: '🇩🇪',
        flagUrl: 'https://flagcdn.com/w320/de.png',
        capital: 'Berlin',
        continents: ['Europe'],
        isUNMember: true,
        latitude: 51.0,
        longitude: 9.0,
        borders: [
          'AUT',
          'BEL',
          'CZE',
          'DNK',
          'FRA',
          'LUX',
          'NLD',
          'POL',
          'CHE'
        ],
        area: 357114,
      );
    });

    // =========================================================================
    // getLocalizedName
    // =========================================================================

    group('getLocalizedName', () {
      test('Türkçe isim döndürmeli', () {
        expect(turkey.getLocalizedName('tur'), 'Türkiye');
      });

      test('Almanca isim döndürmeli', () {
        expect(turkey.getLocalizedName('deu'), 'Türkei');
      });

      test('bilinmeyen dilde İngilizce fallback yapmalı', () {
        expect(turkey.getLocalizedName('xyz'), 'Turkey');
      });

      test('eng dili İngilizce dönmeli (translations yoksa)', () {
        expect(turkey.getLocalizedName('eng'), 'Turkey');
      });
    });

    // =========================================================================
    // checkAnswer
    // =========================================================================

    group('checkAnswer', () {
      test('İngilizce isimle doğru dönmeli', () {
        expect(turkey.checkAnswer('Turkey', 'eng'), true);
      });

      test('Türkçe isimle doğru dönmeli', () {
        expect(turkey.checkAnswer('Türkiye', 'tur'), true);
      });

      test('büyük/küçük harf fark etmemeli', () {
        expect(turkey.checkAnswer('turkey', 'eng'), true);
        expect(turkey.checkAnswer('TURKEY', 'eng'), true);
        expect(turkey.checkAnswer('türkiye', 'tur'), true);
      });

      test('baştaki/sondaki boşluk önemsenmemeli', () {
        expect(turkey.checkAnswer('  Turkey  ', 'eng'), true);
        expect(turkey.checkAnswer(' Türkiye ', 'tur'), true);
      });

      test('yanlış cevab ile false dönmeli', () {
        expect(turkey.checkAnswer('Germany', 'eng'), false);
        expect(turkey.checkAnswer('Almanya', 'tur'), false);
      });

      test('farklı dilde İngilizce isim de kabul edilmeli', () {
        // tur dilinde "Turkey" yazılınca da doğru olmalı
        expect(turkey.checkAnswer('Turkey', 'tur'), true);
      });

      test('boş string false dönmeli', () {
        expect(turkey.checkAnswer('', 'eng'), false);
      });
    });

    // =========================================================================
    // Country.empty()
    // =========================================================================

    group('Country.empty()', () {
      test('boş country varsayılan değerlerle oluşturulmalı', () {
        final empty = Country.empty();

        expect(empty.iso3, '');
        expect(empty.englishName, '');
        expect(empty.continents, isEmpty);
        expect(empty.borders, isEmpty);
        expect(empty.latitude, 0.0);
        expect(empty.longitude, 0.0);
        expect(empty.isUNMember, false);
      });
    });

    // =========================================================================
    // Country.fromJson
    // =========================================================================

    group('Country.fromJson', () {
      test('standart JSON parse edilmeli', () {
        final json = {
          'cca2': 'TR',
          'cca3': 'TUR',
          'name': {'common': 'Turkey'},
          'translations': {
            'tur': {'common': 'Türkiye'}
          },
          'flag': '🇹🇷',
          'flags': {'png': 'https://flagcdn.com/w320/tr.png'},
          'capital': ['Ankara'],
          'continents': ['Asia', 'Europe'],
          'unMember': true,
          'detailed_lat': 39.9334,
          'detailed_lng': 32.8597,
          'borders': ['ARM', 'GRC'],
          'area': 783562,
        };

        final country = Country.fromJson(json);

        expect(country.iso3, 'TUR');
        expect(country.iso2, 'TR');
        expect(country.englishName, 'Turkey');
        expect(country.capital, 'Ankara');
        expect(country.continents, contains('Asia'));
        expect(country.continents, contains('Europe'));
        expect(country.isUNMember, true);
        expect(country.latitude, closeTo(39.93, 0.01));
        expect(country.borders, ['ARM', 'GRC']);
      });

      test('capital List ise ilk elemanı almalı', () {
        final json = {
          'cca2': 'DE',
          'cca3': 'DEU',
          'name': {'common': 'Germany'},
          'capital': ['Berlin'],
          'continents': ['Europe'],
          'area': 357114,
        };

        final country = Country.fromJson(json);
        expect(country.capital, 'Berlin');
      });

      test('capital String ise direkt almalı', () {
        final json = {
          'cca2': 'DE',
          'cca3': 'DEU',
          'name': {'common': 'Germany'},
          'capital': 'Berlin',
          'continents': ['Europe'],
          'area': 357114,
        };

        final country = Country.fromJson(json);
        expect(country.capital, 'Berlin');
      });

      test('eksik alanlar için varsayılan değerler kullanılmalı', () {
        final json = <String, dynamic>{
          'cca2': null,
          'cca3': null,
          'name': null,
        };

        final country = Country.fromJson(json);

        expect(country.iso3, '');
        expect(country.iso2, '');
        expect(country.englishName, 'Unknown');
        expect(country.capital, '');
        expect(country.continents, isEmpty);
        expect(country.isUNMember, false);
        expect(country.latitude, 0.0);
        expect(country.longitude, 0.0);
      });
    });

    // =========================================================================
    // BORDER & CONTINENT DATA
    // =========================================================================

    group('Ülke verileri', () {
      test('Türkiye hem Asya hem Avrupa kıtasında olmalı', () {
        expect(turkey.continents, containsAll(['Asia', 'Europe']));
      });

      test('Almanya sadece Avrupa kıtasında olmalı', () {
        expect(germany.continents, ['Europe']);
      });

      test('Türkiye sınır komşuları doğru olmalı', () {
        expect(turkey.borders, contains('GRC'));
        expect(turkey.borders, contains('IRN'));
        expect(turkey.borders.length, 8);
      });
    });
  });
}
