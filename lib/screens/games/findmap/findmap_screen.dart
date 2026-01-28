import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'package:geogame/screens/games/findmap/findmap_controller.dart';

class FindMapGame extends StatefulWidget {
  const FindMapGame({super.key});

  @override
  State<FindMapGame> createState() => _FindMapGameState();
}

class _FindMapGameState extends State<FindMapGame>
    with TickerProviderStateMixin {
  final FindMapGameController _controller = FindMapGameController();
  final TransformationController _transformController =
      TransformationController();

  final Size mapSize = const Size(2000, 1000);
  double _currentScale = 1.0;

  late AnimationController _pulseController;
  late AnimationController _scoreController;
  bool _showHint = false;

  static const double _hitBaseRadius = 20.0; // Tıklama algılama yarıçapı

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _transformController.addListener(() {
      setState(() {
        _currentScale = _transformController.value.getMaxScaleOnAxis();
      });
    });

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformController.dispose();
    _pulseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await _controller.initializeGame();
    if (mounted) setState(() {});
  }

  void _onTapLocal(TapUpDetails details) {
    if (_controller.isLoading || _controller.targetCountry == null) return;

    // 1. ÖNCE MARKER KONTROLÜ (KÜÇÜK ÜLKELER)
    Country? hitCountry;

    for (var country in _controller.smallCountries) {
      final center = _controller.transformedSmallCountryCenters[country.iso3];
      if (center == null) continue;

      // LocalPosition (2000x1000 space) ile merkez arasındaki mesafe
      final distance = (details.localPosition - center).distance;

      if (distance <= _hitBaseRadius / _currentScale) {
        hitCountry = country;
        break;
      }
    }

    // 2. NORMAL HARİTA KONTROLÜ
    // Marker bulunamadıysa ray-casting ile kontrol et
    hitCountry ??= _controller.handleTap(details.localPosition);

    if (hitCountry != null) {
      if (hitCountry.iso3 == _controller.targetCountry!.iso3) {
        _showResultDialog(true, hitCountry);
      } else {
        _showResultDialog(false, hitCountry);
      }
    }
  }

  void _showResultDialog(bool isCorrect, Country clickedCountry) {
    if (isCorrect) {
      _controller.handleCorrectAnswer(hintUsed: _showHint);
      _scoreController.forward(from: 0);
      _showHint = false;
    } else {
      _controller.handleWrongAnswer();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCorrect
                    ? Localization.t('game_findmap.correct_feedback', args: [
                        clickedCountry
                            .getLocalizedName(Localization.currentLanguage)
                      ])
                    : Localization.t('game_findmap.wrong_feedback', args: [
                        clickedCountry
                            .getLocalizedName(Localization.currentLanguage)
                      ]),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
            isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: _controller.backgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _controller.isDark ? Colors.tealAccent : Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                Localization.t('game_findmap.loading_world'),
                style: TextStyle(
                  fontSize: 18,
                  color: _controller.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    _controller.prepareMapMatrix(mapSize);

    return GameScaffold(
      title: Localization.t('game_findmap.title'),
      backgroundColors: [
        _controller.backgroundColor,
        _controller.backgroundColor
      ],
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minScaleX = constraints.maxWidth / mapSize.width;
                final double minScaleY = constraints.maxHeight / mapSize.height;
                final double fitScale = min(minScaleX, minScaleY);

                return InteractiveViewer(
                  transformationController: _transformController,
                  minScale: fitScale,
                  maxScale: 20.0,
                  boundaryMargin: EdgeInsets.all(constraints.maxWidth),
                  constrained: false,
                  child: GestureDetector(
                    onTapUp: _onTapLocal,
                    child: CustomPaint(
                      size: mapSize,
                      painter: WorldMapPainter(
                        // Cached paths passed directly
                        paths: _controller.transformedPaths,
                        smallCountryCenters:
                            _controller.transformedSmallCountryCenters,
                        targetIso:
                            _showHint ? _controller.targetCountry?.iso3 : null,
                        isDark: AppState.settings.darkTheme,
                        scale: _currentScale,
                        pulseAnimation: _pulseController,
                        showHint: _showHint,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: kIsWeb ? 60 : 16,
            left: 16,
            right: 16,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _controller.isDark
                            ? [const Color(0xFF1E3A5F), const Color(0xFF2C5F7F)]
                            : [
                                const Color(0xFF00ACC1),
                                const Color(0xFF00838F)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_searching,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Localization.t('game_findmap.find_prompt',
                                    args: ['']).replaceAll(':', ''),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _controller.targetCountry?.getLocalizedName(
                                        Localization.currentLanguage) ??
                                    '?',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                    parent: _scoreController, curve: Curves.easeOut),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: _controller.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatItem(
                      Icons.check_circle,
                      _controller.correctAnswers.toString(),
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      height: 30,
                      color: _controller.textColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.cancel,
                      _controller.wrongAnswers.toString(),
                      const Color(0xFFE53935),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: _showHint
                      ? Icons.visibility_off
                      : Icons.lightbulb_outline,
                  color: const Color(0xFFFFA726),
                  onPressed: () {
                    setState(() {
                      _showHint = !_showHint;
                    });
                  },
                  tooltip: _showHint
                      ? Localization.t('game_findmap.hide_hint')
                      : Localization.t('game_findmap.show_hint'),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.center_focus_strong,
                  color: const Color(0xFF00ACC1),
                  onPressed: () {
                    _transformController.value = Matrix4.identity();
                  },
                  tooltip: Localization.t('game_findmap.reset_view'),
                ),
              ],
            ),
          ),
          if (_currentScale > 1.5)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _controller.cardBg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in,
                      size: 16,
                      color: _controller.textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentScale.toStringAsFixed(1)}x',
                      style: TextStyle(
                        color: _controller.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (kIsWeb)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        Localization.t('game_findmap.web_performance_warning'),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _controller.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _controller.cardBg,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}

class WorldMapPainter extends CustomPainter {
  final Map<String, Path> paths; // Already Transformed Paths
  final Map<String, Offset> smallCountryCenters; // ALready Transformed Centers
  final String? targetIso;
  final bool isDark;
  final double scale;
  final Animation<double>? pulseAnimation;
  final bool showHint;

  WorldMapPainter({
    required this.paths,
    required this.smallCountryCenters,
    required this.targetIso,
    required this.isDark,
    required this.scale,
    this.pulseAnimation,
    this.showHint = false,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint oceanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF0A1929), const Color(0xFF132F4C)]
            : [const Color(0xFFB3E5FC), const Color(0xFF81D4FA)],
      ).createShader(rect);
    canvas.drawRect(rect, oceanPaint);

    final Paint countryPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.5, 1.0 / scale)
      ..color = isDark ? Colors.white12 : Colors.black12;

    final Paint hintPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? Colors.amber : Colors.orange)
          .withValues(alpha: 0.3 + (pulseAnimation?.value ?? 0) * 0.3);

    final Paint hintStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, 3.0 / scale)
      ..color = isDark ? Colors.amber : Colors.orange;

    // Küçük ülke markerları için kalem
    final Paint markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? Colors.white : Colors.black54).withValues(alpha: 0.6);

    final double markerRadius = max(2.0, 5.0 / scale);

    // Path'leri çiz (Zaten transform edilmiş durumda)
    for (var entry in paths.entries) {
      final transformedPath = entry.value;

      if (isDark) {
        countryPaint.color = const Color(0xFF263238);
      } else {
        countryPaint.color = const Color(0xFFF5F5F5);
      }

      canvas.drawPath(transformedPath, countryPaint);
      canvas.drawPath(transformedPath, strokePaint);

      if (showHint && targetIso != null && entry.key == targetIso) {
        canvas.drawPath(transformedPath, hintPaint);
        canvas.drawPath(transformedPath, hintStrokePaint);
      }
    }

    // Küçük ülkeler için marker çizimi
    // Zaten sadece küçük ülkelerin keyleri smallCountryCenters içinde var
    for (var center in smallCountryCenters.values) {
      canvas.drawCircle(center, markerRadius, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.targetIso != targetIso ||
        oldDelegate.scale != scale ||
        oldDelegate.showHint != showHint;
  }
}
