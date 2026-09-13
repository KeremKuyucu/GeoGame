## 📦 Version 1.6.7 – Automatic System Locale Detection, Seamless OAuth Deep Linking & Architecture Streamlining

### 🚀 Changes

* **Expanded Multilingual Support (5 New Languages):**
  * Added complete native UI translations for **German (Deutsch - deu)**, **Spanish (Español - spa)**, **French (Français - fra)**, **Portuguese (Português - por)**, and **Russian (Русский - rus)** across all game modes, dialogs, settings, authentication, and navigation.
  * Increased actively selectable languages in Settings from 2 to 7.

* **Automatic System Language Detection:**
  * **Intelligent First-Launch Locale Matching:** `Localization.init()` now automatically detects the device's system language via `PlatformDispatcher.instance.locale.languageCode` on initial app launch when no prior language is set.
  * **25-Language ISO Mapping:** Mapped system locale codes to their corresponding ISO-639-3 codes (supporting `eng`, `tur`, `fra`, `deu`, `spa`, `ita`, `rus`, `jpn`, `ara`, `zho`, `kor`, `por`, `nld`, `pol`, `swe`, etc.), gracefully falling back to English for unmapped locales.
  * **Persistent Preference:** Detected locale is automatically saved to persistent storage via `PreferencesService`, avoiding redundant system checks on subsequent launches while respecting manual user overrides.

* **Streamlined Google OAuth & Deep Link Flow:**
  * **Debounced Auth Listeners:** Optimized `AuthService.initAuthStateListener` to synchronize user profile data solely on `signedIn` and `initialSession` events. Excluded periodic `tokenRefreshed` and `userUpdated` events, eliminating redundant Supabase queries and unintended UI rebuild loops.
  * **Flicker-Free Deep Link Callback:** Updated `onGenerateRoute` in `lib/main.dart` to return an instantaneous silent route when deep link callbacks arrive while application data is already loaded in memory, eliminating redundant splash screen reloads.
  * **Android Task Integrity:** Removed `android:taskAffinity=""` from `MainActivity` in `AndroidManifest.xml`, ensuring proper task stack resumption when returning from the external OAuth browser tab.
  * **Separated Auth Concerns:** Refactored `AuthPage` and `AuthController` to decouple the Google sign-in trigger (`AuthService.signInWithGoogle`) from the `onAuthStateChange` routing listener, resolving race conditions and guaranteeing single execution of success snackbars and navigation.

* **Architecture Simplification & Service Cleanup:**
  * **Removed Legacy Update Checker:** Purged `UpdateCheckerService`, its unit test suite, and the app-start update check hooks from `MainScreen`, reducing bundle overhead and startup delay.
  * **Purged Redundant Windows Auth Service:** Removed obsolete `WindowsAuthService` and deprecated deep link route entries (`/login-callback`, `login-callback`), delegating protocol registration to native platform configurations.
  * **De-cluttered UI Chrome:** Removed redundant version text tiles from the Settings page and the navigation drawer header for a cleaner visual presentation.

* **Settings & State Reliability:**
  * **Unified Theme State:** Directly coupled the dark theme switch and label in `SettingsPage` with `SettingsController.isDarkTheme` for deterministic theme toggling.
  * **Profiles Controller Optimization:** Streamlined user name retrieval in `ProfilesController` and removed redundant session re-checks prior to fetching game records and rankings.
  * **Anonymous Avatar Refresh:** Updated default anonymous avatar endpoint in `UserProfile.anonymous()`.

### 🐛 Bug Fixes

* Eliminated infinite UI re-rendering and excessive database calls caused by `tokenRefreshed` and `userUpdated` events in Supabase auth listener.
* Fixed Android task separation and back navigation anomalies during OAuth deep link returns by removing `android:taskAffinity=""`.
* Prevented unnecessary reload of `SplashScreen` when processing OAuth deep links in an already running app instance.
* Updated `AppSettings` test assertions to match the new automatic system locale detection defaults, bringing the test suite to 91/91 passing tests.

---

## 📦 Sürüm 1.6.7 – Otomatik Sistem Dili Algılama, Kesintisiz OAuth Deep Link ve Mimari Sadeleştirme

### 🚀 Değişiklikler

* **Genişletilmiş Çoklu Dil Desteği (5 Yeni Dil):**
  * Tüm oyun modları, iletişim pencereleri, ayarlar, kimlik doğrulama ve gezinti menüleri için eksiksiz yerel çevirilerle **Almanca (Deutsch - deu)**, **İspanyolca (Español - spa)**, **Fransızca (Français - fra)**, **Portekizce (Português - por)** ve **Rusça (Русский - rus)** dilleri eklendi.
  * Ayarlar menüsünde doğrudan seçilebilir dil sayısı 2'den 7'ye çıkarıldı.

* **Otomatik Sistem Dili Algılama:**
  * **Akıllı İlk Açılış Dil Tespiti:** `Localization.init()`, kullanıcı daha önce bir dil seçmemişse ilk açılışta cihazın sistem dilini (`PlatformDispatcher.instance.locale.languageCode`) otomatik olarak algılar.
  * **25 Dil İçin ISO Eşlemesi:** Sistem dil kodları 25 desteklenen dil için ISO-639-3 kodlarına (`eng`, `tur`, `fra`, `deu`, `spa`, `ita`, `rus`, `jpn`, `ara`, `zho`, `kor`, `por`, `nld`, `pol`, `swe` vb.) haritalandı; desteklenmeyen dillerde varsayılan olarak İngilizceye yönlendirilir.
  * **Kalıcı Tercih Kaydı:** Algılanan sistem dili `PreferencesService` aracılığıyla ayarlara otomatik kaydedilir; böylece her açılışta tekrar sorgulanmaz ve kullanıcının manuel dil tercihleri korunur.

* **Google OAuth ve Deep Link Akışı İyileştirmesi:**
  * **Optimize Edilmiş Auth Dinleyicisi:** `AuthService.initAuthStateListener`, kullanıcı verilerini yalnızca `signedIn` ve `initialSession` durumlarında senkronize edecek şekilde filtrelendi. Periyodik olarak tetiklenen `tokenRefreshed` ve `userUpdated` olayları elenerek gereksiz Supabase veritabanı sorguları ve arayüzün döngüsel yeniden çizilmesi engellendi.
  * **Kırpışmasız Deep Link Dönüşü:** Uygulama bellekte çalışırken (`AppState.allCountries.isNotEmpty`) gelen deep link çağrılarında açılış ekranının (Splash) baştan yüklenmesi engellendi; sıfır süreli sessiz bir rota ile doğrudan akıcı geçiş sağlandı.
  * **Android Görev Sürekliliği:** `AndroidManifest.xml` dosyasındaki `MainActivity` üzerinden `android:taskAffinity=""` kaldırılarak harici tarayıcıdan dönen OAuth oturumlarının ayrı bir Android görevine bölünmesi engellendi.
  * **Sadeleştirilmiş Giriş Ekranı:** `AuthPage` üzerindeki Google ile giriş mantığı ile yönlendirme dinleyicisi birbirinden ayrıldı; yarış durumu (race condition) ortadan kaldırılarak bildirimler ve ana sayfaya geçiş tekilleştirildi.

* **Mimari Sadeleştirme ve Servis Temizliği:**
  * **Eski Güncelleme Denetleyicisi Kaldırıldı:** Atıl kalan `UpdateCheckerService` servisi, birim testleri ve ana ekrandaki başlangıç güncelleme kontrol kancaları projeden tamamen temizlendi.
  * **Windows Auth Servisi Temizliği:** Artık ihtiyaç duyulmayan `WindowsAuthService` ve gereksiz rota tanımları (`/login-callback`, `login-callback`) kaldırılarak protokol yönetimi yerel platform yapılandırmasına bırakıldı.
  * **Gereksiz Arayüz Kalabalığı Giderildi:** Ayarlar sayfasındaki ve çekmece (drawer) başlığındaki statik versiyon metinleri kaldırılarak daha modern ve sade bir arayüz sağlandı.

* **Arayüz ve Durum Güvenilirliği:**
  * **Karanlık Tema Tutarlılığı:** `SettingsPage` içerisindeki tema anahtarları ve etiketleri doğrudan `SettingsController.isDarkTheme` durumuna bağlandı; görsel uyumsuzluklar giderildi.
  * **Profil Mantığı Optimizasyonu:** Kullanıcı adı gösterimi sadeleştirildi ve istatistik sorgulamaları öncesindeki gereksiz `checkSession()` çağrıları kaldırıldı.
  * **Anonim Avatar Güncellemesi:** `UserProfile.anonymous()` içindeki varsayılan anonim avatar adresi güncellendi.

### 🐛 Hata Düzeltmeleri

* Supabase auth dinleyicisindeki `tokenRefreshed` ve `userUpdated` tetikleyicilerinin yol açtığı aşırı veritabanı isteği ve UI yeniden çizilme döngüsü giderildi.
* Android'de `taskAffinity=""` kaynaklı harici tarayıcıdan dönüşlerdeki görev ayrışması ve deep link takılmaları düzeltildi.
* OAuth dönüşünde uygulamanın gereksiz yere açılış ekranına (Splash Screen) düşmesi engellendi.
* `AppSettings` birim testleri yeni varsayılan sistem dili algılama değerleriyle uyumlu hale getirildi ve tüm 91 birim testinin başarıyla geçmesi sağlandı.
