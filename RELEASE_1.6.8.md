## 📦 Version 1.6.8 – Granular Question Logging, Adaptive Scoring & Achievement Foundation

### 🚀 Changes

* **Granular Per-Question Logging (`question_logs`):**
  * **Question-Level Telemetry:** Migrated game telemetry from cumulative session summaries to detailed, question-by-question tracking in the new Supabase `public.question_logs` table.
  * **Standardized ISO3 Country Codes:** Every answered question now records the country's official ISO 3166-1 alpha-3 code (`iso3`) for `correct_answer` and question `options` across all game modes (Capital, Flag, Borderline, Distance, BorderPath, FindMap).
  * **Deterministic Question UUIDs:** Generated RFC-compliant UUIDv5 identifiers from a composite seed (`user_id`, `gameType`, `question`, `timestamp`) to prevent duplication and guarantee idempotency.
  * **Offline Queue & Resilient Sync:** Offline question logs are preserved in local storage (`question_logs` key) and synced to Supabase when connected, gracefully handling unique constraint conflicts (`23505`).

* **Adaptive Pool Scoring Multiplier:**
  * **Dynamic Scoring Algorithm:** Introduced `_poolMultiplier()` based on pool ratio `(ratio * 0.7 + 0.3).clamp(0.3, 1.0)`. Playing with filtered continents or custom country pools scales scores proportionally (from 0.3x up to 1.0x).
  * **Balanced Distance Game Penalty:** Capped wrong guess deductions in Distance mode to a maximum of -20 points (`maxPenalty: 20`), preventing disproportionate score penalties on challenging guesses.
  * **Proportional Penalty Scaling:** Scaled wrong answer penalties proportionally at 20% of base round points (`(_startScore * 0.2).round().clamp(1, cap)`).

* **Achievement System Architecture (`AchievementService`):**
  * **Service Foundation:** Implemented `AchievementService` integrated with Supabase RPC `check_achievements()`.
  * **Built-in Achievement Catalog:** Added a local catalog of 40 achievements (Continent Explorers, Mode Masters, Streak Kings, Snipers, and Secret Milestones) with titles, descriptions, emoji icons, and point values.
  * **Premium In-Game Notifications:** Designed a sleek, gold-bordered floating badge notification (`showAchievementNotification`) with haptic feedback, points pill, and glowing emoji icons.

* **Backend & Auth Streamlining:**
  * **Delegated Profile Creation:** Removed client-side `profiles` table inserts from `AuthService`; Supabase database triggers now automatically handle profile creation upon user registration.
  * **UTC Timestamp Normalization:** Standardized all telemetry and question timestamp serialization to strict UTC ISO-8601 strings.

* **Test Suite Expansion:**
  * Added unit test coverage for question session tracking, adaptive pool score calculations, Distance mode penalty ceilings, BorderPath edge cases, and localization keys (103/103 tests passing).

### 🐛 Bug Fixes

* Fixed `checkStandardAnswer` execution halting after question completion by ensuring ISO-8601 string formatting for question start timestamps during JSON serialization.
* Resolved duplicate profile creation attempts during Google OAuth login flow.
* Fixed Distance mode guess tracking by resetting previous attempts on passes and new rounds.

---

## 📦 Sürüm 1.6.8 – Soru Bazlı Loglama, Dinamik Puanlama ve Başarım Altyapısı

### 🚀 Değişiklikler

* **Ayrıntılı Soru Bazlı Loglama (`question_logs`):**
  * **Soru Seviyesinde Telemetri:** Oyun kayıtları toplu oturum özetlerinden, her bir sorunun bağımsız kaydedildiği yeni Supabase `public.question_logs` tablosuna taşındı.
  * **Standart ISO3 Ülke Kodları:** Tüm oyun modlarında (Başkent, Bayrak, Sınırdaş, Mesafe Avı, Sınır Yolu, Haritada Bul) doğru cevaplar (`correct_answer`) ve seçenekler (`options`) artık standart ISO 3166-1 alpha-3 (`iso3`) formatında tutuluyor.
  * **Deterministik Soru UUID'leri:** Tekrarlanan veya çakışan kayıtları önlemek amacıyla kullanıcı ID, oyun modu, soru ve zaman damgasından türetilen deterministik UUIDv5 kimlikleri (`question_id`) oluşturuldu.
  * **Çevrimdışı Kuyruk ve Güvenli Senkronizasyon:** İnternet kesintilerinde sorular yerel hafızada (`question_logs`) tutulur ve bağlantı sağlandığında `23505` çakışma korumasıyla güvenle Supabase'e aktarılır.

* **Dinamik Havuz Puan Çarpanı:**
  * **Akıllı Puanlama Algoritması:** Seçilen ülke havuzunun büyüklüğüne göre dinamik çarpan formülü `(oran * 0.7 + 0.3).clamp(0.3, 1.0)` geliştirildi. Kıta filtresiyle havuz daraltıldığında puanlar adil bir oranda (0.3x ile 1.0x arası) ölçeklenir.
  * **Dengeli Mesafe Avı Cezası:** Mesafe oyunundaki zor tahminlerde puanın aşırı düşmesini engellemek için yanlış tahmin cezası en fazla -20 puanla (`maxPenalty: 20`) sınırlandırıldı.
  * **Orantılı Ceza Mantığı:** Yanlış cevap cezaları başlangıç puanının %20'si oranında (`(_startScore * 0.2).round().clamp(1, cap)`) orantılı hale getirildi.

* **Başarım Sistemi Altyapısı (`AchievementService`):**
  * **Servis Mimarisi:** Supabase `check_achievements()` RPC fonksiyonuyla çalışan `AchievementService` servisi kuruldu.
  * **40 Başarımlık Katalog:** Kıta kâşifleri, seri şampiyonları, keskin nişancılar ve gizli görevleri kapsayan 40 farklı başarım; başlık, açıklama, emoji ve puan bilgileriyle entegre edildi.
  * **Özel Bildirim Tasarımı:** Yeni başarım kazanıldığında ekranda beliren altın çerçeveli, parlayan emoji rozetli ve titreşim destekli şık bildirim arayüzü (`showAchievementNotification`) oluşturuldu.

* **Arka Plan ve Kimlik Doğrulama Sadeleştirmesi:**
  * **Profil Yönetimi Temizliği:** `AuthService` içindeki manuel `profiles` tablosu ekleme kontrolleri kaldırıldı; profil oluşturma süreci tamamen Supabase veritabanı tetikleyicilerine (trigger) devredildi.
  * **UTC Zaman Standardizasyonu:** Telemetri ve loglama zaman damgaları standart UTC ISO-8601 formatına dönüştürüldü.

* **Genişletilmiş Test Kapsamı:**
  * Soru bazlı oturum sayaçları, dinamik havuz çarpanları, mesafe cezaları, sınır yolu uç durumları ve yerelleştirme anahtarları için birim testler eklendi (103/103 test başarıyla geçti).

### 🐛 Hata Düzeltmeleri

* Doğru cevap verildiğinde soru başlangıç zamanının JSON serileştirme hatası nedeniyle sonraki tura geçişi durdurması sorunu (`toIso8601String`) çözüldü.
* Google ile giriş akışında mükerrer profil kaydı oluşturma teşebbüsleri giderildi.
* Mesafe oyununda pas geçildiğinde veya yeni tura başlandığında önceki tahmin listesinin temizlenmesi sağlandı.
