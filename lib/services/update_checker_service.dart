import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geogame/services/localization_service.dart';

class UpdateService {
  static const String repoOwner = 'KeremKuyucu';
  static const String repoName = 'GeoGame';

  static bool _isNewVersionAvailable(String local, String remote) {
    try {
      List<int> localParts = local.split('.').map(int.parse).toList();
      List<int> remoteParts = remote.split('.').map(int.parse).toList();

      for (var i = 0; i < remoteParts.length; i++) {
        int localPart = i < localParts.length ? localParts[i] : 0;
        if (remoteParts[i] > localPart) return true;
        if (remoteParts[i] < localPart) return false;
      }
    } catch (e) {
      debugPrint("Sürüm ayrıştırma hatası: $e");
    }
    return false;
  }

  static Future<void> check(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String localVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String downloadUrl = data['html_url'] ?? 'https://github.com/$repoOwner/$repoName/releases';
        String remoteVersion = (data['tag_name'] as String? ?? '0.0.0').replaceAll(RegExp(r'^v'), '');
        String updateNotes = data['body'] ?? '';

        if (_isNewVersionAvailable(localVersion, remoteVersion)) {
          if (!context.mounted) return;
          _showUpdateDialog(
            context,
            localVersion,
            remoteVersion,
            updateNotes,
            downloadUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('Güncelleme kontrol hatası: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context, String local, String remote, String notes, String url) {
    String cleanNotes = notes
        .replaceAll(RegExp(r'#{1,6}\s?'), '')
        .replaceAll(RegExp(r'\*\*|__'), '')
        .replaceAll(RegExp(r'\* |_ '), '• ');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(Localization.t('version.new_available'), style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('v$local', style: const TextStyle(color: Colors.grey)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                    ),
                    Text('v$remote', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    cleanNotes,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('version.not_now'), style: const TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                try {
                  // canLaunchUrl bazen yapılandırma hatası nedeniyle false döner.
                  // launchUrl'i doğrudan try-catch içinde çağırmak daha rasyoneldir.
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  debugPrint("URL başlatılamadı: $e");
                  // Hata durumunda kullanıcıya bilgi verilebilir.
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
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