## 📦 Version 1.6.4 – Architecture Modularization, Windows OAuth & Single-Instance Deep Linking

### 🚀 Changes

* **Architecture Modularization & Domain Separation:**
  - **`app_context.dart` Clean-up:** Decoupled global `AppState` by relocating specialized models to their respective domain layers.
  - **Game Button Encapsulation:** Extracted `GameButton` into `lib/models/game/game_button.dart` and encapsulated button pool management directly within `GameService`.
  - **Settings Consolidation:** Relocated `AppSettings` and `GameFilter` directly to `SettingsController`, unifying application configuration, filter states, and preferences persistence into a cohesive controller.
  - **Session & Log Integration:** Migrated `GameSession` into `GameLogService`, streamlining game telemetry and score tracking so game modes communicate directly with the log service.
* **Windows Desktop Google OAuth & Deep Linking:**
  - **Dynamic Protocol Registration:** Introduced `WindowsAuthService` to automatically register the `io.supabase.geogame://` protocol scheme in `HKCU\Software\Classes` on Windows launch (works without administrator privileges across both debug and release builds).
  - **Native Single-Instance Forwarding:** Implemented a Win32 single-instance detector in `windows/runner/main.cpp`. When an OAuth callback arrives from the browser, the secondary process forwards the deep link via `WM_COPYDATA` to the running instance, restores and brings the window to the foreground, and exits immediately.
  - **Installer Protocol Support:** Added `[Registry]` configuration in `InnoSetup.iss` to register the custom URI scheme upon installation and clean it up upon uninstallation.
  - **Upgraded Dependencies:** Upgraded `app_links` to `^7.2.1` for improved desktop protocol compatibility.

### 🐛 Bug Fixes

* Resolved Google Sign-In failure on Windows caused by unregistered custom URL protocol schemes.
* Prevented duplicate window spawns on Windows during external browser OAuth redirects.
* Fixed race condition in `AuthScreen` OAuth state listener where authentication callbacks could be blocked during deep-link handling.

---

## 📦 Sürüm 1.6.4 – Mimari Modülerleştirme, Windows OAuth ve Tekil Örnek (Single-Instance) Deep Link

### 🚀 Değişiklikler

* **Mimari Modülerleştirme ve Sorumlulukların Ayrıştırılması:**
  - **`app_context.dart` Sadeleştirmesi:** Genel `AppState` sınıfı temizlenerek yalnızca oyunlara veya ayarlara özel olan modeller ilgili katmanlara taşındı.
  - **Oyun Butonları Kapsülleme:** `GameButton` sınıfı `lib/models/game/game_button.dart` dosyasına ayrıldı; buton üretimi ve durum yönetimi doğrudan `GameService` bünyesine alındı.
  - **Ayarlar Konsolidasyonu:** `AppSettings` ve `GameFilter` modelleri `SettingsController` altına taşındı; ayar yönetimi, filtreler ve tercihlerin kaydedilmesi tek bir yapıda birleştirildi.
  - **Oturum ve Log Entegrasyonu:** `GameSession` sınıfı `GameLogService` içerisine entegre edildi; oyun modlarının oturum ve skor takibi için doğrudan log servisi ile haberleşmesi sağlandı.
* **Windows Masaüstü Google OAuth ve Deep Link Desteği:**
  - **Dinamik Protokol Kaydı:** Windows üzerinde `io.supabase.geogame://` özel URL şemasını kullanıcı düzeyinde (`HKCU\Software\Classes`) otomatik kaydeden `WindowsAuthService` eklendi (geliştirme/debug ve kurulu sürümlerde yönetici izni gerekmeden çalışır).
  - **Yerel Tekil Örnek (Single-Instance) Yönetimi:** `windows/runner/main.cpp` içine Win32 tekil örnek kontrolü eklendi. Tarayıcıdan OAuth geri dönüşü geldiğinde yeni süreç açılmak yerine link `WM_COPYDATA` ile açık olan mevcut pencereye iletilir, pencere öne getirilir ve ikinci süreç hemen sonlandırılır.
  - **Yükleyici Protokol Entegrasyonu:** `InnoSetup.iss` içerisine `[Registry]` kuralları eklenerek kurulum sırasında protokolün Windows'a tanıtılması ve kaldırma esnasında temizlenmesi sağlandı.
  - **Bağımlılık Güncellemesi:** Masaüstü protokol uyumluluğu için `app_links` paketi `^7.2.1` sürümüne güncellendi.

### 🐛 Hata Düzeltmeleri

* Windows platformunda Google ile oturum açıldığında tarayıcının uygulamaya geri dönememesi sorunu giderildi.
* Windows'ta OAuth geri dönüşü sırasında ikinci bir oyun penceresi açılması engellendi; açık olan pencerenin öne gelmesi sağlandı.
* `AuthScreen` üzerindeki kimlik doğrulama dinleyicisinde OAuth dönüşünü engelleyebilen durum kontrolü optimize edildi.
