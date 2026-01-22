// lib/widgets/flag_loader.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bayrak görsellerini yükleyen yardımcı widget.
/// Önce assets'ten, başarısız olursa network'ten yükler.
class FlagLoader {
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
    bool exists = false;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      exists = manifest.listAssets().contains(assetPath);
    } catch (_) {
      exists = false;
    }

    Widget image;
    if (exists) {
      image = Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _networkImage(flagUrl, size, fit),
      );
    } else {
      image = _networkImage(flagUrl, size, fit);
    }

    return circular ? ClipOval(child: image) : image;
  }

  /// Network'ten bayrak yükler (fallback).
  static Widget _networkImage(String url, double size, BoxFit fit) {
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
    final String assetPath = 'assets/flags/${iso2.toLowerCase()}.webp';
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().contains(assetPath);
    } catch (e) {
      return false;
    }
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
}
