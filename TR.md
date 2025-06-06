# 🌍 GeoGame

<p align="center">
  <a href="README.md">🇬🇧 English</a>
</p>

<p align="center">
  <img src="assets/logo.png" alt="GeoGame Logo" width="200"/>
</p>

<p align="center">
  <img src="https://img.shields.io/github/downloads/keremkuyucu/GeoGame/total?logo=github&style=for-the-badge&color=blue&label=Total%20Downloads"/>
  </p>

---

**GeoGame**, coğrafi bilginizi artırmak için tasarlanmış eğitici bir oyundur. Etkileşimli sınavlar ve mini oyunlarla ülkeler hakkında daha fazla şey öğrenin!

🎮 Başkentler, bayraklar, mesafe tahmini ve daha fazlası!
📱 **Mobil** ve **Windows** uyumlu
🌐 **Türkçe** 🇹🇷 ve **İngilizce** 🇬🇧 dil desteği

---

## 🌐 Web Sitesi

Oyunu oynamak veya güncellemeleri takip etmek için:
➡️ [**GeoGame Web Sitesi**](https://geogame.keremkk.com.tr)

---

## 📦 İndir

Son sürümü indirip GeoGame'i hemen deneyin:
➡️ [**GeoGame - Son Sürüm**](https://github.com/keremkuyucu/GeoGame/releases/latest)

---

## 🧠 Özellikler

* ✅ Ülkelerin başkentleri, bayrakları ve mesafeleri hakkında quizler
* ✅ Kıtaya göre seviyeler: Avrupa, Asya, Afrika ve daha fazlası
* ✅ Discord üzerinden gerçek zamanlı skor tablosu
* ✅ Basit ve kullanıcı dostu arayüz (Material Design)
* ✅ **Mobil** ve **masaüstü (Windows)** desteği
* ✅ Google ile bulut tabanlı giriş sistemi

---

## 🖼️ Ekran Görüntüleri

<p align="center">
  <img src="Resimler/baskentoyun.png" alt="Başkent Oyunu" width="200"/>
  <img src="Resimler/bayrakoyun.png" alt="Bayrak Oyunu" width="200"/>
  <img src="Resimler/mesafeoyun.png" alt="Mesafe Oyunu" width="200"/>
  <img src="Resimler/mainlobi.png" alt="Ana Lobi" width="200"/>
  <img src="Resimler/leadboard.png" alt="Skor Tablosu" width="200"/>
  <img src="Resimler/ulkeler.png" alt="Ülkeler" width="200"/>
  <img src="Resimler/profiles.png" alt="Profil Sayfası" width="200"/>
  <img src="Resimler/settings.png" alt="Ayarlar" width="200"/>
</p>

---

## 🧰 Teknoloji Yığını

| Katman         | Kullanılan Teknolojiler                  |
| -------------- | ---------------------------------------- |
| **Ön Yüz**     | Flutter, Dart                            |
| **Arka Uç**    | Next.js (Vercel üzerinde barındırılıyor) |
| **Giriş**      | Google ile giriş (Firebase & Web App)    |
| **Veritabanı** | Discord Webhook (Skorlar için)           |
| **Web**        | Next.js                                  |

---

## 🧩 Proje Yapısı

GeoGame birden fazla açık kaynaklı depodan oluşur:

| Depo                                                                    | Açıklama                                                           |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [**GeoGame**](https://github.com/keremkuyucu/GeoGame)                   | Mobil ve masaüstü için ana Flutter uygulaması                      |
| [**geogame-api**](https://github.com/keremkuyucu/geogame-api)           | Puan işleme, kullanıcı verisi ve skor güncellemeleri için REST API |
| [**geogame-auth-web**](https://github.com/keremkuyucu/geogame-auth-web) | Google ile giriş ve yönlendirme işlemleri                          |
| [**geogame-cdn**](https://github.com/keremkuyucu/geogame-cdn)           | JSON veriler, ülke bilgileri ve varlıklar için CDN                 |
| [**geogame-website**](https://github.com/keremkuyucu/geogame-website)   | Resmi web sitesi ve tanıtım sayfası                                |
| [**GeoGameCPP**](https://github.com/keremkuyucu/GeoGameCPP)             | GeoGame’in orijinal C++ ile yazılmış ilk versiyonu                 |

---

## 🖥️ Arka Uç İşlevleri

* 📡 Discord Webhook ile **gerçek zamanlı skor güncellemeleri**
* 🔁 Ülke bilgileri ve sorular için **GitHub JSON kaynakları**
* 🧠 Puan doğrulama ve kullanıcı yönetimi için **sunucu tarafı mantığı**
* 🔐 Firebase ve Web Gateway ile **OAuth tabanlı giriş sistemi**

---

## 📜 Lisans

Bu proje **GNU Genel Kamu Lisansı v3.0** ile lisanslanmıştır.
Ayrıntılar için [**LICENSE**](LICENSE) dosyasını inceleyebilirsiniz.

---

## 🙋‍♂️ Geliştirici

Sevgiyle geliştirilmiştir ❤️ [Kerem Kuyucu](https://github.com/keremkuyucu) tarafından

> Öğrenci ve Geliştirici
> 📍 Bilecik, Türkiye
