import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Futuristic animated liquid glass background featuring an ambient Siri-like
/// circular wave with soft glowing blur, expanding and contracting organically.
///
/// Pinned strictly to the screen viewport via a root [Stack] so that it remains
/// static in screen space while the foreground content scrolls smoothly over it.
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
      duration: const Duration(seconds: 14),
    );
    // Avoid scheduling infinite animation frames in widget tests
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
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
        // 1. Viewport-Pinned Static Animated Siri Circular Wave with Blur
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _SiriWaveBackgroundPainter(_controller.value),
              ),
            ),
          ),
        ),

        // 2. Technical Holographic Circuit Matrix Points
        Positioned.fill(
          child: IgnorePointer(
            child: const RepaintBoundary(
              child: CustomPaint(
                painter: _TechGridPainter(),
              ),
            ),
          ),
        ),

        // 3. Scrollable Foreground Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

/// Painter for the ambient Siri-like circular glowing wave with harmonic ripples and soft blur.
class _SiriWaveBackgroundPainter extends CustomPainter {
  final double progress;

  _SiriWaveBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Obsidian Canvas
    final bgPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final center = Offset(size.width * 0.50, size.height * 0.42);
    final baseRadius = math.min(size.width, size.height) * 0.36;
    final t = progress * 2.0 * math.pi;

    // 2. Large soft ambient chromatic aura blur behind the Siri orb
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.32),
          const Color(0xFF00E5FF).withValues(alpha: 0.24),
          const Color(0xFFEC4899).withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.9));
    canvas.drawCircle(center, baseRadius * 1.9, auraPaint);

    // 3. Siri wave harmonic layers (expanding, contracting, and undulating with blur)
    final waveLayers = [
      _SiriWaveConfig(
        color: const Color(0xFF00E5FF), // Electric Cyan
        baseScale: 0.76,
        pulseAmp: 0.16,
        freq: 3,
        waveAmp: 0.08,
        speed: 1.0,
        phase: 0.0,
        blur: 16.0,
      ),
      _SiriWaveConfig(
        color: const Color(0xFFA855F7), // Radiant Violet
        baseScale: 0.92,
        pulseAmp: 0.18,
        freq: 4,
        waveAmp: 0.10,
        speed: -0.85,
        phase: math.pi / 2,
        blur: 20.0,
      ),
      _SiriWaveConfig(
        color: const Color(0xFFEC4899), // Hot Magenta
        baseScale: 1.06,
        pulseAmp: 0.14,
        freq: 3,
        waveAmp: 0.09,
        speed: 1.15,
        phase: math.pi,
        blur: 24.0,
      ),
      _SiriWaveConfig(
        color: const Color(0xFF2563EB), // Deep Royal Blue
        baseScale: 0.64,
        pulseAmp: 0.12,
        freq: 5,
        waveAmp: 0.07,
        speed: -1.1,
        phase: math.pi * 1.5,
        blur: 14.0,
      ),
      _SiriWaveConfig(
        color: const Color(0xFFF59E0B), // Warm Glowing Amber
        baseScale: 0.48,
        pulseAmp: 0.20,
        freq: 3,
        waveAmp: 0.06,
        speed: 0.9,
        phase: math.pi * 0.7,
        blur: 18.0,
      ),
    ];

    for (final cfg in waveLayers) {
      _drawHarmonicSiriWave(canvas, center, baseRadius, t, cfg);
    }

    // 4. Central intense glowing Siri core
    final corePulse = 1.0 + 0.16 * math.sin(t * 1.4);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.50),
          const Color(0xFF00E5FF).withValues(alpha: 0.38),
          const Color(0xFFA855F7).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.32, 0.68, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 0.44 * corePulse));
    canvas.drawCircle(center, baseRadius * 0.44 * corePulse, corePaint);
  }

  void _drawHarmonicSiriWave(
    Canvas canvas,
    Offset center,
    double baseRadius,
    double t,
    _SiriWaveConfig cfg,
  ) {
    final pulse = 1.0 + cfg.pulseAmp * math.sin(t * cfg.speed + cfg.phase);
    final r0 = baseRadius * cfg.baseScale * pulse;

    final path = Path();
    const steps = 72;
    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2.0 * math.pi;
      final wave = cfg.waveAmp * math.sin(cfg.freq * theta + t * cfg.speed + cfg.phase) +
                   (cfg.waveAmp * 0.5) * math.cos((cfg.freq + 2) * theta - t);
      final r = r0 * (1.0 + wave);
      final x = center.dx + math.cos(theta) * r;
      final y = center.dy + math.sin(theta) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Soft blurred glowing fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, cfg.blur)
      ..shader = RadialGradient(
        colors: [
          cfg.color.withValues(alpha: 0.22),
          cfg.color.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.2, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r0 * 1.25));

    canvas.drawPath(path, fillPaint);

    // Glowing wave perimeter rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, cfg.blur * 0.5)
      ..shader = SweepGradient(
        colors: [
          cfg.color.withValues(alpha: 0.75),
          const Color(0xFF00E5FF).withValues(alpha: 0.55),
          const Color(0xFFEC4899).withValues(alpha: 0.65),
          cfg.color.withValues(alpha: 0.75),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r0));

    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _SiriWaveBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SiriWaveConfig {
  final Color color;
  final double baseScale;
  final double pulseAmp;
  final int freq;
  final double waveAmp;
  final double speed;
  final double phase;
  final double blur;

  _SiriWaveConfig({
    required this.color,
    required this.baseScale,
    required this.pulseAmp,
    required this.freq,
    required this.waveAmp,
    required this.speed,
    required this.phase,
    required this.blur,
  });
}

/// Custom painter for subtle holographic technical grid points.
class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.04)
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

/// Apple visionOS & Liquid Glass inspired Translucent Glass Container.
///
/// Designed with calibrated translucency (alpha: 0.22) so that the undulating Siri
/// glowing circular wave in the background remains clearly visible through the glass cards,
/// while providing crisp frosted refraction, specular meniscus glare, and beveled edges.
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
    this.blurSigma = 18.0,
    this.borderWidth = 1.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calibrated translucency (alpha: 0.22) allows the colorful background to shine through
    final effectiveTint =
        tintColor ?? const Color(0xFF0F172A).withValues(alpha: 0.22);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.01),
            (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.06),
          ],
          stops: const [0.0, 0.25, 0.70, 1.0],
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
          splashColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.20),
          highlightColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.10),
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
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
            // Chromatic ambient caustic bloom
            BoxShadow(
              color: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.20),
              blurRadius: 30,
              spreadRadius: -2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: kIsWeb
              ? CustomPaint(
                  foregroundPainter: _BubblyGlassBorderPainter(
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                    glowColor: glowColor,
                  ),
                  child: content,
                )
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: CustomPaint(
                    foregroundPainter: _BubblyGlassBorderPainter(
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      glowColor: glowColor,
                    ),
                    child: content,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Custom painter for the authentic Bubbly Liquid Glass specular highlight & meniscus sheen.
class _BubblyGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Color? glowColor;

  const _BubblyGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Primary Outer Specular Rim (intense 45° shoulder catch)
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.90),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.10),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.30),
        ],
        stops: const [0.0, 0.24, 0.65, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, primaryPaint);

    // 2. Secondary Inner Specular Bevel Line (physical glass lens thickness)
    if (borderRadius > 4) {
      final innerRect = rect.deflate(1.2);
      final innerRRect = RRect.fromRectAndRadius(
        innerRect,
        Radius.circular(borderRadius - 1.2),
      );
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.40],
        ).createShader(innerRect);

      canvas.drawRRect(innerRRect, innerPaint);
    }

    // 3. Convex Specular Meniscus Glare (curved bubble sheen on top shoulder)
    if (size.width > 40 && size.height > 40) {
      final meniscusHeight = math.min(size.height * 0.38, 32.0);
      final meniscusRect = Rect.fromLTWH(
        borderWidth,
        borderWidth,
        size.width - borderWidth * 2,
        meniscusHeight,
      );
      final meniscusRRect = RRect.fromRectAndCorners(
        meniscusRect,
        topLeft: Radius.circular(borderRadius - borderWidth),
        topRight: Radius.circular(borderRadius - borderWidth),
        bottomLeft: const Radius.circular(14),
        bottomRight: const Radius.circular(14),
      );

      final meniscusPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(meniscusRect);

      canvas.drawRRect(meniscusRRect, meniscusPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblyGlassBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.glowColor != glowColor;
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
      glowColor: accentColor,
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
      glowColor: isPrimary ? accentColor : null,
      tintColor: isPrimary
          ? accentColor.withValues(alpha: 0.28)
          : const Color(0xFF0F172A).withValues(alpha: 0.35),
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
              color: isPrimary ? const Color(0xFFF8FAFC) : const Color(0xFFE2E8F0),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
