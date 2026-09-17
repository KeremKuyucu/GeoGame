// lib/widgets/coat_of_arms_loader.dart

import 'package:flutter/material.dart';

/// Arma (Coat of Arms) görsellerini yükleyen yardımcı widget.
class CoatOfArmsLoader {
  /// Büyük arma görüntüsü widget'ı oluşturur (oyun ekranları için).
  static Widget buildCoatOfArmsImage({
    required String url,
    double? width,
    double height = 240,
    BoxFit fit = BoxFit.contain,
  }) {
    if (url.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Icon(
            Icons.shield_outlined,
            size: height * 0.45,
            color: Colors.purple.shade200,
          ),
        ),
      );
    }

    return Image.network(
      url,
      width: width ?? double.infinity,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final total = loadingProgress.expectedTotalBytes;
        final loaded = loadingProgress.cumulativeBytesLoaded;
        return SizedBox(
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: total != null ? loaded / total : null,
              strokeWidth: 3,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        child: Center(
          child: Icon(
            Icons.shield_outlined,
            size: height * 0.45,
            color: Colors.purple.shade200,
          ),
        ),
      ),
    );
  }
}

/// Yeniden kullanılabilir küçük/orta boy arma widget'ı.
class CoatOfArmsWidget extends StatelessWidget {
  final String url;
  final double size;

  const CoatOfArmsWidget({
    super.key,
    required this.url,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Icon(Icons.shield_outlined, size: size * 0.7);
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.shield_outlined, size: size * 0.7),
    );
  }
}
