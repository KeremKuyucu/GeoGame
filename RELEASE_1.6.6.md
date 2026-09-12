## 📦 Version 1.6.6 – Dynamic Parental Ad Filtering, Instant UI Synchronization & Architecture Cleanups

### 🚀 Changes

* **Dynamic Parental Ad Filtering:**
  * **Smart AdMob Reconfiguration:** Connected AdMob ad request configuration directly to the parental lock (`SettingsController.isChildMode`).
  * **Optimized Revenue for General Audience:** When Child Mode is inactive (default), ads are delivered with standard personalized targeting (`TagForChildDirectedTreatment.no` and `MaxAdContentRating.t`), maximizing eCPM and fill rates.
  * **COPPA & Child Safety on Demand:** Activating Child Mode dynamically switches AdMob to non-personalized child-directed ads (`TagForChildDirectedTreatment.yes` and `MaxAdContentRating.g`).
  * **Advertising ID (AD_ID) Support:** Configured `com.google.android.gms.permission.AD_ID` in AndroidManifest for Google Play compliance with 13+ audience.

* **Instant UI Widget Reload on Mode Switch:**
  * Coupled Child Mode toggle with the app's root reset engine (`RestartWidget.restartApp`), matching the instant reload behavior of language changes.
  * Toggling parental mode now immediately rebuilds the full widget tree, guaranteeing all drawer navigation, tab bars, and game routes update without state discrepancies.

* **Child Mode Consistency Across Game & Guest Views:**
  * **Game Scaffolds Protected:** Side drawer (`DrawerWidget`) is now conditionally hidden in `GameScaffold` across all active game sessions when Child Mode is enabled.
  * **Component Refactoring:** Renamed `profiles_widgets.dart` to `profile_guest_view.dart` for clear architectural responsibility, and applied drawer suppression to guest profiles.

### 🧹 Code Cleanups & Improvements

* Removed obsolete, unused profile update methods (`updatePassword`, `updateEmail`, `updateProfileMetadata`) from `AuthService`.
* Verified all 74 unit tests and resolved static analysis warnings across all platforms.

---

## 📦 Sürüm 1.6.6 – Dinamik Ebeveyn Reklam Filtreleme, Anında UI Yenileme ve Mimari Temizlik

### 🚀 Değişiklikler

* **Dinamik Ebeveyn Reklam Filtreleme:**
  * **Akıllı AdMob Yapılandırması:** AdMob reklam istek ayarları doğrudan ayarlardaki ebeveyn kilidine (`SettingsController.isChildMode`) bağlandı.
  * **Genel Kitle İçin Maksimum Gelir:** Çocuk Modu kapalıyken (varsayılan durum) reklamlar kişiselleştirilmiş hedefleme ve genç/yetişkin derecelendirmesiyle (`TagForChildDirectedTreatment.no`, `MaxAdContentRating.t`) sunularak reklam gelirleri optimize edildi.
  * **İsteğe Bağlı Çocuk Güvenliği:** Ebeveyn kilidi açıldığında reklamlar anında COPPA uyumlu, kişiselleştirilmemiş çocuk moduna (`TagForChildDirectedTreatment.yes`, `MaxAdContentRating.g`) geçer.
  * **Reklam Kimliği (AD_ID) Desteği:** Google Play 13+ hedef kitle politikalarına uygun olarak AndroidManifest'te reklam kimliği izni yapılandırıldı.

* **Mod Değişiminde Anında Widget Yenileme:**
  * Çocuk Modu açma ve kapama işlemleri, dil değiştirmenin kullandığı kök sıfırlama mekanizmasına (`RestartWidget.restartApp`) bağlandı.
  * PIN doğrulamasıyla mod değiştirildiğinde tüm widget ağacı anında baştan oluşturularak gezinti çubuğu, çekmeceler ve oyun rotaları gecikmesiz güncellenir.

* **Oyun ve Misafir Ekranlarında Tutarlılık:**
  * **Oyun İçi Çekmece Koruması:** `GameScaffold` bileşeni güncellenerek Çocuk Modu aktifken oyun içi yan menü (Drawer) erişimi devre dışı bırakıldı.
  * **Bileşen Sadeleştirmesi:** Yanıltıcı isimlendirmeye sahip `profiles_widgets.dart` dosyası amaca uygun olarak `profile_guest_view.dart` şeklinde yeniden adlandırıldı ve yan menü ebeveyn kilidine uyarlandı.

### 🧹 Kod Temizliği ve İyileştirmeler

* `AuthService` içindeki kullanılmayan eski profil güncelleme metodları (`updatePassword`, `updateEmail`, `updateProfileMetadata`) temizlendi.
* 74 birim testinin tamamı başarıyla doğrulandı ve statik analiz uyarıları giderildi.
