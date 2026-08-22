## 📦 Version 1.6.2 – Google Sign-In & Supabase Authentication

### 🚀 Changes

* **Google Sign-In Integration:**
  Integrated native Google Sign-In with Supabase authentication (`signInWithIdToken` and OAuth fallback) for fast, secure one-tap registration and login.
* **Automatic Profile & Avatar Sync:**
  Added automatic synchronization of Google user metadata (full name and profile picture) to Supabase `profiles` table and local application state.
* **Modern Auth UI & Google Button:**
  Designed a custom vector Google logo widget (`GoogleLogoWidget`) and glassmorphic `AuthGoogleButton` with loading state feedback.
* **Android Deep Linking Configuration:**
  Configured OAuth callback intent filters in `AndroidManifest.xml` for seamless redirect handling.

### 🐛 Bug Fixes

* Cleaned up redundant imports and enforced final local variable constraints in services.
* Ensured robust profile creation fallback during first-time OAuth sign-in.

---

## 📦 Sürüm 1.6.2 – Google ile Giriş ve Supabase Kimlik Doğrulama

### 🚀 Değişiklikler

* **Google ile Giriş Entegrasyonu:**
  Hızlı ve güvenli tek tıkla kayıt ve giriş için Supabase kimlik doğrulama altyapısıyla yerel Google Sign-In (`signInWithIdToken` ve OAuth fallback) entegre edildi.
* **Otomatik Profil ve Avatar Senkronizasyonu:**
  Google kullanıcı meta verilerinin (ad-soyad ve profil fotoğrafı) Supabase `profiles` tablosuna ve yerel uygulama durumuna otomatik kaydedilmesi sağlandı.
* **Modern Kimlik Doğrulama Arayüzü ve Google Butonu:**
  Özel vektörel Google logo bileşeni (`GoogleLogoWidget`) ve yüklenme durumuna sahip şık `AuthGoogleButton` tasarlandı.
* **Android Deep Link Yapılandırması:**
  Sorunsuz OAuth geri dönüş yönlendirmeleri için `AndroidManifest.xml` dosyasına deep link intent filtreleri eklendi.

### 🐛 Hata Düzeltmeleri

* Servislerdeki gereksiz importlar ve sabit değişken (final) linter uyarıları giderildi.
* İlk kez OAuth ile giriş yapan kullanıcılar için profil oluşturma ve senkronizasyon mekanizması güçlendirildi.
