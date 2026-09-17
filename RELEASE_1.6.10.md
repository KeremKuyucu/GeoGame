## 📦 Version 1.6.10 – Coat of Arms Game Mode, Heraldic Artwork & Deployment Automation

### 🚀 Changes

* **New Game Mode – Coat of Arms Hunt:**
  * Added a brand new quiz game mode where players identify countries from their official national coats of arms and heraldic emblems (`CoatOfArmsGame`, `CoatOfArmsGameController`).
  * Supports dual gameplay modes: 4-choice button mode and autocomplete search keyboard mode with dedicated pass action.
  * Fully integrated into player profile statistics, global leaderboards, and country data models.
  * Introduced `CoatOfArmsLoader` and `CoatOfArmsWidget` with smooth loading indicators and fallback shield icons.

* **Majestic Heraldic Banner Artwork Redesign:**
  * Completely redesigned home screen banners across all 7 game modes (`capital`, `flag`, `coatofarms`, `distance`, `borderline`, `borderpath`, `findmap`).
  * Replaced previous assets with high-resolution, optimized WebP artwork featuring a unified majestic heraldic gold art style.

* **Complete Multilingual Support (7 Languages):**
  * Added full localization for Coat of Arms (titles, descriptions, rules, and tips) across all 7 supported languages: English (`eng`), Turkish (`tur`), German (`deu`), French (`fra`), Portuguese (`por`), Russian (`rus`), and Spanish (`spa`).
  * Standardized game titles and translations across languages (e.g. updating "Başşehir" to "Başkent Avı" in Turkish).

* **GameLogService & Question Telemetry Architecture:**
  * Refactored `GameLogService` to generate unique UUIDv4 question identifiers for clean session tracking.
  * Enhanced Supabase synchronization (`question_logs`) with persistent local queue caching via `SharedPreferences`, preventing data loss during network disconnections.
  * Added robust duplicate detection (PostgreSQL error code 23505) and automated Discord error reporting via `TelemetryService`.

* **Build & Deployment Automation (`build-and-deploy.ps1`):**
  * Added automated Google Play Console AAB upload tool (`scripts/upload_play_store.py`) with support for internal, alpha, beta, and production tracks.
  * Integrated automated extraction of multi-language release notes from `<locale>` tags directly into Google Play releases.
  * Added Vercel CLI automated web deployment with API token validation and interactive login fallback.
  * Introduced pre-flight verification checks for Windows (Inno Setup, SignTool, PFX certificates), Android keystore (`key.properties`), Google Play Service Account JSON, GitHub CLI, and Antigravity CLI.

* **Web Monetization & Deep Linking Infrastructure:**
  * Added `web/app-ads.txt` with publisher verification for AdMob web compliance.
  * Added `web/.well-known/assetlinks.json` configured for Android App Links deep linking verification.
  * Configured proper headers and routing rules in `web/vercel.json` for asset links and ads verification files.

### 🐛 Bug Fixes

* **Windows Build Script Condition Fix:** Fixed parenthesis grouping in `build-and-deploy.ps1` when evaluating search paths for Inno Setup compiler output executables.
* **Country Pool Fallback for Coat of Arms:** Added defensive filtering in `GameService.startNewRound` ensuring only countries with valid coat of arms image URLs are selected, with safe fallback to the global pool if the active regional pool has fewer than 4 valid entries.

---

## 📦 Sürüm 1.6.10 – Arma Avı Oyun Modu, Hanedanlık Banner Tasarımları ve Dağıtım Otomasyonu

### 🚀 Değişiklikler

* **Yeni Oyun Modu – Arma Avı:**
  * Oyuncuların ülkeleri resmi devlet armalarından ve hanedanlık sembollerinden tanıdığı yepyeni bir bilgi yarışması modu eklendi (`CoatOfArmsGame`, `CoatOfArmsGameController`).
  * Çift oynanış modu desteği: 4 şıklı buton modu ve otomatik tamamlamalı arama sunan klavye modu (pas geçme desteğiyle birlikte).
  * Oyuncu profil istatistiklerine, küresel liderlik tablosuna ve ülke veri modellerine tam entegre edildi.
  * Akıcı yükleme animasyonu ve kalkan ikonu hata telafi mekanizmasına sahip `CoatOfArmsLoader` ile `CoatOfArmsWidget` bileşenleri geliştirildi.

* **Hanedanlık Sanatı Tarzında Yenilenen Banner Görselleri:**
  * Ana ekrandaki 7 oyun modunun tamamına ait banner görselleri (`capital`, `flag`, `coatofarms`, `distance`, `borderline`, `borderpath`, `findmap`) sıfırdan yeniden çizildi.
  * Önceki görseller, asil altın heraldik sanat tarzına sahip yüksek çözünürlüklü ve optimize WebP çizimlerle güncellendi.

* **Kapsamlı Çok Dilli Destek (7 Dil):**
  * Desteklenen 7 dilin tamamında (`tur`, `eng`, `deu`, `fra`, `por`, `rus`, `spa`) Arma Avı modu için başlık, açıklama, oyun kuralları ve ipuçları yerelleştirildi.
  * Diller arası terim tutarlılığı sağlandı (ör. Türkçe dilinde "Başşehir" ifadesi "Başkent Avı" olarak standartlaştırıldı).

* **GameLogService ve Soru Telemetrisi Mimarisi:**
  * `GameLogService` mimarisi sadeleştirilerek benzersiz UUIDv4 soru kimlikleri üretimi sağlandı.
  * Çevrimdışı durumlarda veri kaybını önlemek amacıyla `SharedPreferences` tabanlı yerel kuyruk ve Supabase (`question_logs`) arka plan senkronizasyonu güçlendirildi.
  * Mükerrer kayıt koruması (PostgreSQL 23505 hata kodu) ve Discord üzerinden gerçek zamanlı telemetri hata bildirimi eklendi.

* **Derleme ve Dağıtım Otomasyonu (`build-and-deploy.ps1`):**
  * Google Play Console AAB yükleme ve yayınlama aracı (`scripts/upload_play_store.py`) eklendi; internal, alpha, beta ve production kanalları desteklendi.
  * `<locale>` etiketlerinden çok dilli sürüm notlarını otomatik ayrıştırıp Play Store sürümüne ekleyen yapı entegre edildi.
  * Vercel CLI web dağıtım süreci, API token doğrulaması ve oturum yenileme kontrolleriyle otomatikleştirildi.
  * Windows (Inno Setup, SignTool, PFX sertifikası), Android imza bilgileri (`key.properties`), Play Store Service Account JSON, GitHub CLI ve Antigravity CLI için kapsamlı ön kontroller dahil edildi.

* **Web Gelir Modeli ve Derin Bağlantı (Deep Linking) Altyapısı:**
  * AdMob web uyumluluğu ve yayıncı doğrulaması için `web/app-ads.txt` dosyası eklendi.
  * Android Uygulama Bağlantıları (App Links) doğrulaması için `web/.well-known/assetlinks.json` dosyası yapılandırıldı.
  * `web/vercel.json` üzerinde asset links ve app-ads dosyaları için uygun HTTP başlıkları ve yönlendirme kuralları tanımlandı.

### 🐛 Hata Düzeltmeleri

* **Windows Derleme Betiği Koşul Düzeltmesi:** `build-and-deploy.ps1` içinde Inno Setup derleyicisinin çıktı dosyasını ararken oluşan parantezleme ve koşul mantığı hatası düzeltildi.
* **Arma Avı Oyun Havuzu Güvenlik Kontrolü:** `GameService.startNewRound` fonksiyonunda yalnızca geçerli arma görseline sahip ülkelerin seçilmesi garanti altına alındı; aktif bölge havuzunda 4'ten az ülke olması durumunda küresel havuza güvenli geri dönüş sağlandı.
