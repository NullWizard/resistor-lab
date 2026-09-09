import 'dart:ui';
import 'package:flutter/material.dart';

/// Futuristic background with animated/ambient chromatic glowing energy orbs
/// and subtle holographic technical grid lines.
class FuturisticBackground extends StatelessWidget {
  final Widget child;

  const FuturisticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Deep Space Obsidian Canvas
        Container(
          color: const Color(0xFF030712),
        ),

        // 2. Top-Left Ambient Cyan Energy Orb
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.16),
                  const Color(0xFF00E5FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // 3. Right-Center Ambient Violet Plasma Orb
        Positioned(
          top: 280,
          right: -100,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFA855F7).withValues(alpha: 0.13),
                  const Color(0xFFA855F7).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // 4. Bottom-Left Ambient Cobalt Glow
        Positioned(
          bottom: -80,
          left: 40,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  const Color(0xFF3B82F6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // 5. Subtle Technical Grid Pattern
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TechGridPainter(),
            ),
          ),
        ),

        // 6. Child Content
        child,
      ],
    );
  }
}

/// Custom painter for subtle holographic technical grid points.
class _TechGridPainter extends CustomPainter {
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

/// Apple visionOS-inspired Liquid Glass Container.
///
/// Features:
/// - Real-time Gaussian backdrop blur (`BackdropFilter`)
/// - Translucent tinted glass body
/// - Specular reflection gradient border (light catching top-left edge)
/// - Subtle glowing drop shadow
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
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.tintColor,
    this.glowColor,
    this.blurSigma = 16.0,
    this.borderWidth = 1.2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tintColor ?? const Color(0xFF0F172A).withValues(alpha: 0.60);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: effectiveTint,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.01),
          ],
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
          splashColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.15),
          highlightColor: (glowColor ?? const Color(0xFF00E5FF)).withValues(alpha: 0.08),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.18),
              blurRadius: 20,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: CustomPaint(
            foregroundPainter: _GlassBorderPainter(
              borderRadius: borderRadius,
              borderWidth: borderWidth,
              glowColor: glowColor,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the beveled glass specular border highlight.
class _GlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Color? glowColor;

  _GlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glowColor != null
              ? glowColor!.withValues(alpha: 0.70)
              : Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.03),
          glowColor != null
              ? glowColor!.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.12),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.glowColor != glowColor;
}

/// VisionOS style Glass Pill Badge.
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: accentColor),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: 0.3,
            ),
          ),
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
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      glowColor: isPrimary ? accentColor : null,
      tintColor: isPrimary
          ? accentColor.withValues(alpha: 0.22)
          : const Color(0xFF0F172A).withValues(alpha: 0.55),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 17,
              color: isPrimary ? const Color(0xFFF8FAFC) : accentColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFFF8FAFC) : const Color(0xFFE2E8F0),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
