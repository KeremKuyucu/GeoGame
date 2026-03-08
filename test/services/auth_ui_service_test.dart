import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/services/auth_ui_service.dart';

void main() {
  // ===========================================================================
  // EMAIL VALİDASYON
  // ===========================================================================

  group('isValidEmail', () {
    test('geçerli email adresleri true dönmeli', () {
      expect(AuthUIService.isValidEmail('test@example.com'), true);
      expect(AuthUIService.isValidEmail('user.name@domain.org'), true);
      expect(AuthUIService.isValidEmail('user+tag@domain.co.uk'), true);
      expect(AuthUIService.isValidEmail('a@b.cd'), true);
    });

    test('geçersiz email adresleri false dönmeli', () {
      expect(AuthUIService.isValidEmail(''), false);
      expect(AuthUIService.isValidEmail('notanemail'), false);
      expect(AuthUIService.isValidEmail('@domain.com'), false);
      expect(AuthUIService.isValidEmail('user@'), false);
      expect(AuthUIService.isValidEmail('user@.com'), false);
      expect(AuthUIService.isValidEmail('user@domain'), false);
    });
  });

  // ===========================================================================
  // ŞİFRE VALİDASYON
  // ===========================================================================

  group('isValidPassword', () {
    test('6+ karakter true dönmeli', () {
      expect(AuthUIService.isValidPassword('123456'), true);
      expect(AuthUIService.isValidPassword('abcdef'), true);
      expect(AuthUIService.isValidPassword('strongPassword123!'), true);
    });

    test('6 karakterden kısa false dönmeli', () {
      expect(AuthUIService.isValidPassword(''), false);
      expect(AuthUIService.isValidPassword('12345'), false);
      expect(AuthUIService.isValidPassword('abc'), false);
    });

    test('tam 6 karakter sınırda true dönmeli', () {
      expect(AuthUIService.isValidPassword('abcdef'), true);
    });
  });

  // ===========================================================================
  // İSİM VALİDASYON
  // ===========================================================================

  group('isValidName', () {
    test('2+ karakter true dönmeli', () {
      expect(AuthUIService.isValidName('Al'), true);
      expect(AuthUIService.isValidName('Kerem'), true);
      expect(AuthUIService.isValidName('Çağatay'), true);
    });

    test('2 karakterden kısa false dönmeli', () {
      expect(AuthUIService.isValidName(''), false);
      expect(AuthUIService.isValidName('A'), false);
    });

    test('boşluklu isim trimlenip kontrol edilmeli', () {
      expect(AuthUIService.isValidName('  A  '), false); // trim sonrası 1 char
      expect(AuthUIService.isValidName('  Al  '), true); // trim sonrası 2 char
    });
  });

  // ===========================================================================
  // AUTH RESULT MODEL
  // ===========================================================================

  group('AuthResult', () {
    test('success factory doğru oluşturulmalı', () {
      final result = AuthResult.success('Login başarılı');

      expect(result.isSuccess, true);
      expect(result.message, 'Login başarılı');
    });

    test('failure factory doğru oluşturulmalı', () {
      final result = AuthResult.failure('Hatalı şifre');

      expect(result.isSuccess, false);
      expect(result.message, 'Hatalı şifre');
    });
  });
}
