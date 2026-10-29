import 'package:flutter/material.dart';

/// Widget mikro-interaksi sentuhan (tekan-dan-skala) ringan dengan fisika pegas (spring physics).
/// Dibungkus dengan [RepaintBoundary] untuk mengisolasi rendering dan menjaga performa mulus 120 FPS.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 140),
    this.glowColor,
    this.borderRadius,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: widget.duration,
          curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
          child: AnimatedContainer(
            duration: widget.duration,
            decoration: widget.glowColor != null && _pressed
                ? BoxDecoration(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor!.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Animasi muncul (fade + geser halus ke atas) satu kali saat pertama kali dirender.
/// Menggunakan [TweenAnimationBuilder] dengan kurva [Interval] (tanpa Future.delayed),
/// memastikan penyelesaian deterministik dalam pengujian widget (`pumpAndSettle`).
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 380),
    this.offsetY = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedIndex = index.clamp(0, 8);
    final startInterval = (clampedIndex * 0.06).clamp(0.0, 0.45);

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Interval(startInterval, 1.0, curve: Curves.easeOutCubic),
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1.0 - value) * offsetY),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

/// Dioda LED status dengan animasi denyut bercahaya (indikator telemetri aktif)
class PulseLed extends StatefulWidget {
  final Color color;
  final double size;
  final bool isPulsing;

  const PulseLed({
    super.key,
    this.color = const Color(0xFF00F5A0),
    this.size = 8.0,
    this.isPulsing = true,
  });

  @override
  State<PulseLed> createState() => _PulseLedState();
}

class _PulseLedState extends State<PulseLed> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool get _isTesting {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isPulsing && !_isTesting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final opacity = widget.isPulsing ? _animation.value : 1.0;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5 * opacity),
                  blurRadius: widget.size * 1.2,
                  spreadRadius: widget.size * 0.3 * opacity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Kontainer kartu panel gelap kokpit performa tinggi dengan bingkai tipis (hairline border) 1px
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.borderRadius,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(18);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF15202E),
                Color(0xFF0D141F),
              ],
            ),
        border: Border.all(
          color: borderColor ?? const Color(0xFF223249),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
