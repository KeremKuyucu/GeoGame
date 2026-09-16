## 📦 Version 1.6.9 – Global Error Telemetry, Haptic Feedback & UX Polish

### 🚀 Changes

* **Global Error Telemetry & Discord Alerting:**
  * Integrated real-time exception reporting (`TelemetryService.sendError`) connected to Discord bot webhook notifications.
  * Hooked `FlutterError.onError` and `PlatformDispatcher.instance.onError` in `main.dart` to automatically capture and dispatch uncaught UI rendering and async isolate errors with stack traces.

* **Unified Game Navigation & PopScope Integration:**
  * Wrapped `GameScaffold` in `PopScope` to intercept physical/gesture device back buttons across all game modes.
  * Consolidated back and home navigation into `GameScaffold.handleGameExit`, ensuring pending question scores are synchronized to Supabase (`syncPendingLogs`) and interstitial ads are triggered regardless of exit method.

* **Tactile Feedback (`HapticService`):**
  * Introduced native haptic feedback across all game modes (Capital, Flag, Borderline, Distance, FindMap, BorderPath).
  * Tactile feedback provides satisfying light impacts on correct answers, distinct heavy vibrations on incorrect guesses, and smooth selection clicks on passes and path steps.

* **Game UI Simplification & Drawer Scoping:**
  * Removed side drawer from gameplay screens (`GameScaffold`) to prevent accidental drawer openings during map exploration (Distance, FindMap).
  * Replaced the top-left hamburger menu with an intuitive back button (`Icons.arrow_back_ios_new_rounded`).
  * Confined the Drawer exclusively to the four primary dashboard tabs (Games, Leaderboard, Profile, Settings).

* **Play Store Rating & Store Compliance:**
  * Added a "Rate on Play Store" action in `DrawerWidget` with direct Android market URI intent (`market://details?id=com.keremkuyucu.geogame`) and browser fallback.
  * Updated telemetry descriptions from "Anonymous" to "Usage and Diagnostic Data" across all 7 supported languages (`tur`, `eng`, `deu`, `fra`, `por`, `rus`, `spa`) for GDPR/KVKK and Google Play Data Safety compliance.

* **Android Build & Shrinking Optimizations:**
  * Enabled Android R8 optimized resource shrinking (`android.r8.optimizedResourceShrinking=true`).
  * Upgraded Android Gradle Plugin to `8.12.2`.

### 🐛 Bug Fixes

* **Leaderboard Podium Centering Fix:** Resolved an issue where 2nd or 3rd place users with long display names broke the horizontal symmetry and pushed the 1st place podium off-center; podium columns are now bounded to equal 1/3 `Expanded` slots with single-line ellipsis truncation.
* **BorderPath Navigation Cleanup:** Removed redundant controller-level `navigateHome` function and decoupled UI dependencies from `BorderPathGameController`.

---

## 📦 Sürüm 1.6.9 – Global Hata Telemetrisi, Dokunsal Geri Bildirim ve UX İyileştirmeleri

### 🚀 Değişiklikler

* **Global Hata Telemetrisi ve Discord Entegrasyonu:**
  * Gerçek zamanlı Discord webhook bildirimlerini destekleyen `TelemetryService.sendError` altyapısı kuruldu.
  * `main.dart` üzerinde `FlutterError.onError` ve `PlatformDispatcher.instance.onError` kancaları eklenerek tüm UI ve asenkron çökmeler stack trace ile birlikte anlık raporlanabilir hale getirildi.

* **Merkezi Oyun Çıkışı ve PopScope Entegrasyonu:**
  * Tüm oyun ekranları (`GameScaffold`) `PopScope` ile sarmalanarak fiziksel/jest geri tuşu kontrol altına alındı.
  * Oyuncu ister üst bardaki Geri/Home butonlarına bassın ister telefonun geri tuşunu kullansın; puanların Supabase'e aktarılması (`syncPendingLogs`) ve geçiş reklamlarının gösterilmesi `GameScaffold.handleGameExit` altında birleştirildi.

* **Dokunsal Geri Bildirim (`HapticService`):**
  * Tüm oyun modlarına (Başkent, Bayrak, Sınırdaş, Mesafe Avı, Haritada Bul, Sınır Yolu) yerleşik titreşim desteği eklendi.
  * Doğru cevaplarda hafif tatmin edici titreşim, yanlış cevaplarda uyarıcı güçlü titreşim, pas ve rota hamlelerinde mikro dokunuşlar sağlandı.

* **Oyun Arayüzü Sadeleştirmesi ve Drawer Kapsamı:**
  * Harita üzerinde gezinirken yanlışlıkla çekmece menünün açılmasını önlemek amacıyla oyun ekranlarından (`GameScaffold`) Drawer kaldırıldı.
  * Sol üstteki hamburger menü yerine şık bir Geri Oku (`Icons.arrow_back_ios_new_rounded`) yerleştirildi.
  * Çekmece menü yalnızca ana menüdeki 4 ana sekmede (Oyunlar, Liderlik, Profil, Ayarlar) aktif olacak şekilde sınırlandırıldı.

* **Play Store'da Değerlendir Butonu ve Mağaza Uyumluluğu:**
  * Çekmece menüye (`DrawerWidget`) doğrudan Google Play uygulamasını veya web sayfasını açan "Play Store'da Değerlendir" butonu eklendi.
  * Ayarlardaki telemetri başlığı Google Play Veri Güvenliği, KVKK ve GDPR gereksinimlerine tam uyum için desteklenen 7 dilde "Anonim" yerine "Kullanım ve Teşhis Verilerini Paylaş" olarak güncellendi.

* **Android Derleme ve Küçültme Optimizasyonu:**
  * Android R8 optimize kaynak küçültme etkinleştirildi (`android.r8.optimizedResourceShrinking=true`).
  * Android Gradle Eklentisi `8.12.2` sürümüne yükseltildi.

### 🐛 Hata Düzeltmeleri

* **Liderlik Tablosu Podyum Hizalama Düzeltmesi:** 2. veya 3. sıradaki oyuncunun adı uzun olduğunda 1. sıradaki şampiyon podyumunun sağa/sola kayması sorunu giderildi; podyum sütunları eşit `Expanded` genişliklerine sabitlenerek isimler tek satırda zarifçe sınırlandı (`...`).
* **Sınır Yolu Kod Temizliği:** `BorderPathGameController` içindeki gereksiz `navigateHome` fonksiyonu kaldırılarak controller arayüz bağımlılıklarından arındırıldı.
