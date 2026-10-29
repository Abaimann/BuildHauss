import 'package:flutter/material.dart';

/// BuildHaus High-Precision Automotive Engineering Brand Emblem
class BuildHausLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const BuildHausLogo({super.key, this.size = 36, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Apex Crest Emblem
          _ApexBadge(size: size),
          if (showText) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BuildHaus',
                  style: TextStyle(
                    fontSize: size * 0.40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Built for every ride',
                  style: TextStyle(
                    fontSize: size * 0.19,
                    color: const Color(0xFF00F5A0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact aerodynamic apex crest for app bars and icons
class BuildHausLogoCompact extends StatelessWidget {
  final double size;

  const BuildHausLogoCompact({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _ApexBadge(size: size),
    );
  }
}

class _ApexBadge extends StatelessWidget {
  final double size;
  const _ApexBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF162130),
            Color(0xFF090D14),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFF00F5A0).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5A0).withValues(alpha: 0.15),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.68, size * 0.68),
          painter: const _ApexEmblemPainter(),
        ),
      ),
    );
  }
}

/// Precision-engineered automotive telemetry emblem (interlocking BH aero-winglets)
class _ApexEmblemPainter extends CustomPainter {
  const _ApexEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Winglet 1: Titanium metallic left chevron (B arc)
    final leftPath = Path()
      ..moveTo(w * 0.18, h * 0.72)
      ..lineTo(w * 0.18, h * 0.28)
      ..lineTo(cx - w * 0.04, h * 0.12)
      ..lineTo(cx + w * 0.08, h * 0.24)
      ..lineTo(w * 0.36, h * 0.40)
      ..lineTo(w * 0.36, h * 0.62)
      ..close();

    final leftGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFFFFFFF),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final leftPaint = Paint()
      ..shader = leftGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftPath, leftPaint);

    // Winglet 2: Cyber Emerald dynamic right fin (H apex)
    final rightPath = Path()
      ..moveTo(w * 0.82, h * 0.28)
      ..lineTo(w * 0.82, h * 0.72)
      ..lineTo(cx + w * 0.04, h * 0.88)
      ..lineTo(cx - w * 0.08, h * 0.76)
      ..lineTo(w * 0.64, h * 0.60)
      ..lineTo(w * 0.64, h * 0.38)
      ..close();

    final rightGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: const [
        Color(0xFF38BDF8),
        Color(0xFF00F5A0),
        Color(0xFF059669),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final rightPaint = Paint()
      ..shader = rightGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // Center Core: Mechanical Telemetry Apex Diamond
    final corePath = Path()
      ..moveTo(cx, cy - h * 0.14)
      ..lineTo(cx + w * 0.12, cy)
      ..lineTo(cx, cy + h * 0.14)
      ..lineTo(cx - w * 0.12, cy)
      ..close();

    final corePaint = Paint()
      ..color = const Color(0xFF00F5A0)
      ..style = PaintingStyle.fill;
    canvas.drawPath(corePath, corePaint);

    // Inner glowing diode point
    final diodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), w * 0.045, diodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
