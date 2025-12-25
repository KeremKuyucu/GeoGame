import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_context.dart';

// Önceki cevaptaki sınıfların olduğu dosyayı import etmelisin
// import 'app_state.dart';

class StorageService {
  static final _supabase = Supabase.instance.client;

  /// 📂 Yerel Dosyadan Oku ve AppState'i Güncelle
  static Future<void> loadLocalData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/geogame_v2.json'); // v2 ile temiz başlangıç

      if (!await file.exists()) {
        debugPrint('⚠️ Dosya bulunamadı, varsayılanlar kullanılacak.');
        await saveLocalData(); // Varsayılan dosyayı oluştur
        return;
      }

      final contents = await file.readAsString();
      final data = jsonDecode(contents);

      // 1. Ayarları Yükle
      AppState.settings = AppSettings(
        darkTheme: data['darkTheme'] ?? true,
        languageCode: data['languageCode'] ?? 'tr',
      );

      // 2. Filtreleri Yükle (Enum dönüşümüne dikkat!)
      AppState.filter = GameFilter(
        amerika: data['amerika'] ?? true,
        asya: data['asya'] ?? true,
        afrika: data['afrika'] ?? true,
        avrupa: data['avrupa'] ?? true,
        okyanusya: data['okyanusya'] ?? true,
        antarktika: data['antarktika'] ?? true,
        yazmaModu: data['yazmaModu'] ?? true,
        // Integer'dan Enum'a çeviriyoruz
        unFilter: UnFilterStatus.values[data['unFilterIndex'] ?? 0],
      );

      // 3. İstatistikleri Yükle
      AppState.stats = GameStats(
        mesafeDogru: data['mesafeDogru'] ?? 0,
        mesafeYanlis: data['mesafeYanlis'] ?? 0,
        bayrakDogru: data['bayrakDogru'] ?? 0,
        bayrakYanlis: data['bayrakYanlis'] ?? 0,
        baskentDogru: data['baskentDogru'] ?? 0,
        baskentYanlis: data['baskentYanlis'] ?? 0,
        mesafePuan: data['mesafePuan'] ?? 0,
        bayrakPuan: data['bayrakPuan'] ?? 0,
        baskentPuan: data['baskentPuan'] ?? 0,
      );

      // 4. Kullanıcı Bilgisi (Sadece yerel cache, asıl doğrulama Supabase Auth'dan gelir)
      AppState.user = UserProfile(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        avatarUrl: data['avatarUrl'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
      );

      debugPrint("✅ Yerel veriler AppState'e yüklendi.");

      // Kullanıcı giriş yapmışsa senkronizasyonu başlat
      if (AppState.user.isLoggedIn) {
        await syncWithCloud();
      }

    } catch (e) {
      debugPrint('❌ Kritik Dosya Okuma Hatası: $e');
      // Hata durumunda dosyayı silip sıfırlamak bir seçenek olabilir
    }
  }

  /// 💾 AppState'i Yerel Dosyaya Kaydet
  static Future<void> saveLocalData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/geogame_v2.json');

      final data = {
        // Settings
        'darkTheme': AppState.settings.darkTheme,
        'languageCode': AppState.settings.languageCode,

        // Filter
        'amerika': AppState.filter.amerika,
        'asya': AppState.filter.asya,
        'afrika': AppState.filter.afrika,
        'avrupa': AppState.filter.avrupa,
        'okyanusya': AppState.filter.okyanusya,
        'antarktika': AppState.filter.antarktika,
        'yazmaModu': AppState.filter.yazmaModu,
        'unFilterIndex': AppState.filter.unFilter.index, // Enum -> int

        // Stats
        'mesafeDogru': AppState.stats.mesafeDogru,
        'mesafeYanlis': AppState.stats.mesafeYanlis,
        'bayrakDogru': AppState.stats.bayrakDogru,
        'bayrakYanlis': AppState.stats.bayrakYanlis,
        'baskentDogru': AppState.stats.baskentDogru,
        'baskentYanlis': AppState.stats.baskentYanlis,
        'mesafePuan': AppState.stats.mesafePuan,
        'bayrakPuan': AppState.stats.bayrakPuan,
        'baskentPuan': AppState.stats.baskentPuan,
        'toplamPuan': AppState.stats.totalScore,

        // User
        'uid': AppState.user.uid,
        'name': AppState.user.name,
        'avatarUrl': AppState.user.avatarUrl,
      };

      await file.writeAsString(jsonEncode(data));
      debugPrint("💾 Veriler yerel dosyaya yazıldı.");

    } catch (e) {
      debugPrint('❌ Dosya yazma hatası: $e');
    }
  }

  /// ☁️ Bulut Senkronizasyonu (Mantık Güncellendi)
  static Future<void> syncWithCloud() async {
    final uid = AppState.user.uid;
    if (uid.isEmpty) return;

    try {
      final response = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (response == null) {
        // Kullanıcı bulutta yoksa, yerel veriyi gönder
        await _uploadToCloud();
        return;
      }

      final int cloudScore = response['puan'] ?? 0;
      final int localScore = AppState.stats.totalScore;

      debugPrint('🔄 Sync Kontrol: Bulut($cloudScore) vs Yerel($localScore)');

      // 1. Durum: Yerel Puan Daha Yüksek -> Buluta Yükle
      if (localScore > cloudScore) {
        debugPrint('🚀 Yerel skor daha yüksek. Bulut güncelleniyor...');
        await _uploadToCloud();
      }
      // 2. Durum: Bulut Puanı Daha Yüksek -> Yerele İndir
      // DİKKAT: Bu basit mantık hala "offline data kaybı" riski taşır ama
      // senin mevcut mantığını class yapısına uyarladım.
      else if (cloudScore > localScore) {
        debugPrint('📥 Bulut skoru daha yüksek. Yerel güncelleniyor...');

        AppState.stats = GameStats(
          mesafePuan: response['mesafepuan'] ?? 0,
          bayrakPuan: response['bayrakpuan'] ?? 0,
          baskentPuan: response['baskentpuan'] ?? 0,

          mesafeDogru: response['mesafedogru'] ?? 0,
          mesafeYanlis: response['mesafeyanlis'] ?? 0,

          bayrakDogru: response['bayrakdogru'] ?? 0,
          bayrakYanlis: response['bayrakyanlis'] ?? 0,

          baskentDogru: response['baskentdogru'] ?? 0,
          baskentYanlis: response['baskentyanlis'] ?? 0,
        );

        await saveLocalData();
      }
      else {
        debugPrint('✅ Veriler senkronize.');
      }

    } catch (e) {
      debugPrint('❌ Sync Hatası: $e');
    }
  }

  static Future<void> _uploadToCloud() async {
    final stats = AppState.stats;

    await _supabase.from('geogame_stats').upsert({
      'user_id': AppState.user.uid,
      'puan': stats.totalScore,

      'mesafepuan': stats.mesafePuan,
      'mesafedogru': stats.mesafeDogru,
      'mesafeyanlis': stats.mesafeYanlis,

      'bayrakpuan': stats.bayrakPuan,
      'bayrakdogru': stats.bayrakDogru,
      'bayrakyanlis': stats.bayrakYanlis,

      'baskentpuan': stats.baskentPuan,
      'baskentdogru': stats.baskentDogru,
      'baskentyanlis': stats.baskentYanlis,

      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }
}