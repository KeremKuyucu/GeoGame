import 'package:flutter/material.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/profile_view_widget.dart'; // ✅ Yeni widget'ı import ettik

class Userprofile extends StatefulWidget {
  final Map<String, dynamic> user;
  const Userprofile({super.key, required this.user});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<Userprofile> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    // Null safety kontrolleri
    final String name = user['name'] ?? Localization.t('settings.guest');
    final String avatarUrl = user['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
    final int totalScore = user['totalScore'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const DrawerWidget(),

      body: ProfileViewWidget(
        name: name,
        avatarUrl: avatarUrl,
        totalScore: totalScore,
        stats: user,
      ),
    );
  }
}