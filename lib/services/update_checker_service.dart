import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:geogame/services/localization_service.dart';


class UpdateService {
  static const String repoOwner = 'KeremKuyucu';
  static const String repoName = 'GeoGame';

  /// 🚀 Güncelleme Kontrolü (Static Metot)
  static Future<void> check(BuildContext context) async {
    // 1. Yerel Versiyonu Al
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;

    try {
      // 2. GitHub API'den Son Sürümü Çek
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Tag isminden "v" harfini temizle (örn: v1.0.2 -> 1.0.2)
        String remoteVersion = (data['tag_name'] as String? ?? '0.0.0').replaceAll(RegExp(r'^v'), '');

        // Release notlarını al (Markdown formatında gelir)
        String updateNotes = data['body'] ?? '';

        // 3. Versiyonları Karşılaştır (Semantik Kontrol)
        if (_isNewerVersion(localVersion, remoteVersion)) {
          if (!context.mounted) return;

          // Markdown'ı HTML'e çevir
          String htmlContent = md.markdownToHtml(updateNotes);

          _showUpdateDialog(
              context,
              localVersion,
              remoteVersion,
              htmlContent,
              'https://github.com/$repoOwner/$repoName/releases/latest'
          );
        }
      } else {
        debugPrint('GitHub API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Güncelleme kontrol hatası: $e');
    }
  }

  /// 🔢 Semantik Versiyon Karşılaştırma (1.10.0 > 1.2.0 mantığını doğru yapar)
  static bool _isNewerVersion(String local, String remote) {
    try {
      List<int> lParts = local.split('.').map(int.parse).toList();
      List<int> rParts = remote.split('.').map(int.parse).toList();

      // Parça sayısı eşit değilse eşitle (örn: 1.0 vs 1.0.1)
      while (lParts.length < rParts.length) {
        lParts.add(0);
      }
      while (rParts.length < lParts.length) {
        rParts.add(0);
      }

      for (int i = 0; i < lParts.length; i++) {
        if (rParts[i] > lParts[i]) return true; // Uzaktaki daha büyük
        if (rParts[i] < lParts[i]) return false; // Yerel daha büyük
      }
      return false; // Eşit
    } catch (e) {
      return false; // Parse hatası olursa güncelleme gösterme
    }
  }

  /// 📱 Diyalog Gösterimi
  static void _showUpdateDialog(BuildContext context, String local, String remote, String htmlNotes, String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Localization.t('version.new_available')),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'v$local  ➔  v$remote',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Divider(),
                  Html(
                    data: htmlNotes,
                    style: {
                      "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                      "h1": Style(fontSize: FontSize.large),
                      "h2": Style(fontSize: FontSize.medium),
                      "li": Style(margin: Margins.only(bottom: 5)),
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('version.not_now'), style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLauncher.url(url: url);
              },
              child: Text(Localization.t('version.update')),
            ),
          ],
        );
      },
    );
  }
}