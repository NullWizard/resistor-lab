import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VisionOS & Apple Intelligence inspired Liquid Glass background featuring a dark ambient canvas
/// with smooth, fluid harmonic sine waves radiating outward from the middle like Siri,
/// rendered with heavy Gaussian blur for a dreamy, organic, seamless ambient glowing atmosphere.
///
/// Strictly pinned to the screen viewport via a root [Stack] so that it remains
/// static in screen space while the foreground content scrolls smoothly over it.
///
/// Optimized for 60 FPS performance: the animation controller only rebuilds the background
/// CustomPaint canvas and NEVER triggers rebuilds of the foreground widget tree.
class FuturisticBackground extends StatefulWidget {
  final Widget child;

  const FuturisticBackground({super.key, required this.child});

  @override
  State<FuturisticBackground> createState() => _FuturisticBackgroundState();
}

class _FuturisticBackgroundState extends State<FuturisticBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // Avoid scheduling infinite animation frames in widget tests
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Viewport-Pinned Static Animated Smooth Sine Waves Radiating From Middle (Zero-lag isolated canvas)
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _SiriRadiatingWavesPainter(_controller.value),
              ),
            ),
          ),
        ),

        // 2. Holographic Technical Matrix Micro-Grid
        Positioned.fill(
          child: IgnorePointer(
            child: const RepaintBoundary(
              child: CustomPaint(
                painter: _TechGridPainter(),
              ),
            ),
          ),
        ),

        // 3. Foreground Content (Isolated from background animation loop for instant touch responsiveness)
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

/// Painter for smooth fluid sine waves radiating seamlessly from the middle like Siri,
/// with heavy multi-layer Gaussian blur bloom and organic harmonic undulation.
/// The center blends seamlessly with the waves rather than looking like an obvious concentrated dot.
class _SiriRadiatingWavesPainter extends CustomPainter {
  final double progress;

  _SiriRadiatingWavesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Obsidian Canvas
    final bgPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final center = Offset(size.width * 0.50, size.height * 0.44);
    final maxRadius = math.max(size.width, size.height) * 0.72;
    final t = progress * 2.0 * math.pi;

    // 2. Soft, Seamless Ambient Chromatic Glow (Low-opacity, diffused center that blends into space)
    final ambientAuraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.18), // Soft Violet
          const Color(0xFF00E5FF).withValues(alpha: 0.14), // Soft Cyan
          const Color(0xFFEC4899).withValues(alpha: 0.08), // Soft Magenta
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.85))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55.0);
    canvas.drawCircle(center, maxRadius * 0.85, ambientAuraPaint);

    // 3. Smooth Concentric Sine Waves Radiating Outward from Middle (Like Siri)
    // 6 radiating harmonic wave rings with heavy Gaussian blur and seamless origin
    final wavePalette = [
      const Color(0xFF00E5FF), // Electric Cyan
      const Color(0xFFA855F7), // Radiant Violet
      const Color(0xFFEC4899), // Hot Magenta
      const Color(0xFF3B82F6), // Royal Blue
      const Color(0xFF14B8A6), // Electric Teal
      const Color(0xFFF59E0B), // Warm Amber
    ];

    const numRadiatingRings = 6;
    for (int k = 0; k < numRadiatingRings; k++) {
      // Phase progresses outward continuously [0.0 .. 1.0]
      final ringProgress = (progress + k / numRadiatingRings) % 1.0;
      final rBase = ringProgress * maxRadius;

      // Soft parabolic fade: 0 at center, gentle peak mid-way, soft fade at perimeter
      // Smoothly merges into center without creating a dense central dot
      final fade = math.sin(ringProgress * math.pi);
      final alpha = (fade * fade * 0.38).clamp(0.0, 1.0);

      if (alpha < 0.015) continue;

      final color = wavePalette[k % wavePalette.length];
      final path = Path();
      const steps = 96;

      for (int i = 0; i <= steps; i++) {
        final theta = (i / steps) * 2.0 * math.pi;

        // Smooth harmonic sine waves rippling around each radiating ring
        final waveMod = 0.08 * math.sin(4.0 * theta - t * 1.5 + k * 1.2) +
                        0.04 * math.cos(7.0 * theta + t * 2.0) +
                        0.02 * math.sin(10.0 * theta - t);

        final r = rBase * (1.0 + waveMod);
        final x = center.dx + math.cos(theta) * r;
        final y = center.dy + math.sin(theta) * r;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      // Heavy Gaussian Blur Stroke for smooth, dreamy Siri glow
      final blurAmount = 42.0 + 20.0 * ringProgress;
      final waveStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0 + 12.0 * ringProgress
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);

      canvas.drawPath(path, waveStrokePaint);

      // Delicate soft harmonic core line inside the heavy blur
      final coreLinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.white.withValues(alpha: alpha * 0.40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawPath(path, coreLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SiriRadiatingWavesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Custom painter for subtle holographic technical grid points.
class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    for (double x = 18; x < size.width; x += spacing) {
      for (double y = 18; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.85, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Apple visionOS-inspired Real Liquid Glass Container.
///
/// Designed as authentic liquid glass:
/// - Calibrated grayish translucency (alpha: 0.38) providing substantial physical body.
/// - Heavy frosted refraction via deep BackdropFilter blur (sigma: 28.0).
/// - Clean, subtle physical glass refractive bevel rim.
/// - ZERO fake white patches or opaque sticker shapes.
/// - Static GPU caching via RepaintBoundary for instant, zero-lag touch interactions.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final Color? glowColor;
  final double blurSigma;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.padding,
    this.margin,
    this.tintColor,
    this.glowColor,
    this.blurSigma = 28.0,
    this.borderWidth = 1.2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Substantial grayish translucent liquid glass (alpha: 0.38)
    final effectiveTint =
        tintColor ?? const Color(0xFF0F172A).withValues(alpha: 0.38);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFF64748B).withValues(alpha: 0.03),
            Colors.transparent,
            const Color(0xFF1E293B).withValues(alpha: 0.07),
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.10),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            // Soft ambient occlusion shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            // Subtle neutral glass edge reflection
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: kIsWeb
              ? CustomPaint(
                  foregroundPainter: _RealLiquidGlassBorderPainter(
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                  ),
                  child: content,
                )
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: CustomPaint(
                    foregroundPainter: _RealLiquidGlassBorderPainter(
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                    ),
                    child: content,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Custom painter for Authentic Real Liquid Glass refractive borders.
///
/// Features clean, realistic glass refraction bevels:
/// - Clean silver-white 45° light catch on the outer edge.
/// - Micro-inward secondary refraction bevel stroke simulating real glass thickness.
/// - NO fake white patches or opaque sticker shapes.
class _RealLiquidGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;

  const _RealLiquidGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Primary Outer Refractive Specular Rim (Clean silver-white light catch)
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.50),
          const Color(0xFFCBD5E1).withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.05),
          const Color(0xFF94A3B8).withValues(alpha: 0.12),
        ],
        stops: const [0.0, 0.25, 0.65, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, primaryPaint);

    // 2. Secondary Inner Specular Bevel Line (Real physical glass edge thickness)
    if (borderRadius > 4) {
      final innerRect = rect.deflate(1.0);
      final innerRRect = RRect.fromRectAndRadius(
        innerRect,
        Radius.circular(borderRadius - 1.0),
      );
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35],
        ).createShader(innerRect);

      canvas.drawRRect(innerRRect, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RealLiquidGlassBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth;
}

/// VisionOS & Liquid Glass style Rounded Capsule Pill.
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color accentColor;
  final double fontSize;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.accentColor = const Color(0xFF00E5FF),
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5.5),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2.5, color: accentColor),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.9),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: accentColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating circular liquid glass bubble icon lens with specular border and ambient glow.
class LiquidGlassIconLens extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final double size;
  final double iconSize;

  const LiquidGlassIconLens({
    super.key,
    required this.icon,
    this.accentColor = const Color(0xFF00E5FF),
    this.size = 48.0,
    this.iconSize = 23.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0B1322).withValues(alpha: 0.55),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.55),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.32),
            blurRadius: 18,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            accentColor.withValues(alpha: 0.18),
            const Color(0xFF070C16).withValues(alpha: 0.50),
          ],
          stops: const [0.0, 0.38, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: accentColor,
        ),
      ),
    );
  }
}

/// Futuristic circuit trace divider line with a central diamond junction node.
class CircuitTraceDivider extends StatelessWidget {
  final Color accentColor;
  final double height;

  const CircuitTraceDivider({
    super.key,
    this.accentColor = const Color(0xFF00E5FF),
    this.height = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.0),
                    accentColor.withValues(alpha: 0.40),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            transform: Matrix4.rotationZ(0.785398), // 45 degree diamond
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.85),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.90),
                  blurRadius: 7,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.40),
                    accentColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// High-visibility rounded bubbly liquid glass topic container for educational modules.
class LiquidGlassTopicCard extends StatelessWidget {
  final String title;
  final String? topicNumber;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;
  final Widget? trailing;

  const LiquidGlassTopicCard({
    super.key,
    required this.title,
    this.topicNumber,
    required this.icon,
    required this.accentColor,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Floating Liquid Glass Icon Lens
              LiquidGlassIconLens(
                icon: icon,
                accentColor: accentColor,
                size: 48,
                iconSize: 23,
              ),
              const SizedBox(width: 14),

              // Title and Topic Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topicNumber != null) ...[
                      GlassBadge(
                        label: topicNumber!,
                        accentColor: accentColor,
                        fontSize: 10.0,
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8FAFC),
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              ?trailing,
            ],
          ),

          // Glowing Circuit Trace Divider
          CircuitTraceDivider(
            accentColor: accentColor,
            height: 28,
          ),

          // Topic Body
          ...children,
        ],
      ),
    );
  }
}

/// VisionOS style Glass Interactive Action Button.
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isPrimary;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.accentColor = const Color(0xFF00E5FF),
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onPressed,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      tintColor: isPrimary
          ? accentColor.withValues(alpha: 0.28)
          : const Color(0xFF1E293B).withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isPrimary ? const Color(0xFFF8FAFC) : accentColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color:
                  isPrimary ? const Color(0xFFF8FAFC) : const Color(0xFFE2E8F0),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
