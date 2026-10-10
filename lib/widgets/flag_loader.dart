// lib/widgets/flag_loader.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bayrak görsellerini yükleyen yardımcı widget.
/// Önce assets'ten, başarısız olursa network'ten yükler.
class FlagLoader {
  static Set<String>? _cachedFlagAssets;

  /// Manifest'i bir kez yükleyip bayrak yollarını bellekte tutar.
  static Future<Set<String>> _getFlagAssets() async {
    if (_cachedFlagAssets != null) return _cachedFlagAssets!;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _cachedFlagAssets = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/flags/'))
          .toSet();
    } catch (_) {
      _cachedFlagAssets = <String>{};
    }
    return _cachedFlagAssets!;
  }

  /// Manifest bellekte mi kontrolü.
  static bool get hasCachedManifest => _cachedFlagAssets != null;

  /// Senkron olarak yerel asset kontrolü (manifest önbelleklenmişse çalışır).
  static bool isFlagCachedSync(String iso2) {
    if (_cachedFlagAssets == null) return false;
    return _cachedFlagAssets!.contains('assets/flags/${iso2.toLowerCase()}.webp');
  }

  /// Bayrak widget'ını async olarak yükler.
  /// Önce local asset kontrol edilir, yoksa network'ten yüklenir.
  static Future<Widget> loadFlag({
    required String iso2,
    required String flagUrl,
    double size = 40,
    BoxFit fit = BoxFit.cover,
    bool circular = true,
  }) async {
    final assetPath = 'assets/flags/${iso2.toLowerCase()}.webp';
    final assets = await _getFlagAssets();
    final bool exists = assets.contains(assetPath);

    final Widget image = exists
        ? Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                buildNetworkImage(flagUrl, size, fit),
          )
        : buildNetworkImage(flagUrl, size, fit);

    return circular ? ClipOval(child: image) : image;
  }

  /// Network'ten bayrak yükler (fallback).
  static Widget buildNetworkImage(String url, double size, BoxFit fit) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.flag, size: size * 0.6),
    );
  }

  /// Asset'te bayrak var mı kontrol eder.
  static Future<bool> checkFlagAsset(String iso2) async {
    final assets = await _getFlagAssets();
    final String assetPath = 'assets/flags/${iso2.toLowerCase()}.webp';
    return assets.contains(assetPath);
  }

  /// Büyük bayrak görüntüsü widget'ı oluşturur (oyun ekranları için).
  static Widget buildFlagImage({
    required bool existsLocally,
    required String iso2,
    required String url,
    double? width,
    double height = 250,
    BoxFit fit = BoxFit.contain,
  }) {
    if (existsLocally) {
      return Image.asset(
        'assets/flags/${iso2.toLowerCase()}.webp',
        width: width ?? double.infinity,
        height: height,
        fit: fit,
      );
    } else {
      return Image.network(
        url,
        width: width ?? double.infinity,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.flag, size: height * 0.4),
      );
    }
  }
}

/// FutureBuilder ile kullanılabilecek bayrak widget'ı.
/// Manifest önbellekteyse FutureBuilder beklemeden anında senkron çizer.
class FlagWidget extends StatelessWidget {
  final String iso2;
  final String flagUrl;
  final double size;
  final bool circular;

  const FlagWidget({
    super.key,
    required this.iso2,
    required this.flagUrl,
    this.size = 40,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    if (FlagLoader.hasCachedManifest) {
      final exists = FlagLoader.isFlagCachedSync(iso2);
      final assetPath = 'assets/flags/${iso2.toLowerCase()}.webp';
      final Widget image = exists
          ? Image.asset(
              assetPath,
              width: size,
              height: size,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  FlagLoader.buildNetworkImage(flagUrl, size, fit),
            )
          : FlagLoader.buildNetworkImage(flagUrl, size, fit);

      return circular ? ClipOval(child: image) : image;
    }

    return FutureBuilder<Widget>(
      future: FlagLoader.loadFlag(
        iso2: iso2,
        flagUrl: flagUrl,
        size: size,
        circular: circular,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Icon(Icons.flag, size: size * 0.6);
        }
      },
    );
  }

  BoxFit get fit => BoxFit.cover;
}
