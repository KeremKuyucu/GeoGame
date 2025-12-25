import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/app_context.dart'; // AppState, GameStats, GameFilter burada
import 'auth_service.dart'; // AuthService burada

class StorageService {
  static final _supabase = Supabase.instance.client;

  /// 📂 Yerel Dosyadan Oku ve AppState'i Güncelle
  static Future<void> loadLocalData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/geogame_v2.json');

      if (!await file.exists()) {
        debugPrint('⚠️ Dosya bulunamadı, varsayılanlar oluşturuluyor.');
        await saveLocalData();
        return;
      }

      final contents = await file.readAsString();
      final data = jsonDecode(contents);

      // 1. Ayarları Yükle
      AppState.settings = AppSettings(
        darkTheme: data['darkTheme'] ?? true,
        language: data['languageCode'] ?? 'tr',
      );

      // 2. Filtreleri Yükle
      AppState.filter = GameFilter(
        amerika: data['amerika'] ?? true,
        asya: data['asya'] ?? true,
        afrika: data['afrika'] ?? true,
        avrupa: data['avrupa'] ?? true,
        okyanusya: data['okyanusya'] ?? true,
        antarktika: data['antarktika'] ?? true,
        isButtonMode: data['isButtonMode'] ?? true,
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

      // 4. (Opsiyonel) Yerel Kullanıcı Önbelleğini Yükle
      // Offline modda isim ve avatar gözüksün diye
      if (data['uid'] != null) {
        // AppState.user güncellemesi yapılabilir, ama asıl yetki AuthService'de.
      }

      debugPrint("✅ Yerel veriler AppState'e yüklendi.");

      // Eğer internet ve oturum varsa senkronize et
      if (AuthService.isAuthenticated) {
        await syncWithCloud();
      }

    } catch (e) {
      debugPrint('❌ Kritik Dosya Okuma Hatası: $e');
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
        'languageCode': AppState.settings.language,

        // Filter
        'amerika': AppState.filter.amerika,
        'asya': AppState.filter.asya,
        'afrika': AppState.filter.afrika,
        'avrupa': AppState.filter.avrupa,
        'okyanusya': AppState.filter.okyanusya,
        'antarktika': AppState.filter.antarktika,
        'isButtonMode': AppState.filter.isButtonMode,
        'unFilterIndex': AppState.filter.unFilter.index,

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

      };

      await file.writeAsString(jsonEncode(data));
      debugPrint("💾 Veriler yerel dosyaya yazıldı.");

    } catch (e) {
      debugPrint('❌ Dosya yazma hatası: $e');
    }
  }

  /// ☁️ Bulut Senkronizasyonu
  static Future<void> syncWithCloud() async {
    // 🛠️ DÜZELTME: 'user.uid' yerine AuthService kullanıyoruz
    final uid = AuthService.currentUserId;

    if (uid == null) {
      debugPrint("⚠️ Sync iptal: Kullanıcı girişi yok.");
      return;
    }

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

      final int cloudScore = (response['puan'] ?? 0) as int;
      final int localScore = AppState.stats.totalScore;

      debugPrint('🔄 Sync: Bulut($cloudScore) vs Yerel($localScore)');

      // 1. Durum: Yerel Puan Daha Yüksek -> Buluta Yükle
      if (localScore > cloudScore) {
        debugPrint('🚀 Yerel skor yüksek -> Buluta gönderiliyor.');
        await _uploadToCloud();
      }
      // 2. Durum: Bulut Puanı Daha Yüksek -> Yerele İndir
      else if (cloudScore > localScore) {
        debugPrint('📥 Bulut skor yüksek -> Yerele indiriliyor.');

        AppState.stats = GameStats(
          mesafePuan: (response['mesafepuan'] ?? 0) as int,
          bayrakPuan: (response['bayrakpuan'] ?? 0) as int,
          baskentPuan: (response['baskentpuan'] ?? 0) as int,

          mesafeDogru: (response['mesafedogru'] ?? 0) as int,
          mesafeYanlis: (response['mesafeyanlis'] ?? 0) as int,

          bayrakDogru: (response['bayrakdogru'] ?? 0) as int,
          bayrakYanlis: (response['bayrakyanlis'] ?? 0) as int,

          baskentDogru: (response['baskentdogru'] ?? 0) as int,
          baskentYanlis: (response['baskentyanlis'] ?? 0) as int,
        );

        await saveLocalData();
      }
      else {
        debugPrint('✅ Puanlar eşit, senkronizasyon tamam.');
      }

    } catch (e) {
      debugPrint('❌ Sync Hatası: $e');
    }
  }

  static Future<void> _uploadToCloud() async {
    // 🛠️ DÜZELTME: Session kontrolü yerine AuthService ID kontrolü
    final uid = AuthService.currentUserId;
    if (uid == null) return;

    final stats = AppState.stats;

    try {
      await _supabase.from('geogame_stats').upsert({
        'user_id': uid, // Session'dan değil, direkt ID'den
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

      debugPrint("☁️ Veriler buluta başarıyla yüklendi.");
    } catch (e) {
      debugPrint("❌ Bulut Yükleme Hatası: $e");
    }
  }
}