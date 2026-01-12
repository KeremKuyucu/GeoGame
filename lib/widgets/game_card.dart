import 'package:flutter/material.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/localization_service.dart';

/// Oyun kartı widget'ı
/// Ana ekranda oyunları listelemek için kullanılır
class GameCard extends StatelessWidget {
  final GameMetadata metadata;
  final bool isGrid;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.metadata,
    required this.isGrid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = Localization.t('${metadata.titleKey}.title');
    final String desc = Localization.t('${metadata.descKey}.description');
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildCardDecoration(),
        child: Stack(
          children: [
            _buildGradientOverlay(),
            _buildCardContent(title, desc, screenWidth),
          ],
        ),
      ),
    );
  }

  /// Kart dekorasyonu
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
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
    );
  }

  /// Gradient overlay
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  /// Kart içeriği
  Widget _buildCardContent(String title, String desc, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleBadge(title),
                const SizedBox(height: 8),
                _buildTitle(title),
                if (!isGrid || screenWidth > 1000) ...[
                  const SizedBox(height: 4),
                  _buildDescription(desc),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Başlık badge'i
  Widget _buildTitleBadge(String title) {
    return Container(
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
    );
  }

  /// Ana başlık
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: isGrid ? 32 : 26,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Açıklama metni
  Widget _buildDescription(String desc) {
    return Text(
      desc,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey[300], fontSize: 14),
    );
  }
}
