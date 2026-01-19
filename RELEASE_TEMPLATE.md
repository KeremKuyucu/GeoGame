# Release Template / Sürüm Şablonu

Bu dosyayı yeni sürüm notları yazarken şablon olarak kullanın.
Aşağıdaki şablonu kopyalayıp `[PLACEHOLDER]` kısımlarını doldurun.
Dosya adı RELEASE_X.X.X.md olacak.
---

## 📦 Version [X.X.X] – [Short Title in English]

### 🚀 Changes

* **[Feature/Fix Name]:**
  [Description of the change in English]

* **[Feature/Fix Name]:**
  [Description of the change in English]

* **[Feature/Fix Name]:**
  [Description of the change in English]

### 🐛 Bug Fixes

* [Bug fix description]
* [Bug fix description]

### ⚠️ Breaking Changes (if any)

* [Breaking change description]

---

## 📦 Sürüm [X.X.X] – [Kısa Başlık Türkçe]

### 🚀 Değişiklikler

* **[Özellik/Düzeltme Adı]:**
  [Değişikliğin Türkçe açıklaması]

* **[Özellik/Düzeltme Adı]:**
  [Değişikliğin Türkçe açıklaması]

* **[Özellik/Düzeltme Adı]:**
  [Değişikliğin Türkçe açıklaması]

### 🐛 Hata Düzeltmeleri

* [Hata düzeltmesi açıklaması]
* [Hata düzeltmesi açıklaması]

### ⚠️ Kırıcı Değişiklikler (varsa)

* [Kırıcı değişiklik açıklaması]

---

# Örnek / Example

## 📦 Version 1.5.6 – Architecture Refactoring & Build Automation

### 🚀 Changes

* **Authentication System Refactoring:**
  Separated UI logic from core authentication service with new `AuthUIService` and `AuthScreen` components.

* **Enhanced Build Automation:**
  - Interactive platform selection menu with keyboard navigation
  - GitHub Release automation with smart detection

* **Security Improvements:**
  Android signing credentials moved to external `key.properties` file.

### 🐛 Bug Fixes

* Fixed update notification not appearing on Android devices
* Resolved import dependency issues

---

## 📦 Sürüm 1.5.6 – Mimari Yeniden Yapılandırma ve Derleme Otomasyonu

### 🚀 Değişiklikler

* **Kimlik Doğrulama Sistemi Yeniden Yapılandırması:**
  UI mantığı, yeni `AuthUIService` ve `AuthScreen` bileşenleriyle çekirdek servisten ayrıldı.

* **Gelişmiş Derleme Otomasyonu:**
  - Klavye navigasyonu ile interaktif platform seçim menüsü
  - Akıllı algılamalı GitHub Release otomasyonu

* **Güvenlik İyileştirmeleri:**
  Android imza bilgileri harici `key.properties` dosyasına taşındı.

### 🐛 Hata Düzeltmeleri

* Android cihazlarda güncelleme bildiriminin görünmemesi düzeltildi
* Import bağımlılık sorunları giderildi

---

# Emoji Referansı / Emoji Reference

| Emoji | Kullanım / Usage |
|-------|------------------|
| 📦 | Sürüm başlığı / Version header |
| 🚀 | Yeni özellikler / New features |
| 🐛 | Hata düzeltmeleri / Bug fixes |
| ⚠️ | Kırıcı değişiklikler / Breaking changes |
| 🔒 | Güvenlik / Security |
| ⚡ | Performans / Performance |
| 🎨 | UI/UX değişiklikleri / UI/UX changes |
| 🔧 | Yapılandırma / Configuration |
| 📝 | Dokümantasyon / Documentation |
| 🌐 | Yerelleştirme / Localization |
