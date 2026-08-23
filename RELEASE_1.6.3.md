## 📦 Version 1.6.3 – Real-time Auth Sync, Deep Linking & Build Automation

### 🚀 Changes

* **Real-time Profile & Auth Synchronization:**
  - Implemented immediate in-memory user profile updates (`syncUserData`) upon authentication without artificial delays.
  - Added global Supabase auth state listener (`initAuthStateListener`) initialized at app launch to automatically react to session changes, token refresh, and sign-outs.
  - Prioritized display name and avatar resolution across Google metadata, Supabase profile records, and fallback generators.
* **Enhanced OAuth & Deep Linking:**
  - Added real-time OAuth listener in `AuthScreen` to handle web and mobile redirect callbacks smoothly with user notifications and automated home navigation.
  - Configured route resolution fallbacks in `main.dart` for deep linking URLs (`login-callback`, custom scheme redirects).
* **Profile Management Improvements:**
  - Added session validation before profile loading in `ProfilesController`.
  - Improved avatar and username synchronization in `EditProfileController` and `EditProfilePage`.
* **Build & Deployment Automation:**
  - Added Android App Bundle (`.aab`) build and export support in `build-and-deploy.ps1`.
  - Enhanced Windows installer code signing with resilient fallback RFC-3161 timestamp servers.
  - Initialized banner ad lifecycle in `MainScreen`.

### 🐛 Bug Fixes

* Resolved delay issues during profile loading after Google login.
* Fixed deep link routing on mobile redirect callbacks.
* Cleaned up stream subscriptions and prevented memory leaks during authentication disposal.

---

## 📦 Sürüm 1.6.3 – Gerçek Zamanlı Kimlik Senkronizasyonu, Deep Link ve Derleme Otomasyonu

### 🚀 Değişiklikler

* **Gerçek Zamanlı Profil ve Oturum Senkronizasyonu:**
  - Giriş yapıldığında gecikme olmadan anında kullanıcı profilini güncelleyen `syncUserData` mekanizması geliştirildi.
  - Oturum değişiklikleri, token yenilemeleri ve çıkış işlemlerini uygulama genelinde reaktif olarak dinleyen global `initAuthStateListener` eklendi.
  - Google kullanıcı meta verileri, Supabase profil kayıtları ve yedek avatar/isim önceliklendirmesi optimize edildi.
* **Gelişmiş OAuth ve Deep Link Yönetimi:**
  - `AuthScreen` bileşenine OAuth deep link geri dönüşlerini anında yakalayan, başarı bildirimi gösteren ve ana ekrana yönlendiren dinleyici eklendi.
  - `main.dart` üzerinde OAuth geri dönüşleri (`login-callback` ve özel şema yönlendirmeleri) için yönlendirme güvencesi sağlandı.
* **Profil Yönetimi İyileştirmeleri:**
  - `ProfilesController` içinde profil yüklenmeden önce aktif oturum doğrulaması (`checkSession`) eklendi.
  - `EditProfileController` ve profil düzenleme ekranında avatar ve isim senkronizasyonu geliştirildi.
* **Derleme ve Dağıtım Otomasyonu:**
  - `build-and-deploy.ps1` betiğine Android App Bundle (`.aab`) derleme ve kopyalama desteği eklendi.
  - Windows yükleyici imzalaması için çoklu RFC-3161 zaman damgası sunucu desteği eklendi.
  - `MainScreen` üzerinde banner reklam döngüsü entegre edildi.

### 🐛 Hata Düzeltmeleri

* Google girişi sonrası profil bilgilerinin geç yüklenmesi ve boş kalması sorunu giderildi.
* Mobil geri yönlendirmelerde (deep link) yaşanan sayfa bulunamadı durumları çözüldü.
* Kimlik doğrulama ekranı kapatıldığında açık kalan akış dinleyicileri (`StreamSubscription`) temizlendi.
