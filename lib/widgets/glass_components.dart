import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Futuristic background with animated/ambient chromatic glowing energy orbs
/// and subtle holographic technical grid lines, isolated with RepaintBoundary
/// for 60/120 FPS rendering.
class FuturisticBackground extends StatelessWidget {
  final Widget child;

  const FuturisticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // 1. Deep Space Obsidian Canvas
          Container(
            color: const Color(0xFF030712),
          ),

          // 2. Top-Left Vibrant Cyan Aurora Energy Orb
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    const Color(0xFF00E5FF).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Right-Center Vibrant Violet Plasma Orb
          Positioned(
            top: 260,
            right: -120,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA855F7).withValues(alpha: 0.22),
                    const Color(0xFFA855F7).withValues(alpha: 0.06),
                    const Color(0xFFA855F7).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // 4. Center-Left Ambient Teal Glow
          Positioned(
            top: 600,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF14B8A6).withValues(alpha: 0.16),
                    const Color(0xFF14B8A6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom-Right Ambient Sapphire Glow
          Positioned(
            bottom: -100,
            right: 20,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.20),
                    const Color(0xFF3B82F6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 6. Subtle Technical Grid Pattern (cached in RepaintBoundary)
          Positioned.fill(
            child: IgnorePointer(
              child: const RepaintBoundary(
                child: CustomPaint(
                  painter: _TechGridPainter(),
                ),
              ),
            ),
          ),

          // 7. Child Content
          child,
        ],
      ),
    );
  }
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

/// Apple visionOS & Liquid Glass inspired High-Visibility Translucent Container.
///
/// Ref: https://liquidglassdesign.com/
/// Features:
/// - Optical surface luminance simulation with top-to-bottom specular wash
/// - Luminous beveled specular rim highlight (catching light on top-left edge)
/// - Inner lens thickness bevel stroke
/// - Zero-lag RepaintBoundary raster caching
/// - Hardware backdrop blur on native platforms, hardware-efficient shader gradient on web
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
    this.borderRadius = 22.0,
    this.padding,
    this.margin,
    this.tintColor,
    this.glowColor,
    this.blurSigma = 9.0,
    this.borderWidth = 1.4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint =
        tintColor ?? const Color(0xFF0C1322).withValues(alpha: 0.72);

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
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
            (glowColor ?? Colors.white).withValues(alpha: 0.06),
          ],
          stops: const [0.0, 0.20, 0.65, 1.0],
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
          splashColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.18),
          highlightColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.08),
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
            // Deep ambient occlusion shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.52),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            // Chromatic ambient bloom
            if (glowColor != null)
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.22),
                blurRadius: 26,
                spreadRadius: -3,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: kIsWeb
              ? CustomPaint(
                  foregroundPainter: _LiquidGlassBorderPainter(
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                    glowColor: glowColor,
                  ),
                  child: content,
                )
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: CustomPaint(
                    foregroundPainter: _LiquidGlassBorderPainter(
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

/// Custom painter for the beveled Liquid Glass specular border highlight.
/// Renders an outer specular catch and a subtle inner refractive edge.
class _LiquidGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Color? glowColor;

  const _LiquidGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Primary Outer Specular Border (light catching top-left shoulder)
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glowColor != null
              ? glowColor!.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.30),
          Colors.white.withValues(alpha: 0.08),
          glowColor != null
              ? glowColor!.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.22, 0.65, 1.0],
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
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.35],
        ).createShader(innerRect);

      canvas.drawRRect(innerRRect, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.glowColor != glowColor;
}

/// VisionOS & Liquid Glass style Rounded Capsule Pill.
/// Ref: https://liquidglassdesign.com/
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2.5, color: accentColor),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.9),
                    blurRadius: 5,
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

/// Floating circular liquid glass icon lens with specular border and ambient glow.
class LiquidGlassIconLens extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final double size;
  final double iconSize;

  const LiquidGlassIconLens({
    super.key,
    required this.icon,
    this.accentColor = const Color(0xFF00E5FF),
    this.size = 46.0,
    this.iconSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0B1220).withValues(alpha: 0.80),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.50),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.24),
            accentColor.withValues(alpha: 0.16),
            const Color(0xFF070C16).withValues(alpha: 0.70),
          ],
          stops: const [0.0, 0.35, 1.0],
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
                    accentColor.withValues(alpha: 0.35),
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
              color: accentColor.withValues(alpha: 0.75),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.85),
                  blurRadius: 6,
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
                    accentColor.withValues(alpha: 0.35),
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

/// High-visibility rounded liquid glass topic container for educational modules.
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
      borderRadius: 24,
      glowColor: accentColor,
      padding: const EdgeInsets.all(20.0),
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
                size: 46,
                iconSize: 22,
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
                        fontSize: 17.5,
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
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      glowColor: isPrimary ? accentColor : null,
      tintColor: isPrimary
          ? accentColor.withValues(alpha: 0.25)
          : const Color(0xFF0F172A).withValues(alpha: 0.65),
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

