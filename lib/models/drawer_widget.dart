import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:geogame/widgets/feedback_dialog.dart';
import 'package:geogame/services/localization_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.blueAccent),
            title: Text(
              Localization.get('hatabildir'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Diyalog mantığı ayrı bir widget'a taşındı
              showDialog(
                context: context,
                builder: (BuildContext context) => const FeedbackDialog(),
              );
            },
          ),
          ListTile(
            title: Text(
              Localization.get('sikayet'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          const Divider(),
          _buildListTile(
            icon: Icons.share,
            iconColor: const Color(0xFF5865F2),
            title: Localization.get('uygpaylas'),
            onTap: () async {
              await Share.share(Localization.get('davetpromt'));
            },
          ),
          _buildListTile(
            icon: Icons.person,
            iconColor: const Color(0xFF5865F2),
            title: Localization.get('yapimcimetin'),
            onTap: () async {
              await EasyLauncher.url(
                url: 'https://keremkk.com.tr',
                mode: Mode.platformDefault,
              );
            },
          ),
          _buildListTile(
            icon: Icons.public,
            iconColor: Colors.red,
            title: Localization.get('website'),
            onTap: () async {
              await EasyLauncher.url(url: 'https://keremkk.com.tr/geogame');
            },
          ),
          _buildListTile(
            icon: FontAwesomeIcons.github,
            iconColor: Colors.black,
            title: Localization.get('github'),
            onTap: () async {
              await EasyLauncher.url(
                url: 'https://github.com/KeremKuyucu/GeoGame',
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              Localization.get('yapimci'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/logo.png'),
          ),
          const SizedBox(width: 10),
          Text(
            'GeoGame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
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
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}