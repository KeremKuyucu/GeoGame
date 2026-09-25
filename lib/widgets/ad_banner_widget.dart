import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:geogame/services/ad_service.dart';

/// Oyun ekranlarının altında gösterilen banner reklam widget'ı.
/// Platform desteklenmiyorsa boş bir widget döner.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AdService.isSupported) return;

    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        debugPrint('AdBannerWidget: Banner yüklendi');

        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint(
          'AdBannerWidget: Banner yüklenemedi: '
          'code=${error.code}, '
          'domain=${error.domain}, '
          'message=${error.message}',
        );

        if (mounted) {
          setState(() {
            _isLoaded = false;
            _bannerAd = null;
          });
        }
      },
    );

    debugPrint('AdBannerWidget: Banner yükleniyor...');

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isSupported || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
