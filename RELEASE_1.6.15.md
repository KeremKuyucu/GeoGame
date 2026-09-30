## 📦 Version 1.6.15 – CI/CD Pipeline Automation & Automated Release Management

### 🚀 Changes

* **Automated CI/CD Release Workflow:**
  Introduced a comprehensive GitHub Actions release workflow (`release.yml`) featuring automated Android signing, parameterized Windows installer generation (`InnoSetup.iss`), and robust web deployments via Vercel CLI.

* **Automated Release Notes Generation Engine:**
  Added a powerful release notes generator (`generate_release_notes.py` and `generate-release-notes.ps1`) supporting integration with the Gemini API and agy CLI to seamlessly synthesize commit history into detailed release documentation.

* **Configuration & Security Hardening:**
  Refactored project configurations by relocating Vercel project settings to `web/.vercel/`, updating workflow permissions, improving secret handling with inline environment variables, and establishing safe console encoding and certificate verification mechanisms.

### 🐛 Bug Fixes

* Fixed secret encoding issues involving Byte Order Marks (BOM) during CI execution.
* Resolved Windows certificate import and self-signed root verification issues in the installer build pipeline.
* Fixed base64 decoding parameters in CI scripts.

### ⚠️ Breaking Changes (if any)

* None.

---

## 📦 Sürüm 1.6.15 – CI/CD Süreci Otomasyonu ve Akıllı Sürüm Yönetimi

### 🚀 Değişiklikler

* **Otomatik CI/CD Sürüm İş Akışı:**
  Android imzalama, parametrelendirilmiş Windows kurulum paketi oluşturma (`InnoSetup.iss`) ve Vercel CLI ile güvenilir web dağıtımları içeren kapsamlı bir GitHub Actions iş akışı (`release.yml`) eklendi.

* **Yapay Zeka Destekli Sürüm Notları Motoru:**
  Commit geçmişini detaylı sürüm belgelerine dönüştürmek için Gemini API ve agy CLI entegrasyonunu destekleyen yeni bir sürüm notu üreticisi (`generate_release_notes.py` ve `generate-release-notes.ps1`) eklendi.

* **Yapılandırma ve Güvenlik İyileştirmeleri:**
  Vercel proje ayarları `web/.vercel/` altına taşındı, iş akışı yetkileri güncellendi, ortam değişkenleriyle güvenli gizli veri yönetimi sağlandı ve konsol kodlaması ile sertifika doğrulama mekanizmaları iyileştirildi.

### 🐛 Hata Düzeltmeleri

* CI yürütülmesi sırasında gizli anahtarlarda oluşan Bayt Sırası İşareti (BOM) kodlama sorunları düzeltildi.
* Yükleyici derleme hattındaki Windows sertifika içe aktarma ve kök doğrulama hataları giderildi.
* CI betiklerindeki base64 çözme parametreleri düzeltildi.

### ⚠️ Kırıcı Değişiklikler (varsa)

* Yok.