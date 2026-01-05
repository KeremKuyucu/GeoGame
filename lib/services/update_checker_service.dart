import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geogame/services/localization_service.dart';

class UpdateService {
  static const String repoOwner = 'KeremKuyucu';
  static const String repoName = 'GeoGame';

  /// 🚀 Güncelleme Kontrolü
  static Future<void> check(BuildContext context) async {
    // 1. Yerel Versiyon
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;

    try {
      // 2. GitHub API
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Versiyon temizliği (v1.0.0 -> 1.0.0)
        String remoteVersion = (data['tag_name'] as String? ?? '0.0.0').replaceAll(RegExp(r'^v'), '');
        String updateNotes = data['body'] ?? '';
        // 3. Karşılaştırma
        if (localVersion != remoteVersion) {
          if (!context.mounted) return;
          _showUpdateDialog(
            context,
            localVersion,
            remoteVersion,
            updateNotes,
            'https://github.com/$repoOwner/$repoName/releases/latest',
          );
        }
      }
    } catch (e) {
      debugPrint('Güncelleme hatası: $e');
    }
  }

  /// 📱 Diyalog (HTML Paketi Kaldırıldı)
  static void _showUpdateDialog(BuildContext context, String local, String remote, String notes, String url) {
    // Markdown sembollerini basitçe temizleyelim (İsteğe bağlı)
    // Bu basit regex başlıkları (#) ve kalın yazıları (**) temizler, okunaklı düz metin yapar.
    String cleanNotes = notes
        .replaceAll(RegExp(r'#{1,6}\s?'), '') // Başlıkları kaldır (#)
        .replaceAll(RegExp(r'\*\*|__'), '')   // Kalın sembolleri kaldır (**)
        .replaceAll(RegExp(r'\* |_ '), '• '); // Listeleri noktaya çevir

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.system_update, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(child: Text(Localization.t('version.new_available'), style: TextStyle(fontSize: 18))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Versiyon bilgisi
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('v$local', style: TextStyle(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                    ),
                    Text('v$remote', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Notlar
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    cleanNotes,
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('version.not_now'), style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri uri = Uri.parse(url);
await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(Localization.t('version.update')),
            ),
          ],
        );
      },
    );
  }
}