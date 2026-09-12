import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/services/update_checker_service.dart';

void main() {
  // ===========================================================================
  // VERSİYON KARŞILAŞTIRMA TESTLERİ
  // ===========================================================================

  group('UpdateService.isNewVersionAvailable', () {
    test('remote daha büyükse true dönmeli', () {
      expect(UpdateService.isNewVersionAvailable('1.5.0', '1.6.0'), true);
      expect(UpdateService.isNewVersionAvailable('1.0.0', '2.0.0'), true);
      expect(UpdateService.isNewVersionAvailable('1.5.9', '1.6.0'), true);
    });

    test('minor/patch artışı true dönmeli', () {
      expect(UpdateService.isNewVersionAvailable('1.6.5', '1.6.6'), true);
      expect(UpdateService.isNewVersionAvailable('1.6.6', '1.7.0'), true);
    });

    test('aynı versiyon false dönmeli', () {
      expect(UpdateService.isNewVersionAvailable('1.6.0', '1.6.0'), false);
      expect(UpdateService.isNewVersionAvailable('0.0.1', '0.0.1'), false);
    });

    test('local daha büyükse false dönmeli', () {
      expect(UpdateService.isNewVersionAvailable('2.0.0', '1.6.0'), false);
      expect(UpdateService.isNewVersionAvailable('1.6.1', '1.6.0'), false);
    });

    test('farklı uzunlukta versiyon stringlerini handle etmeli', () {
      expect(UpdateService.isNewVersionAvailable('1.0', '1.0.1'), true);
      expect(UpdateService.isNewVersionAvailable('1.0.0', '1.1'), true);
    });

    test('major versiyon farkı doğru çalışmalı', () {
      expect(UpdateService.isNewVersionAvailable('1.9.9', '2.0.0'), true);
      expect(UpdateService.isNewVersionAvailable('3.0.0', '2.9.9'), false);
    });

    test('geçersiz versiyon stringi false dönmeli (hata fırlatmamalı)', () {
      expect(UpdateService.isNewVersionAvailable('abc', '1.0.0'), false);
      expect(UpdateService.isNewVersionAvailable('1.0.0', 'xyz'), false);
      expect(UpdateService.isNewVersionAvailable('', ''), false);
    });
  });

  // ===========================================================================
  // SABİTLER
  // ===========================================================================

  group('UpdateService sabitleri', () {
    test('repo sabitlerinin doğru olmalı', () {
      expect(UpdateService.repoOwner, 'KeremKuyucu');
      expect(UpdateService.repoName, 'GeoGame');
    });
  });
}
