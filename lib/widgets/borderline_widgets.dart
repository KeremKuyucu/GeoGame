import 'package:flutter/material.dart';

import 'package:geogame/screens/games/borderline/borderline_controller.dart';

/// Harita container widget'ı
class BorderLineMapContainer extends StatelessWidget {
  final BorderLineGameController controller;

  const BorderLineMapContainer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: controller.isDark ? Colors.black26 : Colors.white54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.isDark
              ? Colors.white10
              : Colors.indigo.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<Path?>(
        future: controller.countryShapePathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: controller.accentColor),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 50,
                  color: controller.isDark ? Colors.white38 : Colors.grey,
                ),
                const SizedBox(height: 10),
                Text(
                  "Harita verisi yüklenemedi",
                  style: TextStyle(
                    color: controller.isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
                if (snapshot.hasError)
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                  ),
              ],
            );
          }

          return CustomPaint(
            painter: CountryShapePainter(
              path: snapshot.data!,
              color: controller.isDark
                  ? const Color(0xFFC5CAE9)
                  : const Color(0xFF3949AB),
              strokeColor: controller.isDark ? Colors.white : Colors.black87,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

/// Ülke şekli çizen CustomPainter
class CountryShapePainter extends CustomPainter {
  final Path path;
  final Color color;
  final Color strokeColor;

  CountryShapePainter({
    required this.path,
    required this.color,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.getBounds().isEmpty) return;

    final Rect bounds = path.getBounds();

    final double scaleX = size.width / bounds.width;
    final double scaleY = size.height / bounds.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final Matrix4 matrix = Matrix4.identity();

    final double offsetX = (size.width - (bounds.width * scale)) / 2;
    final double offsetY = (size.height - (bounds.height * scale)) / 2;

    matrix.translateByDouble(offsetX, offsetY, 0.0, 1.0);
    matrix.scaleByDouble(scale, scale, 1.0, 1.0);
    matrix.translateByDouble(-bounds.left, -bounds.top, 0.0, 1.0);

    final Path transformedPath = path.transform(matrix.storage);

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawShadow(transformedPath, Colors.black, 4.0, true);
    canvas.drawPath(transformedPath, fillPaint);
    canvas.drawPath(transformedPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CountryShapePainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
