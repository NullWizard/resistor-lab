import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Scope providing ambient waveform progress and animation to descendant glass components,
/// allowing glass bubbles to dynamically reflect, float, and react to background waves.
class LiquidGlassScope extends InheritedWidget {
  final double progress;
  final Animation<double>? animation;

  const LiquidGlassScope({
    super.key,
    required this.progress,
    this.animation,
    required super.child,
  });

  static LiquidGlassScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LiquidGlassScope>();
  }

  @override
  bool updateShouldNotify(LiquidGlassScope oldWidget) =>
      oldWidget.progress != progress;
}

/// VisionOS-inspired Liquid Glass background featuring a dark ambient canvas
/// with a large central circular waveform where smooth sine-like waves continuously
/// ripple around the circle's boundary like a futuristic audio visualizer.
///
/// Strictly pinned to the screen viewport via a root [Stack] so that it remains
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
      duration: const Duration(seconds: 12),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        return LiquidGlassScope(
          progress: progress,
          animation: _controller,
          child: Stack(
            children: [
              // 1. Viewport-Pinned Static Animated Large Central Circular Waveform (Music Visualizer Style)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _CircularVisualizerWaveformPainter(progress),
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

              // 3. Scrollable Foreground Content
              Positioned.fill(
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Painter for the dark ambient background with a large central circular waveform,
/// featuring smooth multi-frequency sine ripples along the circle boundary and
/// pulsating radial audio-visualizer frequency rays with soft glowing blur bloom.
class _CircularVisualizerWaveformPainter extends CustomPainter {
  final double progress;

  _CircularVisualizerWaveformPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Obsidian Canvas
    final bgPaint = Paint()..color = const Color(0xFF020611);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final center = Offset(size.width * 0.50, size.height * 0.44);
    final baseRadius = math.min(size.width, size.height) * 0.38;
    final t = progress * 2.0 * math.pi;

    // 2. Soft Ambient Chromatic Caustic Halo (Back-glow)
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.28), // Violet
          const Color(0xFF00E5FF).withValues(alpha: 0.20), // Cyan
          const Color(0xFFEC4899).withValues(alpha: 0.12), // Magenta
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: baseRadius * 1.85));
    canvas.drawCircle(center, baseRadius * 1.85, haloPaint);

    // 3. Radial Frequency Visualizer Rays (Music Visualizer Bars rippling around the boundary)
    const numRays = 120;
    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numRays; i++) {
      final theta = (i / numRays) * 2.0 * math.pi;

      // Harmonic frequency modulation simulating audio visualizer spectral energy
      final freq1 = math.sin(8.0 * theta + t * 2.0);
      final freq2 = math.cos(14.0 * theta - t * 3.0);
      final freq3 = math.sin(26.0 * theta + t * 1.5);
      final energy = (0.35 + 0.35 * freq1 + 0.20 * freq2 + 0.10 * freq3)
          .clamp(0.05, 1.0);

      final rayLength = 8.0 + energy * 26.0;
      final rInner = baseRadius * 0.94;
      final rOuter = rInner + rayLength;

      final p1 = Offset(
        center.dx + math.cos(theta) * rInner,
        center.dy + math.sin(theta) * rInner,
      );
      final p2 = Offset(
        center.dx + math.cos(theta) * rOuter,
        center.dy + math.sin(theta) * rOuter,
      );

      // Interpolate ray hue across cyan, violet, and magenta
      final huePhase = (theta / (2.0 * math.pi) + progress) % 1.0;
      Color rayColor;
      if (huePhase < 0.33) {
        rayColor = Color.lerp(const Color(0xFF00E5FF), const Color(0xFFA855F7),
            huePhase / 0.33)!;
      } else if (huePhase < 0.66) {
        rayColor = Color.lerp(const Color(0xFFA855F7), const Color(0xFFEC4899),
            (huePhase - 0.33) / 0.33)!;
      } else {
        rayColor = Color.lerp(const Color(0xFFEC4899), const Color(0xFF00E5FF),
            (huePhase - 0.66) / 0.34)!;
      }

      rayPaint
        ..color = rayColor.withValues(alpha: 0.30 + energy * 0.45)
        ..strokeWidth = 1.6;

      canvas.drawLine(p1, p2, rayPaint);
    }

    // 4. Multi-Layered Continuous Sine-Wave Boundary Rings (Smooth ripple visualizer)
    final waveLayers = [
      _WaveRingConfig(
        color: const Color(0xFF00E5FF), // Electric Cyan
        radiusScale: 1.0,
        harmonics: [
          _Harmonic(freq: 8, amp: 10.0, speed: 1.0, phase: 0.0),
          _Harmonic(freq: 16, amp: 5.0, speed: -1.6, phase: math.pi / 4),
          _Harmonic(freq: 24, amp: 2.5, speed: 2.2, phase: math.pi / 2),
        ],
        strokeWidth: 2.6,
        blur: 16.0,
        fillAlpha: 0.12,
      ),
      _WaveRingConfig(
        color: const Color(0xFFA855F7), // Radiant Violet
        radiusScale: 0.92,
        harmonics: [
          _Harmonic(freq: 6, amp: 12.0, speed: -0.9, phase: math.pi / 3),
          _Harmonic(freq: 12, amp: 6.0, speed: 1.4, phase: math.pi),
          _Harmonic(freq: 20, amp: 3.0, speed: -2.0, phase: 0.0),
        ],
        strokeWidth: 2.2,
        blur: 20.0,
        fillAlpha: 0.10,
      ),
      _WaveRingConfig(
        color: const Color(0xFFEC4899), // Hot Magenta
        radiusScale: 1.08,
        harmonics: [
          _Harmonic(freq: 10, amp: 8.0, speed: 1.2, phase: math.pi / 2),
          _Harmonic(freq: 18, amp: 4.0, speed: -1.8, phase: math.pi * 1.5),
        ],
        strokeWidth: 2.0,
        blur: 24.0,
        fillAlpha: 0.08,
      ),
      _WaveRingConfig(
        color: const Color(0xFF14B8A6), // Electric Teal
        radiusScale: 0.82,
        harmonics: [
          _Harmonic(freq: 5, amp: 9.0, speed: 0.8, phase: math.pi * 0.7),
          _Harmonic(freq: 15, amp: 4.5, speed: -1.2, phase: math.pi * 0.3),
        ],
        strokeWidth: 1.8,
        blur: 14.0,
        fillAlpha: 0.08,
      ),
    ];

    for (final layer in waveLayers) {
      _drawContinuousWaveRing(canvas, center, baseRadius, t, layer);
    }

    // 5. Central Intense Core Glow (Audio Energy Center)
    final corePulse = 1.0 + 0.14 * math.sin(t * 1.8);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          const Color(0xFF00E5FF).withValues(alpha: 0.35),
          const Color(0xFFA855F7).withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.28, 0.65, 1.0],
      ).createShader(Rect.fromCircle(
          center: center, radius: baseRadius * 0.40 * corePulse));
    canvas.drawCircle(center, baseRadius * 0.40 * corePulse, corePaint);
  }

  void _drawContinuousWaveRing(
    Canvas canvas,
    Offset center,
    double baseRadius,
    double t,
    _WaveRingConfig config,
  ) {
    final r0 = baseRadius * config.radiusScale;
    final path = Path();
    const steps = 144;

    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2.0 * math.pi;

      // Sum continuous smooth sine-like harmonic waves rippling around the circular boundary
      double dr = 0.0;
      for (final h in config.harmonics) {
        dr += h.amp * math.sin(h.freq * theta + t * h.speed + h.phase);
      }

      final r = r0 + dr;
      final x = center.dx + math.cos(theta) * r;
      final y = center.dy + math.sin(theta) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Soft Blurred Radiant Glow Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blur)
      ..shader = RadialGradient(
        colors: [
          config.color.withValues(alpha: config.fillAlpha * 1.5),
          config.color.withValues(alpha: config.fillAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.3, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r0 * 1.25));

    canvas.drawPath(path, fillPaint);

    // Glowing Boundary Perimeter Stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blur * 0.4)
      ..shader = SweepGradient(
        colors: [
          config.color.withValues(alpha: 0.85),
          const Color(0xFF00E5FF).withValues(alpha: 0.70),
          const Color(0xFFEC4899).withValues(alpha: 0.80),
          config.color.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r0));

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CircularVisualizerWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Harmonic {
  final int freq;
  final double amp;
  final double speed;
  final double phase;

  const _Harmonic({
    required this.freq,
    required this.amp,
    required this.speed,
    required this.phase,
  });
}

class _WaveRingConfig {
  final Color color;
  final double radiusScale;
  final List<_Harmonic> harmonics;
  final double strokeWidth;
  final double blur;
  final double fillAlpha;

  _WaveRingConfig({
    required this.color,
    required this.radiusScale,
    required this.harmonics,
    required this.strokeWidth,
    required this.blur,
    required this.fillAlpha,
  });
}

/// Custom painter for subtle holographic technical grid points.
class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.035)
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

/// Apple visionOS & Liquid Glass inspired Translucent Glass Bubble Container.
///
/// Designed as a real dynamic glass bubble: translucent (alpha: 0.20), refractive,
/// rounded, slightly floating with weightless suspension, convex specular meniscus
/// glares, and dynamic reactive lighting that subtly responds to background waveform ripples.
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
    this.blurSigma = 20.0,
    this.borderWidth = 1.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scope = LiquidGlassScope.maybeOf(context);
    final progress = scope?.progress ?? 0.0;

    // Subtle weightless floating oscillation (physically integrated bubble suspension)
    final floatY = scope != null
        ? math.sin(progress * 2.0 * math.pi) * 2.0
        : 0.0;

    // Generic grayish translucent look (no individual colored tints on the glass)
    final effectiveTint =
        tintColor ?? const Color(0xFF1E293B).withValues(alpha: 0.18);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            const Color(0xFF94A3B8).withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.01),
            const Color(0xFFCBD5E1).withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.28, 0.70, 1.0],
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
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: content,
        ),
      );
    }

    Widget bubble = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Soft ambient occlusion shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          // Subtle neutral glass edge reflection (breathing slightly with ambient waveform)
          BoxShadow(
            color: Colors.white.withValues(
                alpha: 0.04 + 0.02 * math.sin(progress * 2.0 * math.pi)),
            blurRadius: 28,
            spreadRadius: -2,
            offset: const Offset(0, 4),
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
                  progress: progress,
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
                    progress: progress,
                  ),
                  child: content,
                ),
              ),
      ),
    );

    if (floatY != 0.0) {
      bubble = Transform.translate(
        offset: Offset(0, floatY),
        child: bubble,
      );
    }

    return RepaintBoundary(child: bubble);
  }
}

/// Custom painter for the authentic Bubbly Liquid Glass specular highlight,
/// convex meniscus sheen, and dynamic reactive lighting reacting to background waves.
class _BubblyGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Color? glowColor;
  final double progress;

  const _BubblyGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.glowColor,
    this.progress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Dynamic reactive specular alignment (traveling glare catch reacting to circular waves)
    final lightX = -0.7 + 0.3 * math.cos(progress * 2.0 * math.pi * 0.5);
    final lightY = -0.8 + 0.2 * math.sin(progress * 2.0 * math.pi * 0.5);

    // 1. Primary Outer Specular Rim (High-contrast 45° shoulder catch)
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment(lightX, lightY),
        end: Alignment(lightX + 1.4, lightY + 1.6),
        colors: [
          Colors.white.withValues(alpha: 0.92),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.10),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.32),
        ],
        stops: const [0.0, 0.25, 0.65, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, primaryPaint);

    // 2. Secondary Inner Specular Bevel Line (Physical glass bubble lens thickness)
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
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.40],
        ).createShader(innerRect);

      canvas.drawRRect(innerRRect, innerPaint);
    }

    // 3. Convex Specular Meniscus Glare (Curved fluid sheen on top shoulder)
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
          begin: Alignment(lightX * 0.5, -1.0),
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(meniscusRect);

      canvas.drawRRect(meniscusRRect, meniscusPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblyGlassBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.progress != progress;
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
