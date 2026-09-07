## 📦 Version 1.6.5 – PIN-Protected Child Mode, Streamlined Google Authentication & Telemetry

### 🚀 Changes

* **PIN-Protected Child Mode:**
  * **Parental Lock:** Introduced a dedicated Child Mode in Settings, protected by a 4-digit numeric PIN. Once activated, it cannot be disabled without re-entering the correct PIN.
  * **Leaderboard Isolation:** Dynamically removes the Leaderboard tab from navigation (`CustomNavBar` and `MainScaffold`) and locks direct page access to provide a distraction-free, safe play environment.
  * **Drawer & External Links Removal:** Completely disables the side menu (Drawer) and external web/social links across all main screens (`MainScreen`, `Profiles`, `Leaderboard`, `Settings`) while Child Mode is active.
  * **Reactive State Updates:** Integrated `AppState.childModeNotifier` to ensure real-time UI synchronization without requiring app restart.
  * **Family Safety & Google Play Readiness:** Structured the app to align with Google Play Families Policy and "Teacher Approved" standards.

* **Streamlined Google Authentication:**
  * Standardized user authentication to Google Sign-In with OAuth / ID Token support across Web, Mobile (Android), and Windows.
  * Removed legacy email/password registration and password reset flows for a faster, one-tap onboarding experience.
  * Removed obsolete Edit Profile page and routes; user names and avatars now sync directly with Google profile data.

* **Telemetry & Startup Performance:**
  * Replaced legacy logging with a non-blocking `TelemetryService` to record daily app open pings with platform mapping (`mobile`, `windows`, `web`).
  * Unblocked initial app startup by running AdMob and Telemetry initialization asynchronously in `main.dart`.

### 🐛 Bug Fixes

* Fixed null-safety type mismatch (`Null is not a subtype of bool`) during settings loading on Flutter Web.
* Standardized static access for `SettingsController.isChildMode` and `childModePin`.
* Resolved missing localized translation strings for dialog actions across Turkish and English.

---

## 📦 Sürüm 1.6.5 – PIN Korumalı Çocuk Modu, Sadeleştirilmiş Google Kimlik Doğrulama ve Telemetri

### 🚀 Değişiklikler

* **PIN Korumalı Çocuk Modu:**
  * **Ebeveyn Kilidi:** Ayarlar ekranına 4 haneli PIN koduyla kilitlenen Çocuk Modu eklendi. Mod aktif edildikten sonra belirlenen PIN girilmeden kapatılamaz.
  * **Sıralama Tablosu İzolasyonu:** Çocuk Modu açıkken Sıralama (Leaderboard) sekmesi alt gezinti çubuğundan (`CustomNavBar` ve `MainScaffold`) dinamik olarak kaldırılır ve erişim kısıtlanır.
  * **Yan Menü ve Dış Bağlantı Koruması:** Çocuk modundayken yan menü (Drawer) ve harici web/sosyal bağlantılar tüm ekranlardan (`MainScreen`, `Profiles`, `Leaderboard`, `Settings`) tamamen gizlenir.
  * **Reaktif Durum Yönetimi:** Mod geçişlerinin anında tüm ekrana yansıması için `AppState.childModeNotifier` entegre edildi.
  * **Öğretmen Onaylı & Aile Politikası Uyumu:** Uygulama Google Play Aile Politikası ve "Öğretmen Onaylı" (Teacher Approved) standartlarına uygun hale getirildi.

* **Sadeleştirilmiş Google ile Giriş:**
  * Kimlik doğrulama süreci Web, Mobil ve Windows üzerinde tek tıkla Google ile Giriş yapısına standardize edildi.
  * E-posta/şifre kayıt ve şifre sıfırlama adımları kaldırılarak hızlı oturum açma deneyimi sağlandı.
  * Eski Profil Düzenleme ekranı ve rotaları kaldırılarak profil adı ve avatarın doğrudan Google verileriyle senkronize olması sağlandı.

* **Telemetri ve Başlatma Performansı:**
  * Eski log yapısı yerine platform bazlı (`mobile`, `windows`, `web`) günlük açılış sayısını anonim takip eden hafif `TelemetryService` eklendi.
  * `main.dart` içindeki AdMob ve telemetri başlatma işlemleri asenkron hale getirilerek uygulama açılışı hızlandırıldı.

### 🐛 Hata Düzeltmeleri

* Flutter Web üzerinde ayarlar yüklenirken oluşan `Null is not a subtype of bool` tip hatası giderildi.
* `SettingsController` üzerindeki `isChildMode` erişimleri standardize edilerek derleme uyarıları çözüldü.
* Türkçe ve İngilizce dil dosyalarında eksik olan genel buton metinleri (`close`, `confirm`) tamamlandı.
