import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_components.dart';

/// Enum representing the kinds of 3D resistor models available.
enum Resistor3DType {
  carbonComposition,
  carbonFilm,
  metalFilm,
  wireWound,
  potentiometer,
  rheostat,
  trimmer,
  ldr,
  thermistor,
  varistor,
  cementPower,
  smd,
}

/// A 3D Vector for geometry, camera transformations, and lighting math.
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 o) => Vector3(x + o.x, y + o.y, z + o.z);
  Vector3 operator -(Vector3 o) => Vector3(x - o.x, y - o.y, z - o.z);
  Vector3 operator *(double s) => Vector3(x * s, y * s, z * s);

  double dot(Vector3 o) => x * o.x + y * o.y + z * o.z;

  Vector3 cross(Vector3 o) => Vector3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => math.sqrt(x * x + y * y + z * z);

  Vector3 get normalized {
    final l = length;
    if (l < 1e-6) return const Vector3(0, 0, 1);
    return Vector3(x / l, y / l, z / l);
  }

  /// Rotate around X axis (pitch)
  Vector3 rotateX(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Vector3(x, y * c - z * s, y * s + z * c);
  }

  /// Rotate around Y axis (yaw)
  Vector3 rotateY(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Vector3(x * c + z * s, y, -x * s + z * c);
  }

  /// Rotate around Z axis (roll)
  Vector3 rotateZ(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Vector3(x * c - y * s, x * s + y * c, z);
  }
}

/// A 3D triangular face for realistic, watertight solid rendering.
class Face3D {
  final List<Vector3> vertices;
  final Color baseColor;
  final bool isMetallic;
  final bool isShaded;
  final bool doubleSided;

  Face3D({
    required this.vertices,
    required this.baseColor,
    this.isMetallic = false,
    this.isShaded = true,
    this.doubleSided = false,
  });

  double get avgZ {
    if (vertices.isEmpty) return 0;
    double sum = 0;
    for (final v in vertices) {
      sum += v.z;
    }
    return sum / vertices.length;
  }
}

/// A 3D line segment (for tracks, fine coils, or silkscreen text).
class Line3D {
  final Vector3 start;
  final Vector3 end;
  final Color color;
  final double strokeWidth;

  Line3D({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
  });

  double get avgZ => (start.z + end.z) / 2.0;
}

/// Interactive 3D Resistor Model Viewer widget.
class Resistor3DViewer extends StatefulWidget {
  final Resistor3DType type;
  final double height;
  final bool enableGesture;
  final bool showInspectButton;
  final String? title;

  const Resistor3DViewer({
    super.key,
    required this.type,
    this.height = 180,
    this.enableGesture = true,
    this.showInspectButton = true,
    this.title,
  });

  @override
  State<Resistor3DViewer> createState() => _Resistor3DViewerState();
}

class _Resistor3DViewerState extends State<Resistor3DViewer> {
  double _yaw = 0.52;
  double _pitch = -0.26;

  void _openInspectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => _Resistor3DInspectorDialog(
        type: widget.type,
        title: widget.title ?? _getResistorName(widget.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: widget.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF070C18).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.40),
            width: 1.3,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.03),
              const Color(0xFF00E5FF).withValues(alpha: 0.07),
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 22,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Holographic technical grid
            Positioned.fill(
              child: CustomPaint(
                painter: _ViewportGridPainter(),
              ),
            ),

            // Interactive 3D Model Viewport (touch/mouse drag)
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (widget.enableGesture) {
                    setState(() {
                      _yaw += details.delta.dx * 0.018;
                      _pitch = (_pitch - details.delta.dy * 0.018)
                          .clamp(-math.pi / 2.2, math.pi / 2.2);
                    });
                  }
                },
                onDoubleTap: () {
                  setState(() {
                    _yaw = 0.52;
                    _pitch = -0.26;
                  });
                },
                child: CustomPaint(
                  painter: _Resistor3DPainter(
                    type: widget.type,
                    yaw: _yaw,
                    pitch: _pitch,
                    zoom: 1.12,
                  ),
                ),
              ),
            ),

            // Top-Left CAD Tag
            Positioned(
              top: 10,
              left: 12,
              child: GlassBadge(
                label: '3D CAD MODEL',
                icon: Icons.view_in_ar_rounded,
                accentColor: const Color(0xFF00E5FF),
                fontSize: 9.5,
              ),
            ),

            // Top-Right Drag Hint
            Positioned(
              top: 12,
              right: 14,
              child: Text(
                'DRAG TO ROTATE 360°',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Bottom-Right Inspect / Fullscreen Button
            if (widget.showInspectButton)
              Positioned(
                bottom: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openInspectionDialog(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.50),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_full_rounded, size: 12, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 6),
                          Text(
                            'Inspect 3D',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF8FAFC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen high-resolution 3D model inspection dialog.
class _Resistor3DInspectorDialog extends StatefulWidget {
  final Resistor3DType type;
  final String title;

  const _Resistor3DInspectorDialog({
    required this.type,
    required this.title,
  });

  @override
  State<_Resistor3DInspectorDialog> createState() =>
      _Resistor3DInspectorDialogState();
}

class _Resistor3DInspectorDialogState extends State<_Resistor3DInspectorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationAnim;
  double _yaw = 0.52;
  double _pitch = -0.26;
  double _zoom = 1.50;
  bool _autoRotate = true;

  @override
  void initState() {
    super.initState();
    _rotationAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..addListener(() {
        if (_autoRotate) {
          setState(() {
            _yaw += 0.009;
            if (_yaw > math.pi * 2) _yaw -= math.pi * 2;
          });
        }
      });
    _rotationAnim.repeat();
  }

  @override
  void dispose() {
    _rotationAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 660),
        child: GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(22),
          glowColor: const Color(0xFF00E5FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const LiquidGlassIconLens(
                    icon: Icons.view_in_ar_rounded,
                    accentColor: Color(0xFF00E5FF),
                    size: 42,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Full 360° Solid CAD Structural View',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3D Viewport
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050914),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1E293B),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _ViewportGridPainter()),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onPanStart: (_) => setState(() => _autoRotate = false),
                          onPanUpdate: (details) {
                            setState(() {
                              _yaw += details.delta.dx * 0.015;
                              _pitch = (_pitch - details.delta.dy * 0.015)
                                  .clamp(-math.pi / 2.2, math.pi / 2.2);
                            });
                          },
                          child: CustomPaint(
                            painter: _Resistor3DPainter(
                              type: widget.type,
                              yaw: _yaw,
                              pitch: _pitch,
                              zoom: _zoom,
                            ),
                          ),
                        ),
                      ),
                      // Real-time HUD
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.80),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            'YAW: ${(_yaw * 180 / math.pi % 360).round()}° | PITCH: ${(_pitch * 180 / math.pi).round()}°',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Orbit Switch
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: InkWell(
                          onTap: () => setState(() => _autoRotate = !_autoRotate),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _autoRotate
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.20)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _autoRotate
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF334155),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _autoRotate
                                      ? Icons.motion_photos_on_rounded
                                      : Icons.motion_photos_off_rounded,
                                  size: 14,
                                  color: _autoRotate
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _autoRotate ? 'Orbit: ON' : 'Orbit: OFF',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: _autoRotate
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Zoom Controls
              Row(
                children: [
                  const Icon(Icons.zoom_out_rounded, size: 18, color: Color(0xFF94A3B8)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF00E5FF),
                        thumbColor: const Color(0xFF00E5FF),
                        inactiveTrackColor: const Color(0xFF1E293B),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _zoom,
                        min: 0.8,
                        max: 2.4,
                        onChanged: (v) => setState(() => _zoom = v),
                      ),
                    ),
                  ),
                  const Icon(Icons.zoom_in_rounded, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _yaw = 0.52;
                        _pitch = -0.26;
                        _zoom = 1.50;
                        _autoRotate = true;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: Text('Reset', style: GoogleFonts.spaceGrotesk(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCBD5E1),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Structural Callout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getResistorCallout(widget.type),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFCBD5E1),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Canvas painter for 100% solid, full-bodied 3D components.
class _Resistor3DPainter extends CustomPainter {
  final Resistor3DType type;
  final double yaw;
  final double pitch;
  final double zoom;

  static const double focalLength = 380.0;
  static final Vector3 lightDir = const Vector3(-0.35, -0.65, -0.65).normalized;

  _Resistor3DPainter({
    required this.type,
    required this.yaw,
    required this.pitch,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rawFaces = <Face3D>[];
    final rawLines = <Line3D>[];

    // 1. Build geometry
    _generateGeometry(rawFaces, rawLines);

    // 2. Rotate into camera space
    final transformedFaces = <Face3D>[];
    for (final face in rawFaces) {
      final tVerts = face.vertices.map((v) {
        return v.rotateX(pitch).rotateY(yaw) * zoom;
      }).toList();

      transformedFaces.add(Face3D(
        vertices: tVerts,
        baseColor: face.baseColor,
        isMetallic: face.isMetallic,
        isShaded: face.isShaded,
        doubleSided: face.doubleSided,
      ));
    }

    final transformedLines = <Line3D>[];
    for (final line in rawLines) {
      final tStart = line.start.rotateX(pitch).rotateY(yaw) * zoom;
      final tEnd = line.end.rotateX(pitch).rotateY(yaw) * zoom;
      transformedLines.add(Line3D(
        start: tStart,
        end: tEnd,
        color: line.color,
        strokeWidth: line.strokeWidth * zoom,
      ));
    }

    // 3. Project & sort depth
    final renderables = <_Renderable>[];

    for (final face in transformedFaces) {
      if (face.vertices.length < 3) continue;

      // 3D camera-space normal check
      final v0 = face.vertices[0];
      final v1 = face.vertices[1];
      final v2 = face.vertices[2];
      final normal = (v1 - v0).cross(v2 - v0);

      // In camera space looking along +Z, if normal.z > 0, it points away from camera
      // Culling true backfaces prevents drawing interior faces while maintaining solid look
      if (normal.z > 0.05 && !face.doubleSided) {
        continue;
      }

      final projectedPts = face.vertices.map((v) => _project(center, v)).toList();

      renderables.add(_Renderable(
        z: face.avgZ,
        face: face,
        projectedPts: projectedPts,
      ));
    }

    for (final line in transformedLines) {
      renderables.add(_Renderable(
        z: line.avgZ,
        line: line,
      ));
    }

    // Sort descending: furthest elements painted first, closest in front
    renderables.sort((a, b) => b.z.compareTo(a.z));

    // 4. Render
    for (final item in renderables) {
      if (item.line != null) {
        _renderLine(canvas, center, item.line!);
      } else if (item.face != null && item.projectedPts != null) {
        _renderFace(canvas, item.face!, item.projectedPts!);
      }
    }
  }

  void _renderLine(Canvas canvas, Offset center, Line3D line) {
    final p1 = _project(center, line.start);
    final p2 = _project(center, line.end);

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = math.max(1.0, line.strokeWidth)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, paint);
  }

  void _renderFace(Canvas canvas, Face3D face, List<Offset> pts) {
    if (pts.length < 3) return;

    Color renderColor = face.baseColor;
    if (face.isShaded) {
      final v0 = face.vertices[0];
      final v1 = face.vertices[1];
      final v2 = face.vertices[2];
      final normal = (v1 - v0).cross(v2 - v0).normalized;

      final nDotL = -normal.dot(lightDir);
      final diffuse = (0.35 + 0.65 * math.max(0.0, nDotL)).clamp(0.0, 1.0);

      final rZ = lightDir.z - 2.0 * (lightDir.dot(normal)) * normal.z;
      final specBase = math.max(0.0, -rZ);
      final specPower = face.isMetallic ? 14.0 : 4.0;
      final specIntensity = face.isMetallic ? 0.60 : 0.20;
      final spec = math.pow(specBase, specPower) * specIntensity;

      final baseR = (face.baseColor.r * 255.0).round();
      final baseG = (face.baseColor.g * 255.0).round();
      final baseB = (face.baseColor.b * 255.0).round();
      final baseA = (face.baseColor.a * 255.0).round();

      final r = (baseR * diffuse + 255 * spec).clamp(0, 255).toInt();
      final g = (baseG * diffuse + 255 * spec).clamp(0, 255).toInt();
      final b = (baseB * diffuse + 255 * spec).clamp(0, 255).toInt();

      renderColor = Color.fromARGB(baseA, r, g, b);
    }

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();

    final paint = Paint()
      ..color = renderColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Offset _project(Offset center, Vector3 v) {
    final scale = focalLength / (focalLength + v.z);
    return Offset(center.dx + v.x * scale, center.dy + v.y * scale);
  }

  // ===========================================================================
  // 100% SOLID WATERTIGHT 3D MODEL GENERATORS
  // ===========================================================================

  void _generateGeometry(List<Face3D> faces, List<Line3D> lines) {
    switch (type) {
      case Resistor3DType.carbonComposition:
        _buildSolidAxialLathe(
          faces,
          lines,
          bodyColor: const Color(0xFF2C221C), // Phenolic charcoal
          bands: [
            const Color(0xFF9A5B2D), // Brown (1)
            Colors.black,            // Black (0)
            const Color(0xFFFF9800), // Orange (x1k)
            const Color(0xFFFFD700), // Gold (±5%)
          ],
        );
        break;

      case Resistor3DType.carbonFilm:
        _buildSolidAxialLathe(
          faces,
          lines,
          bodyColor: const Color(0xFFD4B07B), // Warm beige ceramic
          hasHelicalGroove: true,
          bands: [
            const Color(0xFF9A5B2D), // Brown (1)
            Colors.black,            // Black (0)
            const Color(0xFFE53935), // Red (x100)
            const Color(0xFFFFD700), // Gold (±5%)
          ],
        );
        break;

      case Resistor3DType.metalFilm:
        _buildSolidAxialLathe(
          faces,
          lines,
          bodyColor: const Color(0xFF0284C7), // Precision sky-blue
          bands: [
            const Color(0xFF9A5B2D), // Brown (1)
            Colors.black,            // Black (0)
            Colors.black,            // Black (0)
            const Color(0xFF9A5B2D), // Brown (x10)
            const Color(0xFF9A5B2D), // Brown (±1%)
          ],
        );
        break;

      case Resistor3DType.wireWound:
        _buildWireWoundResistor(faces, lines);
        break;

      case Resistor3DType.potentiometer:
        _buildPotentiometer(faces, lines);
        break;

      case Resistor3DType.rheostat:
        _buildRheostat(faces, lines);
        break;

      case Resistor3DType.trimmer:
        _buildTrimmer(faces, lines);
        break;

      case Resistor3DType.ldr:
        _buildLDR(faces, lines);
        break;

      case Resistor3DType.thermistor:
        _buildThermistor(faces, lines);
        break;

      case Resistor3DType.varistor:
        _buildVaristor(faces, lines);
        break;

      case Resistor3DType.cementPower:
        _buildCementResistor(faces, lines);
        break;

      case Resistor3DType.smd:
        _buildSMDResistor(faces, lines);
        break;
    }
  }

  /// 1. Continuous Lathe Surface of Revolution for Axial Resistors (100% Watertight Solid)
  void _buildSolidAxialLathe(
    List<Face3D> faces,
    List<Line3D> lines, {
    required Color bodyColor,
    required List<Color> bands,
    bool hasHelicalGroove = false,
  }) {
    const halfLen = 38.0;
    const bodyR = 15.0;
    const neckR = 14.2;
    const shoulderR = 16.0;
    const capR = 12.0;
    const segs = 18;

    // Solid 3D Metallic Cylindrical Leads
    _buildSolidCylinderX(faces, const Vector3(-halfLen - 46, 0, 0), 46, 2.5, 10,
        const Color(0xFFE2E8F0), isMetallic: true);
    _buildSolidCylinderX(faces, const Vector3(halfLen, 0, 0), 46, 2.5, 10,
        const Color(0xFFE2E8F0), isMetallic: true);

    // Profile of continuous solid dogbone lathe: [x, radius, isCap, isBand, color]
    final profile = <_LatheSlice>[
      _LatheSlice(-halfLen, capR, const Color(0xFFCBD5E1), isMetallic: true),
      _LatheSlice(-halfLen + 4, capR, const Color(0xFFCBD5E1), isMetallic: true),
      _LatheSlice(-halfLen + 9, shoulderR, bodyColor),
      _LatheSlice(-halfLen + 15, neckR, bodyColor),
    ];

    // Slices for color bands and body
    final centerSpan = (halfLen - 15) * 2;
    final bandSpacing = centerSpan / (bands.length + 1);
    for (int b = 0; b < bands.length; b++) {
      final bx = -halfLen + 15 + (b + 1) * bandSpacing;
      profile.add(_LatheSlice(bx - 2.5, bodyR, bodyColor));
      profile.add(_LatheSlice(bx - 2.2, bodyR + 0.35, bands[b]));
      profile.add(_LatheSlice(bx + 2.2, bodyR + 0.35, bands[b]));
      profile.add(_LatheSlice(bx + 2.5, bodyR, bodyColor));
    }

    profile.addAll([
      _LatheSlice(halfLen - 15, neckR, bodyColor),
      _LatheSlice(halfLen - 9, shoulderR, bodyColor),
      _LatheSlice(halfLen - 4, capR, const Color(0xFFCBD5E1), isMetallic: true),
      _LatheSlice(halfLen, capR, const Color(0xFFCBD5E1), isMetallic: true),
    ]);

    // Generate ring vertices
    final rings = <List<Vector3>>[];
    for (final s in profile) {
      final ring = <Vector3>[];
      for (int i = 0; i < segs; i++) {
        final a = (i / segs) * 2 * math.pi;
        ring.add(Vector3(s.x, math.cos(a) * s.radius, math.sin(a) * s.radius));
      }
      rings.add(ring);
    }

    // Connect adjacent slices with solid triangles
    for (int r = 0; r < rings.length - 1; r++) {
      final r1 = rings[r];
      final r2 = rings[r + 1];
      final color = profile[r].color;
      final isMetallic = profile[r].isMetallic;

      for (int i = 0; i < segs; i++) {
        final next = (i + 1) % segs;
        final p1 = r1[i];
        final p2 = r1[next];
        final p3 = r2[next];
        final p4 = r2[i];

        faces.add(Face3D(
          vertices: [p1, p2, p3],
          baseColor: color,
          isMetallic: isMetallic,
        ));
        faces.add(Face3D(
          vertices: [p1, p3, p4],
          baseColor: color,
          isMetallic: isMetallic,
        ));
      }
    }

    // Sealed solid end caps
    final leftCenter = Vector3(profile.first.x, 0, 0);
    for (int i = 0; i < segs; i++) {
      final next = (i + 1) % segs;
      faces.add(Face3D(
        vertices: [leftCenter, rings.first[next], rings.first[i]],
        baseColor: const Color(0xFFCBD5E1),
        isMetallic: true,
      ));
    }

    final rightCenter = Vector3(profile.last.x, 0, 0);
    for (int i = 0; i < segs; i++) {
      final next = (i + 1) % segs;
      faces.add(Face3D(
        vertices: [rightCenter, rings.last[i], rings.last[next]],
        baseColor: const Color(0xFFCBD5E1),
        isMetallic: true,
      ));
    }

    // Helical Spiral Cut for Carbon Film Resistor
    if (hasHelicalGroove) {
      for (double x = -halfLen + 15; x < halfLen - 15; x += 1.8) {
        final angle = (x * 0.50);
        final p = Vector3(x, math.cos(angle) * (bodyR + 0.5), math.sin(angle) * (bodyR + 0.5));
        lines.add(Line3D(
          start: p,
          end: p + const Vector3(1.4, 0.6, 0.6),
          color: const Color(0xFF3E1D0C),
          strokeWidth: 2.2,
        ));
      }
    }
  }

  /// Solid 3D metallic helical wire coils wrapped around an X-axis cylinder
  void _build3DWireCoilX(
    List<Face3D> faces, {
    required double startX,
    required double length,
    required double coreRadius,
    required double wireThickness,
    required int turns,
    required int segsPerTurn,
    required Color wireColor,
    bool isMetallic = true,
  }) {
    final totalSteps = turns * segsPerTurn;
    final pitch = length / turns;
    final rOut = coreRadius + wireThickness;

    for (int step = 0; step < totalSteps; step++) {
      final t1 = step / totalSteps;
      final t2 = (step + 1) / totalSteps;
      final x1 = startX + t1 * length;
      final x2 = startX + t2 * length;

      final a1 = (step % segsPerTurn) / segsPerTurn * 2.0 * math.pi;
      final a2 = ((step + 1) % segsPerTurn) / segsPerTurn * 2.0 * math.pi;

      final o1 = Vector3(x1, math.cos(a1) * rOut, math.sin(a1) * rOut);
      final o2 = Vector3(x2, math.cos(a2) * rOut, math.sin(a2) * rOut);
      final halfW = pitch * 0.38;

      final v0 = Vector3(o1.x - halfW, o1.y, o1.z);
      final v1 = Vector3(o1.x + halfW, o1.y, o1.z);
      final v2 = Vector3(o2.x + halfW, o2.y, o2.z);
      final v3 = Vector3(o2.x - halfW, o2.y, o2.z);

      // Verified counterclockwise outward normal for correct specular reflection
      faces.add(Face3D(
        vertices: [v0, v3, v2],
        baseColor: wireColor,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [v0, v2, v1],
        baseColor: wireColor,
        isMetallic: isMetallic,
      ));
    }
  }

  /// 2. Wire Wound Resistor (100% Solid 3D ceramic core, 3D metallic Nichrome coils, crimp collars)
  void _buildWireWoundResistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 16.0;
    const length = 84.0;
    const segs = 18;

    // Solid Leads
    _buildSolidCylinderX(faces, const Vector3(-length / 2 - 46, 0, 0), 46, 2.5, 10,
        const Color(0xFFF1F5F9), isMetallic: true);
    _buildSolidCylinderX(faces, Vector3(length / 2, 0, 0), 46, 2.5, 10,
        const Color(0xFFF1F5F9), isMetallic: true);

    // Ceramic Porcelain Core Cylinder (Solid)
    _buildSolidCylinderX(faces, Vector3(-length / 2, 0, 0), length, radius, segs,
        const Color(0xFFF8FAFC));

    // Stamped Metallic Crimp Band Collars (Clamping resistance wire at ends)
    _buildSolidCylinderX(faces, Vector3(-length / 2, 0, 0), 12, radius + 1.2, segs,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderX(faces, Vector3(length / 2 - 12, 0, 0), 12, radius + 1.2, segs,
        const Color(0xFFCBD5E1), isMetallic: true);

    // Solid 3D Metallic Nichrome Wire Coils (Gleaming copper/amber alloy turns)
    _build3DWireCoilX(
      faces,
      startX: -length / 2 + 13,
      length: length - 26,
      coreRadius: radius,
      wireThickness: 1.4,
      turns: 20,
      segsPerTurn: 16,
      wireColor: const Color(0xFFEA580C),
      isMetallic: true,
    );

    // Semi-translucent protective Vitreous Enamel Glaze (Center green band letting coils gleam)
    _buildSolidCylinderX(faces, const Vector3(-16, 0, 0), 32, radius + 1.5, segs,
        const Color(0xFF047857).withValues(alpha: 0.85), isMetallic: true);
  }

  /// 3. Potentiometer (Solid cylindrical metal can, brass bushing, hex nut, shaft, lugs)
  void _buildPotentiometer(List<Face3D> faces, List<Line3D> lines) {
    // 1. Metal Cylindrical Housing Can (along Z)
    _buildSolidCylinderZ(
      faces,
      const Vector3(0, -6, -20),
      20.0,
      24.0,
      18,
      const Color(0xFF64748B),
      isMetallic: true,
    );

    // 2. Threaded Brass Bushing Collar
    _buildSolidCylinderZ(
      faces,
      const Vector3(0, -6, 0),
      14.0,
      11.0,
      18,
      const Color(0xFFCA8A04),
      isMetallic: true,
    );

    // 3. Stamped Hexagonal Locking Nut (6-sided prism)
    _buildSolidCylinderZ(
      faces,
      const Vector3(0, -6, 4),
      4.0,
      15.0,
      6,
      const Color(0xFFEAB308),
      isMetallic: true,
    );

    // 4. Rotating Metal Control Shaft
    _buildSolidCylinderZ(
      faces,
      const Vector3(0, -6, 14),
      24.0,
      7.0,
      16,
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );

    // Shaft Flat Notch line
    lines.add(Line3D(
      start: const Vector3(-5, -6, 38),
      end: const Vector3(5, -6, 38),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.4,
    ));

    // 5. 3 Stamped Solder Lugs (Bottom)
    for (int i = -1; i <= 1; i++) {
      final x = i * 14.0;
      _buildSolidBox(
        faces,
        Vector3(x - 3.5, 18, -12),
        const Vector3(7, 24, 2.5),
        const Color(0xFFCBD5E1),
        isMetallic: true,
      );

      lines.add(Line3D(
        start: Vector3(x - 2, 36, -10.5),
        end: Vector3(x + 2, 36, -10.5),
        color: const Color(0xFF0F172A),
        strokeWidth: 2.2,
      ));
    }
  }

  /// 4. Rheostat (Porcelain winding tube, dense 3D metallic wire turns, brush contact track, slider carriage, cast A-frames, knurled terminals)
  void _buildRheostat(List<Face3D> faces, List<Line3D> lines) {
    const length = 94.0;
    const radius = 18.0;
    const segs = 20;

    // 1. Hollow Glazed Ceramic Porcelain Coil Tube
    _buildSolidCylinderX(faces, Vector3(-length / 2, 6, 0), length, radius, segs,
        const Color(0xFFF1F5F9));

    // 2. Dense Solid 3D Metallic Resistance Wire Winding (30 turns of Nichrome bronze wire)
    _build3DWireCoilX(
      faces,
      startX: -length / 2 + 7,
      length: length - 14,
      coreRadius: radius,
      wireThickness: 1.3,
      turns: 30,
      segsPerTurn: 16,
      wireColor: const Color(0xFFD97706),
      isMetallic: true,
    );

    // 3. Exposed Top Brushed Silver Contact Track (where insulation is ground for slider brush)
    _buildSolidBox(
      faces,
      Vector3(-length / 2 + 7, 6 - radius - 1.4, -3.5),
      Vector3(length - 14, 0.9, 7.0),
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );

    // 4. Sturdy Cast Metal End A-Frames (Left & Right support brackets with base feet)
    for (final isLeft in [true, false]) {
      final x = isLeft ? -length / 2 - 4.0 : length / 2;
      // Vertical end plate holding tube
      _buildSolidBox(
        faces,
        Vector3(x, -22, -12),
        const Vector3(4.0, 48.0, 24.0),
        const Color(0xFF334155),
        isMetallic: true,
      );
      // Stable horizontal base foot
      _buildSolidBox(
        faces,
        Vector3(x - 2.0, 24, -18),
        const Vector3(8.0, 5.0, 36.0),
        const Color(0xFF1E293B),
        isMetallic: true,
      );
    }

    // 5. Solid Hexagonal / Cylindrical Top Chrome Slider Guide Rod
    _buildSolidCylinderX(
      faces,
      Vector3(-length / 2 - 8, -18, 0),
      length + 16,
      2.6,
      12,
      const Color(0xFFCBD5E1),
      isMetallic: true,
    );

    // 6. Detailed Slider Wiper Carriage (Positioned near center x = -6)
    const wiperX = -6.0;
    // Wiper carriage body (Phenolic insulated block)
    _buildSolidBox(
      faces,
      const Vector3(wiperX - 9, -24, -10),
      const Vector3(18, 12, 20),
      const Color(0xFF0F172A),
    );
    // Fluted adjustment knob on top
    _buildSolidCylinderY(
      faces,
      const Vector3(wiperX, -28, 0),
      4.0,
      7.0,
      14,
      const Color(0xFF1E293B),
    );
    // Machined Spring Brass Wiper Blade Contact (pressing firmly against top silver brush track)
    _buildSolidBox(
      faces,
      const Vector3(wiperX - 5, -13, -5),
      const Vector3(10, 6.5, 10),
      const Color(0xFFCA8A04),
      isMetallic: true,
    );

    // 7. Heavy Brass Knurled Terminal Binding Posts (2 for coil ends, 1 for slider bar)
    // Left coil terminal
    _buildSolidCylinderZ(
      faces,
      Vector3(-length / 2 - 2, 16, -14),
      10,
      4.5,
      10,
      const Color(0xFFEAB308),
      isMetallic: true,
    );
    // Right coil terminal
    _buildSolidCylinderZ(
      faces,
      Vector3(length / 2 - 2, 16, -14),
      10,
      4.5,
      10,
      const Color(0xFFEAB308),
      isMetallic: true,
    );
    // Top slider guide bar terminal (Right top)
    _buildSolidCylinderZ(
      faces,
      Vector3(length / 2 - 2, -18, -14),
      10,
      4.5,
      10,
      const Color(0xFFEAB308),
      isMetallic: true,
    );
  }

  /// 5. Preset Trimmer (Bourns 3296 sealed blue cermet case, golden screw, 3 pins)
  void _buildTrimmer(List<Face3D> faces, List<Line3D> lines) {
    // Ultramarine Blue Casing
    _buildSolidBox(faces, const Vector3(-24, -24, -16), const Vector3(48, 46, 32),
        const Color(0xFF1D4ED8));

    // Top Brass Adjustment Screw Head
    _buildSolidCylinderY(faces, const Vector3(10, -28, 0), 4, 6.5, 14,
        const Color(0xFFEAB308), isMetallic: true);

    // Cross Screw Slot (+)
    lines.add(Line3D(
      start: const Vector3(6, -28.5, -3.5),
      end: const Vector3(14, -28.5, 3.5),
      color: const Color(0xFF713F12),
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(10, -28.5, -3.5),
      end: const Vector3(10, -28.5, 3.5),
      color: const Color(0xFF713F12),
      strokeWidth: 2.0,
    ));

    // 3 Gold-Plated PCB Solder Pins (Bottom Solid Cylinders)
    for (int i = -1; i <= 1; i++) {
      final x = i * 13.0;
      _buildSolidCylinderY(faces, Vector3(x, 22, 0), 22, 1.6, 8,
          const Color(0xFFFBBF24), isMetallic: true);
    }
  }

  /// 6. LDR (Light Dependent Resistor: forward-facing disc, CdS zigzag track, brass bezel)
  void _buildLDR(List<Face3D> faces, List<Line3D> lines) {
    const radius = 26.0;
    const segs = 20;

    // Ceramic Base Disc along Z
    _buildSolidCylinderZ(faces, const Vector3(0, 0, -6), 8, radius, segs,
        const Color(0xFFE2E8F0));

    // Golden Bezel Rim
    _buildSolidCylinderZ(faces, const Vector3(0, 0, 1), 2, radius + 1.2, segs,
        const Color(0xFFCA8A04), isMetallic: true);

    // Clear Optical Face (Yellow-tinted epoxy)
    _buildSolidCylinderZ(faces, const Vector3(0, 0, 2), 1, radius - 0.5, segs,
        const Color(0xFFFEF08A));

    // Serpentine Zigzag CdS Photoconductive Track Pattern
    final pts = <Vector3>[
      const Vector3(-18, -16, 3.2),
      const Vector3(18, -16, 3.2),
      const Vector3(18, -8, 3.2),
      const Vector3(-18, -8, 3.2),
      const Vector3(-18, 0, 3.2),
      const Vector3(18, 0, 3.2),
      const Vector3(18, 8, 3.2),
      const Vector3(-18, 8, 3.2),
      const Vector3(-18, 16, 3.2),
      const Vector3(18, 16, 3.2),
    ];
    for (int i = 0; i < pts.length - 1; i++) {
      lines.add(Line3D(
        start: pts[i],
        end: pts[i + 1],
        color: const Color(0xFFDC2626),
        strokeWidth: 2.8,
      ));
    }

    // 2 Rear Leads (Solid Cylinders)
    _buildSolidCylinderZ(faces, const Vector3(-10, 0, -46), 40, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderZ(faces, const Vector3(10, 0, -46), 40, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
  }

  /// 7. Thermistor (Glossy organic ceramic bead with kinked dual leads)
  void _buildThermistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 20.0;

    // Solid Spheroid Bead Body
    _buildSolidSphere(faces, const Vector3(0, 0, 0), radius, 12, 16,
        const Color(0xFF0D9488), isMetallic: true);

    // Leads (Solid Cylinders with Kink)
    _buildSolidCylinderY(faces, Vector3(-6, radius - 2, 0), 14, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderY(faces, Vector3(-9, radius + 12, 0), 32, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);

    _buildSolidCylinderY(faces, Vector3(6, radius - 2, 0), 14, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderY(faces, Vector3(9, radius + 12, 0), 32, 1.6, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
  }

  /// 8. Varistor (MOV Radial Disc with Silkscreen markings)
  void _buildVaristor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 28.0;
    const thickness = 8.0;
    const segs = 20;

    // Disc Body along Z (High-Voltage Blue MOV)
    _buildSolidCylinderZ(
      faces,
      const Vector3(0, -6, -thickness / 2),
      thickness,
      radius,
      segs,
      const Color(0xFF1D4ED8),
    );

    // 2 Radial Leads (Solid Cylinders)
    _buildSolidCylinderY(faces, Vector3(-10, radius - 6, 0), 44, 1.8, 8,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderY(faces, Vector3(10, radius - 6, 0), 44, 1.8, 8,
        const Color(0xFFCBD5E1), isMetallic: true);

    // Stamped markings silkscreen
    lines.add(Line3D(
      start: const Vector3(-14, -10, thickness / 2 + 0.6),
      end: const Vector3(14, -10, thickness / 2 + 0.6),
      color: const Color(0xFF93C5FD),
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(-10, -2, thickness / 2 + 0.6),
      end: const Vector3(10, -2, thickness / 2 + 0.6),
      color: const Color(0xFF93C5FD),
      strokeWidth: 2.0,
    ));
  }

  /// 9. Cement Power Resistor (Ceramic Block)
  void _buildCementResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 80.0;
    const width = 24.0;
    const height = 24.0;

    // White Ceramic Prism Brick
    _buildSolidBox(
      faces,
      Vector3(-length / 2, -height / 2, -width / 2),
      const Vector3(length, height, width),
      const Color(0xFFF8FAFC),
    );

    // Stamped wattage markings lines
    lines.add(Line3D(
      start: const Vector3(-22, -4, width / 2 + 0.6),
      end: const Vector3(22, -4, width / 2 + 0.6),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(-16, 5, width / 2 + 0.6),
      end: const Vector3(16, 5, width / 2 + 0.6),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.2,
    ));

    // Heavy Tinned Solid Leads
    _buildSolidCylinderX(faces, const Vector3(-length / 2 - 44, 0, 0), 44, 2.5, 10,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildSolidCylinderX(faces, Vector3(length / 2, 0, 0), 44, 2.5, 10,
        const Color(0xFFCBD5E1), isMetallic: true);
  }

  /// 10. SMD Resistor (0805 Surface Mount Chip)
  void _buildSMDResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 64.0;
    const height = 12.0;
    const width = 32.0;
    const capWidth = 12.0;

    // Black Ceramic Body (Center)
    _buildSolidBox(
      faces,
      Vector3(-length / 2 + capWidth, -height / 2, -width / 2),
      const Vector3(length - capWidth * 2, height, width),
      const Color(0xFF0F172A),
    );

    // Silver Wrap-Around Solder Terminations (Left & Right)
    _buildSolidBox(
      faces,
      Vector3(-length / 2, -height / 2, -width / 2),
      const Vector3(capWidth, height, width),
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );
    _buildSolidBox(
      faces,
      Vector3(length / 2 - capWidth, -height / 2, -width / 2),
      const Vector3(capWidth, height, width),
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );

    // Stamped "103" SMD Code
    lines.add(Line3D(
      start: const Vector3(-9, -height / 2 - 0.6, -6),
      end: const Vector3(-9, -height / 2 - 0.6, 6),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(0, -height / 2 - 0.6, -6),
      end: const Vector3(0, -height / 2 - 0.6, 6),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(9, -height / 2 - 0.6, -6),
      end: const Vector3(9, -height / 2 - 0.6, 6),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
  }

  // ===========================================================================
  // 100% SOLID WATERTIGHT PRIMITIVE HELPERS
  // ===========================================================================

  void _buildSolidCylinderX(
    List<Face3D> faces,
    Vector3 origin,
    double length,
    double radius,
    int segments,
    Color color, {
    bool isMetallic = false,
  }) {
    final leftCap = <Vector3>[];
    final rightCap = <Vector3>[];

    for (int i = 0; i < segments; i++) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;

      final y1 = math.cos(a1) * radius;
      final z1 = math.sin(a1) * radius;
      final y2 = math.cos(a2) * radius;
      final z2 = math.sin(a2) * radius;

      final p1 = origin + Vector3(0, y1, z1);
      final p2 = origin + Vector3(0, y2, z2);
      final p3 = origin + Vector3(length, y2, z2);
      final p4 = origin + Vector3(length, y1, z1);

      // Two triangles per quad for planar accuracy
      faces.add(Face3D(
        vertices: [p1, p2, p3],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [p1, p3, p4],
        baseColor: color,
        isMetallic: isMetallic,
      ));

      leftCap.add(p1);
      rightCap.add(p4);
    }

    final leftCenter = origin;
    final rightCenter = origin + Vector3(length, 0, 0);
    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      faces.add(Face3D(
        vertices: [leftCenter, leftCap[next], leftCap[i]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [rightCenter, rightCap[i], rightCap[next]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
    }
  }

  void _buildSolidCylinderY(
    List<Face3D> faces,
    Vector3 origin,
    double length,
    double radius,
    int segments,
    Color color, {
    bool isMetallic = false,
  }) {
    final bottomCap = <Vector3>[];
    final topCap = <Vector3>[];

    for (int i = 0; i < segments; i++) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;

      final x1 = math.cos(a1) * radius;
      final z1 = math.sin(a1) * radius;
      final x2 = math.cos(a2) * radius;
      final z2 = math.sin(a2) * radius;

      final p1 = origin + Vector3(x1, 0, z1);
      final p2 = origin + Vector3(x2, 0, z2);
      final p3 = origin + Vector3(x2, length, z2);
      final p4 = origin + Vector3(x1, length, z1);

      faces.add(Face3D(
        vertices: [p1, p4, p3],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [p1, p3, p2],
        baseColor: color,
        isMetallic: isMetallic,
      ));

      bottomCap.add(p1);
      topCap.add(p4);
    }

    final bottomCenter = origin;
    final topCenter = origin + Vector3(0, length, 0);
    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      faces.add(Face3D(
        vertices: [bottomCenter, bottomCap[next], bottomCap[i]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [topCenter, topCap[i], topCap[next]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
    }
  }

  void _buildSolidCylinderZ(
    List<Face3D> faces,
    Vector3 origin,
    double length,
    double radius,
    int segments,
    Color color, {
    bool isMetallic = false,
  }) {
    final backCap = <Vector3>[];
    final frontCap = <Vector3>[];

    for (int i = 0; i < segments; i++) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;

      final x1 = math.cos(a1) * radius;
      final y1 = math.sin(a1) * radius;
      final x2 = math.cos(a2) * radius;
      final y2 = math.sin(a2) * radius;

      final p1 = origin + Vector3(x1, y1, 0);
      final p2 = origin + Vector3(x2, y2, 0);
      final p3 = origin + Vector3(x2, y2, length);
      final p4 = origin + Vector3(x1, y1, length);

      faces.add(Face3D(
        vertices: [p1, p2, p3],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [p1, p3, p4],
        baseColor: color,
        isMetallic: isMetallic,
      ));

      backCap.add(p1);
      frontCap.add(p4);
    }

    final backCenter = origin;
    final frontCenter = origin + Vector3(0, 0, length);
    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      faces.add(Face3D(
        vertices: [backCenter, backCap[next], backCap[i]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
      faces.add(Face3D(
        vertices: [frontCenter, frontCap[i], frontCap[next]],
        baseColor: color,
        isMetallic: isMetallic,
      ));
    }
  }

  void _buildSolidBox(
    List<Face3D> faces,
    Vector3 origin,
    Vector3 size,
    Color color, {
    bool isMetallic = false,
  }) {
    final p000 = origin;
    final p100 = origin + Vector3(size.x, 0, 0);
    final p110 = origin + Vector3(size.x, size.y, 0);
    final p010 = origin + Vector3(0, size.y, 0);
    final p001 = origin + Vector3(0, 0, size.z);
    final p101 = origin + Vector3(size.x, 0, size.z);
    final p111 = origin + size;
    final p011 = origin + Vector3(0, size.y, size.z);

    void addQuad(Vector3 a, Vector3 b, Vector3 c, Vector3 d) {
      faces.add(Face3D(vertices: [a, b, c], baseColor: color, isMetallic: isMetallic));
      faces.add(Face3D(vertices: [a, c, d], baseColor: color, isMetallic: isMetallic));
    }

    addQuad(p001, p101, p111, p011); // Front
    addQuad(p100, p000, p010, p110); // Back
    addQuad(p000, p100, p101, p001); // Top
    addQuad(p010, p011, p111, p110); // Bottom
    addQuad(p000, p001, p011, p010); // Left
    addQuad(p100, p110, p111, p101); // Right
  }

  void _buildSolidSphere(
    List<Face3D> faces,
    Vector3 center,
    double radius,
    int rings,
    int segments,
    Color color, {
    bool isMetallic = false,
  }) {
    for (int r = 0; r < rings; r++) {
      final phi1 = (r / rings) * math.pi;
      final phi2 = ((r + 1) / rings) * math.pi;

      final y1 = math.cos(phi1) * radius;
      final y2 = math.cos(phi2) * radius;
      final rRing1 = math.sin(phi1) * radius;
      final rRing2 = math.sin(phi2) * radius;

      for (int s = 0; s < segments; s++) {
        final a1 = (s / segments) * 2 * math.pi;
        final a2 = ((s + 1) / segments) * 2 * math.pi;

        final p1 = center + Vector3(math.cos(a1) * rRing1, y1, math.sin(a1) * rRing1);
        final p2 = center + Vector3(math.cos(a2) * rRing1, y1, math.sin(a2) * rRing1);
        final p3 = center + Vector3(math.cos(a2) * rRing2, y2, math.sin(a2) * rRing2);
        final p4 = center + Vector3(math.cos(a1) * rRing2, y2, math.sin(a1) * rRing2);

        if (r == 0) {
          faces.add(Face3D(vertices: [p1, p3, p4], baseColor: color, isMetallic: isMetallic));
        } else if (r == rings - 1) {
          faces.add(Face3D(vertices: [p1, p2, p3], baseColor: color, isMetallic: isMetallic));
        } else {
          faces.add(Face3D(vertices: [p1, p2, p3], baseColor: color, isMetallic: isMetallic));
          faces.add(Face3D(vertices: [p1, p3, p4], baseColor: color, isMetallic: isMetallic));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Resistor3DPainter oldDelegate) =>
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.zoom != zoom ||
      oldDelegate.type != type;
}

class _LatheSlice {
  final double x;
  final double radius;
  final Color color;
  final bool isMetallic;

  _LatheSlice(this.x, this.radius, this.color, {this.isMetallic = false});
}

class _Renderable {
  final double z;
  final Face3D? face;
  final Line3D? line;
  final List<Offset>? projectedPts;

  _Renderable({required this.z, this.face, this.line, this.projectedPts});
}

class _ViewportGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
      ..strokeWidth = 0.8;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final chPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    _drawCrosshair(canvas, const Offset(12, 12), chPaint);
    _drawCrosshair(canvas, Offset(size.width - 12, 12), chPaint);
    _drawCrosshair(canvas, Offset(12, size.height - 12), chPaint);
    _drawCrosshair(canvas, Offset(size.width - 12, size.height - 12), chPaint);
  }

  void _drawCrosshair(Canvas canvas, Offset p, Paint paint) {
    canvas.drawLine(p - const Offset(5, 0), p + const Offset(5, 0), paint);
    canvas.drawLine(p - const Offset(0, 5), p + const Offset(0, 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _getResistorName(Resistor3DType type) {
  switch (type) {
    case Resistor3DType.carbonComposition:
      return 'Carbon Composition Resistor';
    case Resistor3DType.carbonFilm:
      return 'Carbon Film Resistor';
    case Resistor3DType.metalFilm:
      return 'Metal Film Resistor';
    case Resistor3DType.wireWound:
      return 'Wire Wound Resistor';
    case Resistor3DType.potentiometer:
      return 'Potentiometer (Pot)';
    case Resistor3DType.rheostat:
      return 'Rheostat';
    case Resistor3DType.trimmer:
      return 'Preset / Trimmer (Trimpot)';
    case Resistor3DType.ldr:
      return 'LDR (Light Dependent Resistor)';
    case Resistor3DType.thermistor:
      return 'Thermistor (NTC/PTC)';
    case Resistor3DType.varistor:
      return 'Varistor (MOV)';
    case Resistor3DType.cementPower:
      return 'Cement Power Resistor';
    case Resistor3DType.smd:
      return 'SMD Resistor (0805/1206)';
  }
}

String _getResistorCallout(Resistor3DType type) {
  switch (type) {
    case Resistor3DType.carbonComposition:
      return 'Solid contoured ceramic body, tinned axial copper leads, and 4-band color coding.';
    case Resistor3DType.carbonFilm:
      return 'Precision pure carbon film with a visible helical laser-cut groove to calibrate resistance.';
    case Resistor3DType.metalFilm:
      return 'Vacuum-sputtered Nichrome alloy film on alumina core with tight ±1% 5-band tolerance.';
    case Resistor3DType.wireWound:
      return 'Heavy Nichrome wire coil wound on porcelain tube with vitreous protective enamel caps.';
    case Resistor3DType.potentiometer:
      return 'Stamped metal housing, threaded brass collar with hex locking nut, and 3 solder eyelets.';
    case Resistor3DType.rheostat:
      return 'Heavy-duty winding tube, top slider guide rod, adjustable carriage, and binding post terminals.';
    case Resistor3DType.trimmer:
      return 'Bourns 3296 style blue cermet case with brass cross-slot adjustment screw and 3 PCB pins.';
    case Resistor3DType.ldr:
      return 'High-density serpentine Cadmium Sulfide (CdS) photo-conductive track beneath optical window.';
    case Resistor3DType.thermistor:
      return 'Epoxy-dipped semiconductor ceramic bead with organic contours and dual kinked radial leads.';
    case Resistor3DType.varistor:
      return 'Zinc-oxide radial disc in high-voltage blue epoxy with silkscreen rating and radial leads.';
    case Resistor3DType.cementPower:
      return 'Flameproof white rectangular ceramic block with stamped wattage/tolerance and heavy leads.';
    case Resistor3DType.smd:
      return 'Surface-mount 0805 chip with silver/tin wrap-around solder pads and 3-digit numeric code.';
  }
}
