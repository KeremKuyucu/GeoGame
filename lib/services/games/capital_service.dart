// lib/services/games/capital_game_service.dart

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart'; // kalici, yeniulkesec, butontiklama vb. buradan geliyor
import 'package:geogame/services/game_log_service.dart';

import 'package:geogame/services/localization_service.dart';

class CapitalGameService {

  /// Oyunu başlatır, puanları sıfırlar ve ilk soruyu seçer
  void initializeGame() {
    AppState.session.reset(
      startScore: 50,
      minScore: 20,
    );
    selectNewCountry(); // Global fonksiyon: Yeni soru seçer ve butonları karıştırır
  }

  /// Cevabı kontrol eder
  /// [answer]: Kullanıcının girdiği metin
  /// [buttonIndex]: Eğer butona basıldıysa indexi (0-3), SearchField ise rastgele bir sayı (örn: 4) gelebilir.
  /// Return: Doğru bildi mi? (true/false)
  bool processAnswer(String answer, int buttonIndex) {
    // Cevap kontrolü (Global 'kalici' değişkeni üzerinden)
    bool isCorrect = targetCountry.checkAnswer(answer.trim(),AppState.settings.language);

    if (isCorrect) {
      // Doğruysa:
      AppState.session.submitCorrect();
      GameLogService.saveToStorage("capital");
      selectNewCountry(); // Yeni soruya geç
      return true;
    } else {
      // Yanlışsa:
      AppState.session.submitWrong();

      // Eğer buton modundaysak ve geçerli bir index geldiyse o butonu pasif yap
      if (buttonIndex >= 0 && buttonIndex < 4) {
        isButtonActive[buttonIndex] = false; // Global değişkeni güncelle
      }
      return false;
    }
  }

  /// Pas geçme işlemini yönetir
  /// Return: Pas geçilen ülkenin ismi (Ekranda göstermek için)
  String handlePass() {
    AppState.session.submitPass();

    String passCountryName = targetCountry.getLocalizedName(Localization.currentLanguage);

    selectNewCountry();
    return passCountryName;
  }
}