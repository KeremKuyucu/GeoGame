## 📦 Version 1.6.1 – Infrastructure Refactoring & Build Optimizations

### 🚀 Changes

* **Application Architecture Refactoring:**
  Implemented a new, clean project structure with core services, data models, and comprehensive unit tests to ensure high maintainability and reliability.
* **Android Build Optimizations:**
  Added comprehensive Android build configuration, which includes secure signing credentials, ABI splits for reduced APK size, and enabled core library desugaring for better modern Java API support.
* **Vercel Integration:**
  Configured routing and added a health check endpoint for seamless Vercel deployment.
* **Performance Improvements:**
  Applied `const` constructors across `GameMetadata` configurations to optimize widget rebuilds and overall Flutter performance.

### 🐛 Bug Fixes

* Resolved missing `const` identifier linter errors that caused warnings during compilation.

---

## 📦 Sürüm 1.6.1 – Altyapı Yenileme ve Derleme Optimizasyonları

### 🚀 Değişiklikler

* **Uygulama Mimarisi Yeniden Yapılandırması:**
  Yüksek sürdürülebilirlik ve güvenilirlik sağlamak amacıyla temel servisler, veri modelleri ve kapsamlı birim testleriyle yeni ve temiz bir proje yapısı uygulandı.
* **Android Derleme Optimizasyonları:**
  Güvenli imzalama kimlik bilgileri, APK boyutunu küçültmek için ABI ayırma (ABI splits) ve modern Java API desteği için "core library desugaring" özelliklerini içeren kapsamlı Android derleme yapılandırması eklendi.
* **Vercel Entegrasyonu:**
  Sorunsuz Vercel dağıtımı için yönlendirmeler yapılandırıldı ve sağlık kontrolü (health check) uç noktası eklendi.
* **Performans İyileştirmeleri:**
  Widget yeniden oluşturma (rebuild) süreçlerini ve genel Flutter performansını optimize etmek için `GameMetadata` öğelerinde `const` düzenlemeleri yapıldı.

### 🐛 Hata Düzeltmeleri

* Derleme sırasında uyarılara neden olan eksik `const` linter hataları giderildi.
