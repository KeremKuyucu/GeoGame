import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Merkezi reklam yönetim servisi.
///
/// Banner, interstitial ve rewarded reklamları yönetir.
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

  // --- Ad Unit ID'leri ---

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4674396016131447/1324822353';
    }

    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4674396016131447/3683287187';
    }

    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4674396016131447/6822074506';
    }

    return '';
  }

  // --- Interstitial ---

  static DateTime? _lastInterstitialShowTime;

  static const Duration _interstitialCooldown = Duration(minutes: 3);

  static InterstitialAd? _interstitialAd;

  static bool _isInterstitialLoading = false;

  // --- Rewarded ---

  static RewardedAd? _rewardedAd;

  static bool _isRewardedLoading = false;

  // --- SDK Başlatma ---

  /// Google Mobile Ads SDK'sını başlatır ve reklamları
  /// arka planda yüklemeye başlar.
  static Future<void> initialize() async {
    if (!isSupported) return;

    try {
      await MobileAds.instance.initialize();

      debugPrint(
        'AdService: MobileAds SDK başlatıldı',
      );

      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint(
        'AdService: SDK başlatma hatası: $e',
      );
    }
  }

  // --- Banner ---

  /// Yeni bir BannerAd oluşturur.
  ///
  /// Çağıran widget banner'ın load ve dispose işlemlerinden
  /// sorumludur.
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
          debugPrint(
            'AdService: Banner reklam yüklendi',
          );

          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'AdService: Banner yükleme hatası: $error',
          );

          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // --- Interstitial ---

  /// Interstitial reklamı arka planda yükler.
  static void _loadInterstitialAd() {
    if (!isSupported || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;

          debugPrint(
            'AdService: Interstitial reklam yüklendi',
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;

          debugPrint(
            'AdService: Interstitial yükleme hatası: $error',
          );
        },
      ),
    );
  }

  /// Interstitial reklamı gösterir.
  ///
  /// Reklamlar arasında 3 dakika cooldown uygulanır.
  static Future<bool> showInterstitialAd() async {
    if (!isSupported) return false;

    // Cooldown kontrolü
    if (_lastInterstitialShowTime != null) {
      final elapsed = DateTime.now().difference(
        _lastInterstitialShowTime!,
      );

      if (elapsed < _interstitialCooldown) {
        final remaining = _interstitialCooldown - elapsed;

        debugPrint(
          'AdService: Interstitial cooldown aktif '
          '(${remaining.inMinutes} dk kaldı)',
        );

        return false;
      }
    }

    final ad = _interstitialAd;

    if (ad == null) {
      debugPrint(
        'AdService: Interstitial reklam hazır değil',
      );

      _loadInterstitialAd();
      return false;
    }

    // Reklam artık kullanılacak.
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(
          'AdService: Interstitial reklam gösteriliyor',
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (
        ad,
        error,
      ) {
        debugPrint(
          'AdService: Interstitial gösterim hatası: $error',
        );

        ad.dispose();
        _loadInterstitialAd();
      },
    );

    try {
      await ad.show();

      _lastInterstitialShowTime = DateTime.now();

      debugPrint(
        'AdService: Interstitial reklam gösterildi',
      );

      return true;
    } catch (e) {
      debugPrint(
        'AdService: Interstitial show() exception: $e',
      );

      ad.dispose();
      _loadInterstitialAd();

      return false;
    }
  }

  // --- Rewarded ---

  /// Ödüllü reklamın hazır olup olmadığını bildirir.
  static bool get isRewardedAdReady => _rewardedAd != null;

  /// Ödüllü reklamı arka planda yükler.
  static void _loadRewardedAd() {
    if (!isSupported || _isRewardedLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;

          debugPrint(
            'AdService: Rewarded reklam yüklendi',
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;

          debugPrint(
            'AdService: Rewarded yükleme hatası: $error',
          );
        },
      ),
    );
  }

  /// Ödüllü reklamı gösterir.
  ///
  /// Reklam tamamlandığında [onRewarded] callback'i
  /// çalıştırılır.
  static Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
  }) async {
    if (!isSupported) return false;

    final ad = _rewardedAd;

    if (ad == null) {
      debugPrint(
        'AdService: Rewarded reklam hazır değil',
      );

      _loadRewardedAd();
      return false;
    }

    // Reklam artık kullanılacak.
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(
          'AdService: Rewarded reklam gösteriliyor',
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
          'AdService: Rewarded reklam kapatıldı',
        );

        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (
        ad,
        error,
      ) {
        debugPrint(
          'AdService: Rewarded gösterim hatası: $error',
        );

        ad.dispose();
        _loadRewardedAd();
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (
          AdWithoutView ad,
          RewardItem reward,
        ) {
          debugPrint(
            'AdService: Kullanıcı ödülü kazandı: '
            '${reward.amount} ${reward.type}',
          );

          onRewarded();
        },
      );

      return true;
    } catch (e) {
      debugPrint(
        'AdService: Rewarded show() exception: $e',
      );

      ad.dispose();
      _loadRewardedAd();

      return false;
    }
  }

  // --- Dispose ---

  /// Tüm reklam kaynaklarını serbest bırakır.
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;

    _isInterstitialLoading = false;
    _isRewardedLoading = false;
  }
}
