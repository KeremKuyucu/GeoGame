import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/services/update_checker_service.dart';

void main() {
  // ===========================================================================
  // VERSİYON KARŞILAŞTIRMA TESTLERİ
  // ===========================================================================
  //
  // _isNewVersionAvailable private olduğu için dolaylı olarak test ediyoruz.
  // Aşağıdaki testler, metodu public yaparsanız veya @visibleForTesting
  // annotation'ı eklerseniz çalışır.
  //
  // Şu an direkt erişim olmadığı için bu test dosyası, metodu public yaptıktan
  // sonra çalışması için hazırlanmıştır.
  //
  // update_checker_service.dart'ta şu değişikliği yapın:
  //   static bool _isNewVersionAvailable(...)
  //   →
  //   @visibleForTesting
  //   static bool isNewVersionAvailable(...)
  // ===========================================================================

  group('Versiyon karşılaştırma (UpdateService)', () {
    // Bu testler _isNewVersionAvailable metodunu @visibleForTesting ile
    // açtığınızda çalıştırılabilir.

    // Örnek test yapısı:
    //
    // test('remote daha büyükse true dönmeli', () {
    //   expect(UpdateService.isNewVersionAvailable('1.5.0', '1.6.0'), true);
    //   expect(UpdateService.isNewVersionAvailable('1.0.0', '2.0.0'), true);
    //   expect(UpdateService.isNewVersionAvailable('1.5.9', '1.6.0'), true);
    // });
    //
    // test('aynı versiyon false dönmeli', () {
    //   expect(UpdateService.isNewVersionAvailable('1.6.0', '1.6.0'), false);
    // });
    //
    // test('local daha büyükse false dönmeli', () {
    //   expect(UpdateService.isNewVersionAvailable('2.0.0', '1.6.0'), false);
    //   expect(UpdateService.isNewVersionAvailable('1.6.1', '1.6.0'), false);
    // });
    //
    // test('farklı uzunlukta versiyon stringlerini handle etmeli', () {
    //   expect(UpdateService.isNewVersionAvailable('1.0', '1.0.1'), true);
    //   expect(UpdateService.isNewVersionAvailable('1.0.0', '1.1'), true);
    // });

    test('UpdateService sınıf sabitleri doğru olmalı', () {
      expect(UpdateService.repoOwner, 'KeremKuyucu');
      expect(UpdateService.repoName, 'GeoGame');
    });
  });
}
