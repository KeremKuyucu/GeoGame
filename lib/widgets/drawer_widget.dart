import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:geogame/widgets/feedback_dialog.dart';

import 'package:geogame/services/localization_service.dart';

import 'package:geogame/models/app_context.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: <Widget>[
                const SizedBox(height: 10),
                _buildActionSection(context),
                const Divider(height: 30),
                _buildSocialSection(),
                const Divider(height: 30),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo.webp'),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GeoGame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                Localization.t('drawer.version_text', args: [AppState.version]),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListTile(
          icon: Icons.bug_report_rounded,
          iconColor: Colors.amber.shade700,
          title: Localization.t('drawer.report_bug'),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) => const FeedbackDialog(),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Text(
            Localization.t('drawer.feedback_note'),
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    // mode: LaunchMode.externalApplication -> Uygulama içi webview değil, Chrome/Safari açar.
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Link açılamadı: $urlString");
    }
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        _buildListTile(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF5865F2),
          title: Localization.t('drawer.my_website'),
          onTap: () => _launchURL('https://keremkk.com.tr'),
        ),
        _buildListTile(
          icon: Icons.language_rounded,
          iconColor: Colors.redAccent,
          title: Localization.t('drawer.geogame_website'),
          onTap: () => _launchURL('https://geogame.keremkk.com.tr'),
        ),
        _buildListTile(
          icon: Icons.terminal_rounded,
          iconColor: Colors.black87, // GitHub için siyah daha uygun
          title: Localization.t('drawer.geogame_github'),
          onTap: () => _launchURL('https://github.com/KeremKuyucu/GeoGame'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            Localization.t('drawer.creator'),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: iconColor.withValues(alpha: 0.05),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
