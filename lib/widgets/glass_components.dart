import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Calm Ambient Liquid Glass background featuring a deep dark obsidian canvas
/// with soft, subtle blurred ambient color pools that provide depth without distraction.
///
/// Strictly pinned to the screen viewport via a root [Stack] so that it remains
/// static in screen space while the foreground content scrolls smoothly over it.
/// Completely static GPU-cached layer painted once, saving battery and preventing distraction.
class FuturisticBackground extends StatelessWidget {
  final Widget child;

  const FuturisticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Calm Ambient Blur Canvas (Completely static GPU layer, painted ONCE)
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SimpleAmbientBlurBackgroundPainter(),
            ),
          ),
        ),

        // 2. Foreground Content (Isolated in its own GPU layer)
        Positioned.fill(
          child: RepaintBoundary(
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Static Ambient Blur Background Painter:
/// Combines a deep obsidian canvas with gentle, soft blurred color washes
/// (indigo, cyan, subtle rose, and twilight blue) that are quiet and non-distracting.
class _SimpleAmbientBlurBackgroundPainter extends CustomPainter {
  const _SimpleAmbientBlurBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Obsidian Base
    final bgPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final width = size.width;
    final height = size.height;

    // 2. Soft, calm ambient color pools with gentle radial falloffs
    // Orb 1: Upper-left soft indigo / violet wash
    final orb1Center = Offset(width * 0.22, height * 0.18);
    final orb1Radius = math.max(width, height) * 0.55;
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.15),
          const Color(0xFF6366F1).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: orb1Radius));
    canvas.drawCircle(orb1Center, orb1Radius, orb1Paint);

    // Orb 2: Mid-right soft cyan / sky wash
    final orb2Center = Offset(width * 0.82, height * 0.42);
    final orb2Radius = math.max(width, height) * 0.50;
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF06B6D4).withValues(alpha: 0.11),
          const Color(0xFF06B6D4).withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: orb2Radius));
    canvas.drawCircle(orb2Center, orb2Radius, orb2Paint);

    // Orb 3: Lower-left soft warm rose / magenta accent (very subtle)
    final orb3Center = Offset(width * 0.26, height * 0.76);
    final orb3Radius = math.max(width, height) * 0.46;
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEC4899).withValues(alpha: 0.07),
          const Color(0xFFEC4899).withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: orb3Center, radius: orb3Radius));
    canvas.drawCircle(orb3Center, orb3Radius, orb3Paint);

    // Orb 4: Center-bottom deep twilight blue accent to ground the composition
    final orb4Center = Offset(width * 0.68, height * 0.85);
    final orb4Radius = math.max(width, height) * 0.42;
    final orb4Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: orb4Center, radius: orb4Radius));
    canvas.drawCircle(orb4Center, orb4Radius, orb4Paint);
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
class GlassContainer extends StatefulWidget {
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
    this.borderRadius = 26.0,
    this.padding,
    this.margin,
    this.tintColor,
    this.glowColor,
    this.blurSigma = 26.0,
    this.borderWidth = 1.2,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Calibrated transparent grayish liquid glass (alpha: 0.22)
    final effectiveTint =
        widget.tintColor ?? const Color(0xFF0F172A).withValues(alpha: 0.22);

    Widget content = Container(
      padding: widget.padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: _isPressed ? 0.12 : 0.05),
            const Color(0xFF64748B).withValues(alpha: 0.02),
            Colors.transparent,
            const Color(0xFF1E293B).withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
        ),
      ),
      child: widget.child,
    );

    final isTappable = widget.onTap != null;

    final containerBody = Container(
      margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            // Soft ambient occlusion shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.30 : 0.45),
              blurRadius: _isPressed ? 16 : 28,
              offset: Offset(0, _isPressed ? 4 : 12),
            ),
            // Subtle neutral glass edge reflection / glow
            BoxShadow(
              color: (widget.glowColor ?? const Color(0xFF00E5FF))
                  .withValues(alpha: _isPressed ? 0.12 : 0.03),
              blurRadius: _isPressed ? 20 : 16,
              spreadRadius: _isPressed ? 1 : -2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: (kIsWeb || defaultTargetPlatform == TargetPlatform.android)
              ? CustomPaint(
                  foregroundPainter: _RealLiquidGlassBorderPainter(
                    borderRadius: widget.borderRadius,
                    borderWidth: widget.borderWidth,
                    isPressed: _isPressed,
                  ),
                  child: content,
                )
              : BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurSigma,
                    sigmaY: widget.blurSigma,
                  ),
                  child: CustomPaint(
                    foregroundPainter: _RealLiquidGlassBorderPainter(
                      borderRadius: widget.borderRadius,
                      borderWidth: widget.borderWidth,
                      isPressed: _isPressed,
                    ),
                    child: content,
                  ),
                ),
        ),
      );

    if (isTappable) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: containerBody,
        ),
      );
    }

    return containerBody;
  }
}

/// Custom painter for Authentic Real Liquid Glass refractive borders.
///
/// Features clean, realistic glass refraction bevels:
/// - Clean silver-white 45° light catch on the outer edge.
/// - Micro-inward secondary refraction bevel stroke simulating real glass thickness.
/// - Dynamic responsive glow catch on press.
class _RealLiquidGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final bool isPressed;

  const _RealLiquidGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.isPressed = false,
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
          Colors.white.withValues(alpha: isPressed ? 0.75 : 0.50),
          const Color(0xFFCBD5E1).withValues(alpha: isPressed ? 0.40 : 0.22),
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
            Colors.white.withValues(alpha: isPressed ? 0.35 : 0.18),
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
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.isPressed != isPressed;
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

/// Smooth visionOS & Apple Intelligence inspired fluid transition for sub-screens.
/// Avoids slide-stutter and lets the persistent background remain seamless.
class LiquidGlassPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  LiquidGlassPageRoute({required this.builder, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}
