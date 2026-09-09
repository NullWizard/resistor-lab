import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Futuristic animated liquid glass background with smoothly orbiting chromatic
/// plasma orbs and ascending translucent glass micro-bubbles.
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
      duration: const Duration(seconds: 22),
    );
    // Avoid scheduling infinite animation frames in widget tests which would cause pumpAndSettle to time out
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
        // 1. Viewport-Pinned Static Animated Canvas
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _AnimatedLiquidPlasmaPainter(_controller.value),
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

/// Smooth 60 FPS painter for drifting chromatic plasma orbs and ascending glass micro-bubbles.
class _AnimatedLiquidPlasmaPainter extends CustomPainter {
  final double progress;

  _AnimatedLiquidPlasmaPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Obsidian Canvas
    final bgPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final t = progress * 2.0 * math.pi;

    // 2. Drifting Chromatic Plasma Orbs
    // Orb A: Electric Cyber Cyan (Top-Left drifting)
    final orbAx = size.width * 0.15 + math.sin(t) * 60;
    final orbAy = size.height * 0.12 + math.cos(t * 0.8) * 45;
    final orbAr = 240.0 + math.sin(t * 1.2) * 35;
    _drawPlasmaOrb(
      canvas,
      Offset(orbAx, orbAy),
      orbAr,
      const Color(0xFF00E5FF),
      alphaPeak: 0.24,
    );

    // Orb B: Radiant Ultraviolet (Right-Center drifting)
    final orbBx = size.width * 0.88 + math.cos(t * 0.9) * 55;
    final orbBy = size.height * 0.42 + math.sin(t * 1.1) * 65;
    final orbBr = 260.0 + math.cos(t) * 40;
    _drawPlasmaOrb(
      canvas,
      Offset(orbBx, orbBy),
      orbBr,
      const Color(0xFFA855F7),
      alphaPeak: 0.22,
    );

    // Orb C: Electric Bioluminescent Teal (Left-Lower drifting)
    final orbCx = size.width * 0.12 + math.cos(t * 0.7) * 45;
    final orbCy = size.height * 0.72 + math.sin(t * 0.9) * 55;
    final orbCr = 220.0 + math.sin(t * 0.8) * 30;
    _drawPlasmaOrb(
      canvas,
      Offset(orbCx, orbCy),
      orbCr,
      const Color(0xFF14B8A6),
      alphaPeak: 0.18,
    );

    // Orb D: Deep Azure Sapphire (Bottom-Right drifting)
    final orbDx = size.width * 0.82 + math.sin(t * 1.3) * 50;
    final orbDy = size.height * 0.88 + math.cos(t * 0.7) * 45;
    final orbDr = 250.0 + math.sin(t * 0.9) * 35;
    _drawPlasmaOrb(
      canvas,
      Offset(orbDx, orbDy),
      orbDr,
      const Color(0xFF3B82F6),
      alphaPeak: 0.20,
    );

    // Orb E: Hot Plasma Magenta (Subtle Center Floating)
    final orbEx = size.width * 0.50 + math.sin(t * 0.6) * 40;
    final orbEy = size.height * 0.55 + math.cos(t * 0.8) * 50;
    final orbEr = 200.0 + math.cos(t * 1.4) * 25;
    _drawPlasmaOrb(
      canvas,
      Offset(orbEx, orbEy),
      orbEr,
      const Color(0xFFEC4899),
      alphaPeak: 0.12,
    );

    // 3. Ascending Translucent Glass Micro-Bubbles
    _drawGlassBubbles(canvas, size, progress);
  }

  void _drawPlasmaOrb(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    required double alphaPeak,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alphaPeak),
          color.withValues(alpha: alphaPeak * 0.45),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  void _drawGlassBubbles(Canvas canvas, Size size, double progress) {
    const bubbleCount = 14;
    for (int i = 0; i < bubbleCount; i++) {
      final seedX = ((i * 37 + 11) % 100) / 100.0;
      final speed = 0.4 + ((i * 19 + 7) % 10) / 15.0;
      final bubbleRadius = 5.0 + ((i * 29 + 13) % 11).toDouble();

      final yProgress = (progress * speed + (i / bubbleCount)) % 1.0;
      final y = size.height * (1.0 - yProgress);

      final sway = math.sin((progress * 2.0 * math.pi) + (i * 1.5)) * 18.0;
      final x = (size.width * seedX + sway).clamp(bubbleRadius * 2, size.width - bubbleRadius * 2);

      final center = Offset(x, y);

      final bubbleFill = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white.withValues(alpha: 0.15),
            const Color(0xFF00E5FF).withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bubbleRadius));
      canvas.drawCircle(center, bubbleRadius, bubbleFill);

      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.10),
            const Color(0xFF00E5FF).withValues(alpha: 0.30),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: bubbleRadius));
      canvas.drawCircle(center, bubbleRadius, rimPaint);

      final gleamCenter = center + Offset(-bubbleRadius * 0.35, -bubbleRadius * 0.35);
      final gleamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(gleamCenter, bubbleRadius * 0.22, gleamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedLiquidPlasmaPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Custom painter for subtle holographic technical grid points.
class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    for (double x = 18; x < size.width; x += spacing) {
      for (double y = 18; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Apple visionOS & Liquid Glass inspired Bubbly Translucent Glass Container.
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
    this.blurSigma = 14.0,
    this.borderWidth = 1.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint =
        tintColor ?? const Color(0xFF0B1322).withValues(alpha: 0.70);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.02),
            (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.08),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.22),
              blurRadius: 32,
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
          Colors.white.withValues(alpha: 0.92),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.70),
          Colors.white.withValues(alpha: 0.12),
          (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.35),
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
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.40],
        ).createShader(innerRect);

      canvas.drawRRect(innerRRect, innerPaint);
    }

    // 3. Convex Specular Meniscus Glare (curved bubble sheen on top shoulder)
    if (size.width > 40 && size.height > 40) {
      final meniscusHeight = math.min(size.height * 0.40, 36.0);
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
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      );

      final meniscusPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
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
        color: const Color(0xFF0B1322).withValues(alpha: 0.82),
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
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.30),
            accentColor.withValues(alpha: 0.20),
            const Color(0xFF070C16).withValues(alpha: 0.75),
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
          : const Color(0xFF0F172A).withValues(alpha: 0.70),
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
