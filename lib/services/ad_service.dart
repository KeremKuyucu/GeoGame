import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Merkezi reklam yönetim servisi.
/// Banner ve interstitial reklamları yönetir.
/// Sadece Android/iOS platformlarında aktif olur.
class AdService {
  AdService._();

  // --- Platform Kontrolü ---
  /// Reklamların desteklenip desteklenmediğini kontrol eder.
  /// Web ve desktop platformlarında false döner.
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // --- Test Ad Unit ID'leri ---
  // Yayında gerçek ID'ler ile değiştirilmeli
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4674396016131447/1324822353'; // Android test banner
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4674396016131447/3683287187'; // Android test interstitial
    }
    return '';
  }

  // --- Interstitial Cooldown ---
  static DateTime? _lastInterstitialShowTime;
  static const Duration _interstitialCooldown = Duration(minutes: 5);

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  /// SDK'yı başlatır ve ilk interstitial reklamı yükler.
  static Future<void> initialize() async {
    if (!isSupported) return;

    try {
      await MobileAds.instance.initialize();
      debugPrint('AdService: MobileAds SDK başlatıldı');
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: SDK başlatma hatası: $e');
    }
  }

  // --- Banner Reklam ---

  /// Yeni bir BannerAd oluşturur.
  /// Çağıran widget kendi banner'ını yönetmelidir (load & dispose).
  static BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdService: Banner reklam yüklendi');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner yükleme hatası: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // --- Interstitial Reklam ---

  /// Interstitial reklamı arka planda yükler.
  static void _loadInterstitialAd() {
    if (!isSupported || _isInterstitialLoading) return;

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('AdService: Interstitial reklam yüklendi');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('AdService: Interstitial yükleme hatası: $error');
        },
      ),
    );
  }

  /// Interstitial reklamı gösterir.
  /// 5 dakika cooldown kontrolü yapar.
  /// Reklam gösterildikten sonra otomatik olarak yenisini yükler.
  /// Geri dönüş: reklam gösterilip gösterilmediği.
  static Future<bool> showInterstitialAd() async {
    if (!isSupported) return false;

    // 5 dakika cooldown kontrolü
    if (_lastInterstitialShowTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShowTime!);
      if (elapsed < _interstitialCooldown) {
        debugPrint(
            'AdService: Interstitial cooldown aktif (${_interstitialCooldown.inMinutes - elapsed.inMinutes} dk kaldı)');
        return false;
      }
    }

    // Reklam hazır mı?
    if (_interstitialAd == null) {
      debugPrint('AdService: Interstitial reklam hazır değil');
      _loadInterstitialAd(); // Tekrar yüklemeyi dene
      return false;
    }

    // Callback'leri ayarla
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // Yeni reklam yükle
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial gösterim hatası: $error');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    // Reklamı göster
    await _interstitialAd!.show();
    _lastInterstitialShowTime = DateTime.now();
    debugPrint('AdService: Interstitial reklam gösterildi');
    return true;
  }

  /// Tüm kaynakları serbest bırakır.
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
