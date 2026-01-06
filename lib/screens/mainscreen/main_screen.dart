import 'package:flutter/material.dart';
import 'package:geogame/widgets/drawer_widget.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/update_checker_service.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.check(context);
    });
  }

  void _startGame(GameMetadata metadata) {
    if (AppState.filteredCountries.isEmpty) {
      _showNoContinentWarning();
      return;
    }
    Navigator.pushNamed(context, metadata.route);
  }

  void _showNoContinentWarning() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Localization.t('settings.no_continent_active'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: Localization.t('settings.title').toUpperCase(),
          textColor: Colors.white,
          onPressed: () {
            AppState.selectedIndex = 3;
            Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('GeoGame').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xff6200ee),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
                : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLarge = constraints.maxWidth > 800;

            return isLarge ? _buildGrid(isLarge) : _buildList(isLarge);
          },
        ),
      ),
    );
  }

  Widget _buildGrid(bool isGrid) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: gameMetadataList.length,
      itemBuilder: (context, index) => _buildGameCard(gameMetadataList[index], isGrid),
    );
  }
  Widget _buildList(bool isGrid) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      itemCount: gameMetadataList.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: SizedBox(
          height: 200,
          child: _buildGameCard(gameMetadataList[index], isGrid),
        ),
      ),
    );
  }
  Widget _buildGameCard(GameMetadata metadata, bool isGrid) {
    final String title = Localization.t('${metadata.titleKey}.title');
    final String desc = Localization.t('${metadata.descKey}.description');

    return GestureDetector(
      onTap: () => _startGame(metadata),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: metadata.color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(metadata.img),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: metadata.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isGrid ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isGrid ? 32 : 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!isGrid || MediaQuery.of(context).size.width > 1000) ...[
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[300], fontSize: 14),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}