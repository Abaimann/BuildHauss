import 'package:flutter/material.dart';

/// BuildHaus Logo SVG-style widget
class BuildHausLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const BuildHausLogo({super.key, this.size = 36, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade400],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.7, size * 0.7),
              painter: _LogoPainter(),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BuildHaus',
                style: TextStyle(
                  fontSize: size * 0.44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Built for every ride',
                style: TextStyle(
                  fontSize: size * 0.22,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF101010)
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // House roof
    final roofPath = Path()
      ..moveTo(size.width * 0.15, cy + size.height * 0.15)
      ..lineTo(cx, size.height * 0.1)
      ..lineTo(size.width * 0.85, cy + size.height * 0.15);
    canvas.drawPath(roofPath, paint);

    // House body
    final bodyPath = Path()
      ..moveTo(size.width * 0.18, cy + size.height * 0.15)
      ..lineTo(size.width * 0.18, size.height * 0.85)
      ..lineTo(size.width * 0.82, size.height * 0.85)
      ..lineTo(size.width * 0.82, cy + size.height * 0.15);
    canvas.drawPath(bodyPath, paint);

    // Door
    final doorPaint = Paint()
      ..color = const Color(0xFF101010)
      ..strokeWidth = size.width * 0.06
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx * 0.8, size.height * 0.85),
      Offset(cx * 0.8, cy + size.height * 0.25),
      doorPaint,
    );
    canvas.drawLine(
      Offset(cx * 1.2, size.height * 0.85),
      Offset(cx * 1.2, cy + size.height * 0.25),
      doorPaint,
    );
    canvas.drawLine(
      Offset(cx * 0.8, cy + size.height * 0.25),
      Offset(cx * 1.2, cy + size.height * 0.25),
      doorPaint,
    );

    // Motorcycle wheel (green dot)
    final wheelPaint = Paint()
      ..color = const Color(0xFF3da96e)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx * 0.7, cy + size.height * 0.55),
      size.width * 0.07,
      wheelPaint,
    );
    canvas.drawCircle(
      Offset(cx * 1.3, cy + size.height * 0.55),
      size.width * 0.07,
      wheelPaint,
    );

    // Checkmark badge
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.2),
      size.width * 0.12,
      wheelPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact logo for small spaces
class BuildHausLogoCompact extends StatelessWidget {
  final double size;

  const BuildHausLogoCompact({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _LogoPainter(),
        ),
      ),
    );
  }
}
