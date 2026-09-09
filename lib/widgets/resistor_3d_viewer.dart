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

/// A 3D Vector for geometry and transformations.
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

/// A 3D polygon face for rendering.
class Face3D {
  final List<Vector3> vertices;
  final Color baseColor;
  final bool isMetallic;
  final bool isShaded;
  final bool isWireframe;

  Face3D({
    required this.vertices,
    required this.baseColor,
    this.isMetallic = false,
    this.isShaded = true,
    this.isWireframe = false,
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

/// A 3D line segment (e.g. for leads, coils, or tracks).
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
///
/// Optimized for silky smooth 60fps performance on both Web and Mobile:
/// - Static high-fidelity perspective rendering by default in cards (0 CPU overhead).
/// - Instant real-time 3D rotation on mouse/touch drag.
/// - Full 360° CAD Inspector dialog with orbital rotation and zoom.
class Resistor3DViewer extends StatefulWidget {
  final Resistor3DType type;
  final double height;
  final bool enableGesture;
  final bool showInspectButton;
  final String? title;

  const Resistor3DViewer({
    super.key,
    required this.type,
    this.height = 165,
    this.enableGesture = true,
    this.showInspectButton = true,
    this.title,
  });

  @override
  State<Resistor3DViewer> createState() => _Resistor3DViewerState();
}

class _Resistor3DViewerState extends State<Resistor3DViewer> {
  double _yaw = 0.50;
  double _pitch = -0.28;

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
          color: const Color(0xFF070C18).withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: 1.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.02),
              const Color(0xFF00E5FF).withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle holographic viewport grid
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
                    _yaw = 0.50;
                    _pitch = -0.28;
                  });
                },
                child: CustomPaint(
                  painter: _Resistor3DPainter(
                    type: widget.type,
                    yaw: _yaw,
                    pitch: _pitch,
                    zoom: 1.05,
                  ),
                ),
              ),
            ),

            // Top-Left CAD Tag
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.20),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.view_in_ar_rounded, size: 12, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 5),
                    Text(
                      '3D CAD MODEL',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E5FF),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right Drag Hint
            Positioned(
              top: 10,
              right: 12,
              child: Text(
                'DRAG TO ROTATE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Bottom-Right Inspect / Fullscreen Button
            if (widget.showInspectButton)
              Positioned(
                bottom: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openInspectionDialog(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.20),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_full_rounded, size: 12, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 5),
                          Text(
                            'Inspect 3D',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
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
  double _yaw = 0.50;
  double _pitch = -0.28;
  double _zoom = 1.45;
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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 650),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          glowColor: const Color(0xFF00E5FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.view_in_ar_rounded,
                      color: Color(0xFF00E5FF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Full 360° Structural CAD Inspection',
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
              const SizedBox(height: 14),

              // 3D Viewport
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050914),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E293B),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Viewport grid
                      Positioned.fill(
                        child: CustomPaint(painter: _ViewportGridPainter()),
                      ),

                      // Gesture Detector
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

                      // Real-time CAD Coordinates HUD
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
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

                      // Auto-Rotate Button
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: InkWell(
                          onTap: () => setState(() => _autoRotate = !_autoRotate),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _autoRotate
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
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
                                  size: 13,
                                  color: _autoRotate
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _autoRotate ? 'Orbit: ON' : 'Orbit: OFF',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10.5,
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
                        max: 2.3,
                        onChanged: (v) => setState(() => _zoom = v),
                      ),
                    ),
                  ),
                  const Icon(Icons.zoom_in_rounded, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _yaw = 0.50;
                        _pitch = -0.28;
                        _zoom = 1.45;
                        _autoRotate = true;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: Text('Reset', style: GoogleFonts.spaceGrotesk(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCBD5E1),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Structural Callout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getResistorCallout(widget.type),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFCBD5E1),
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

/// Canvas painter for realistic 3D component rendering with Phong specular highlights.
class _Resistor3DPainter extends CustomPainter {
  final Resistor3DType type;
  final double yaw;
  final double pitch;
  final double zoom;

  static const double focalLength = 320.0;
  static final Vector3 lightDir = const Vector3(-0.4, -0.7, 0.6).normalized;

  _Resistor3DPainter({
    required this.type,
    required this.yaw,
    required this.pitch,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final faces = <Face3D>[];
    final lines = <Line3D>[];

    // Build the realistic 3D geometry
    _generateGeometry(faces, lines);

    // Transform vertices
    final transformedFaces = <Face3D>[];
    for (final face in faces) {
      final tVerts = face.vertices.map((v) {
        return v.rotateX(pitch).rotateY(yaw) * zoom;
      }).toList();

      transformedFaces.add(Face3D(
        vertices: tVerts,
        baseColor: face.baseColor,
        isMetallic: face.isMetallic,
        isShaded: face.isShaded,
        isWireframe: face.isWireframe,
      ));
    }

    final transformedLines = <Line3D>[];
    for (final line in lines) {
      final tStart = line.start.rotateX(pitch).rotateY(yaw) * zoom;
      final tEnd = line.end.rotateX(pitch).rotateY(yaw) * zoom;
      transformedLines.add(Line3D(
        start: tStart,
        end: tEnd,
        color: line.color,
        strokeWidth: line.strokeWidth * zoom,
      ));
    }

    // Combine for Painter's Algorithm sorting
    final renderables = <_Renderable>[];
    for (final face in transformedFaces) {
      renderables.add(_Renderable(z: face.avgZ, face: face));
    }
    for (final line in transformedLines) {
      renderables.add(_Renderable(z: line.avgZ, line: line));
    }

    // Sort back-to-front
    renderables.sort((a, b) => a.z.compareTo(b.z));

    // Render sorted elements
    for (final item in renderables) {
      if (item.line != null) {
        _renderLine(canvas, center, item.line!);
      } else if (item.face != null) {
        _renderFace(canvas, center, item.face!);
      }
    }
  }

  void _renderLine(Canvas canvas, Offset center, Line3D line) {
    final p1 = _project(center, line.start);
    final p2 = _project(center, line.end);

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, paint);
  }

  void _renderFace(Canvas canvas, Offset center, Face3D face) {
    if (face.vertices.length < 3) return;

    final v0 = face.vertices[0];
    final v1 = face.vertices[1];
    final v2 = face.vertices[2];

    final edge1 = v1 - v0;
    final edge2 = v2 - v0;
    final normal = edge1.cross(edge2).normalized;

    Color renderColor = face.baseColor;
    if (face.isShaded) {
      final diffuse = math.max(0.28, normal.dot(lightDir));
      final spec = face.isMetallic
          ? math.pow(math.max(0.0, normal.dot(lightDir)), 7) * 0.55
          : math.pow(math.max(0.0, normal.dot(lightDir)), 4) * 0.22;

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
    final firstP = _project(center, face.vertices[0]);
    path.moveTo(firstP.dx, firstP.dy);
    for (int i = 1; i < face.vertices.length; i++) {
      final p = _project(center, face.vertices[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    final paint = Paint()
      ..color = renderColor
      ..style = face.isWireframe ? PaintingStyle.stroke : PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Subtle edge highlight for 3D definition
    if (!face.isWireframe && face.vertices.length <= 4) {
      final borderPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawPath(path, borderPaint);
    }
  }

  Offset _project(Offset center, Vector3 v) {
    final scale = focalLength / (focalLength + v.z);
    return Offset(center.dx + v.x * scale, center.dy + v.y * scale);
  }

  // ===========================================================================
  // REALISTIC 3D COMPONENT GENERATORS
  // ===========================================================================

  void _generateGeometry(List<Face3D> faces, List<Line3D> lines) {
    switch (type) {
      case Resistor3DType.carbonComposition:
        _buildContouredAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFF332A24), // Dark phenolic charcoal
          bands: [
            const Color(0xFF9A5B2D), // Brown
            Colors.black,            // Black
            const Color(0xFFFF9800), // Orange
            const Color(0xFFFFD700), // Gold
          ],
        );
        break;

      case Resistor3DType.carbonFilm:
        _buildContouredAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFFD4B07B), // Warm beige ceramic
          hasHelicalGroove: true,
          bands: [
            const Color(0xFF9A5B2D), // Brown
            Colors.black,            // Black
            const Color(0xFFE53935), // Red
            const Color(0xFFFFD700), // Gold
          ],
        );
        break;

      case Resistor3DType.metalFilm:
        _buildContouredAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFF0284C7), // High precision sky-blue
          bands: [
            const Color(0xFF9A5B2D), // Brown
            Colors.black,            // Black
            Colors.black,            // Black
            const Color(0xFF9A5B2D), // Brown
            const Color(0xFF9A5B2D), // Brown (1%)
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

  /// 1. Realistic Contoured Axial Resistor (Dogbone flared shoulders, metallic leads, shine)
  void _buildContouredAxialResistor(
    List<Face3D> faces,
    List<Line3D> lines, {
    required Color bodyColor,
    required List<Color> bands,
    bool hasHelicalGroove = false,
  }) {
    const halfLen = 42.0;
    const segments = 16;

    // Metallic Axial Wire Leads (silver-tinned copper)
    lines.add(Line3D(
      start: const Vector3(-halfLen - 55, 0, 0),
      end: const Vector3(-halfLen, 0, 0),
      color: const Color(0xFFE2E8F0),
      strokeWidth: 4.0,
    ));
    lines.add(Line3D(
      start: const Vector3(halfLen, 0, 0),
      end: const Vector3(halfLen + 55, 0, 0),
      color: const Color(0xFFE2E8F0),
      strokeWidth: 4.0,
    ));

    // Metallic Solder Caps at entry
    _buildCylinder(faces, const Vector3(-halfLen - 5, 0, 0), 5, 6, segments,
        const Color(0xFFCBD5E1), isMetallic: true);
    _buildCylinder(faces, const Vector3(halfLen, 0, 0), 5, 6, segments,
        const Color(0xFFCBD5E1), isMetallic: true);

    // Left Flared Shoulder (Dogbone end)
    _buildTaperedCylinder(
      faces,
      const Vector3(-halfLen, 0, 0),
      12.0,
      radius1: 14.0,
      radius2: 19.5,
      segments: segments,
      color: bodyColor,
    );

    // Center Body Cylinder
    _buildCylinder(faces, const Vector3(-halfLen + 12, 0, 0), 60.0, 18.0,
        segments, bodyColor);

    // Right Flared Shoulder (Dogbone end)
    _buildTaperedCylinder(
      faces,
      const Vector3(halfLen - 12, 0, 0),
      12.0,
      radius1: 18.0,
      radius2: 14.0,
      segments: segments,
      color: bodyColor,
    );

    // Precision Color Bands
    final totalBandSpan = 52.0;
    final bandSpacing = totalBandSpan / (bands.length + 1);
    for (int i = 0; i < bands.length; i++) {
      final startX = -halfLen + 16.0 + i * bandSpacing;
      _buildCylinder(faces, Vector3(startX, 0, 0), 4.8, 18.6, segments,
          bands[i], isShaded: true);

      // Fine metallic border divider rings
      lines.add(Line3D(
        start: Vector3(startX, 18.6, 0),
        end: Vector3(startX, -18.6, 0),
        color: Colors.black.withValues(alpha: 0.3),
        strokeWidth: 1.0,
      ));
    }

    // Helical Spiral Cut for Carbon Film Resistor
    if (hasHelicalGroove) {
      for (double x = -halfLen + 16; x < halfLen - 16; x += 1.8) {
        final angle = (x * 0.45);
        final p = Vector3(x, math.cos(angle) * 19.0, math.sin(angle) * 19.0);
        lines.add(Line3D(
          start: p,
          end: p + const Vector3(1.4, 0.6, 0.6),
          color: const Color(0xFF451A03), // Spiral cut groove
          strokeWidth: 2.0,
        ));
      }
    }
  }

  /// 2. Wire Wound Resistor with visible metallic Nichrome coils
  void _buildWireWoundResistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 22.0;
    const length = 92.0;
    const segments = 16;

    // Heavy Tinned Axial Leads
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 50, 0, 0),
      end: const Vector3(-length / 2, 0, 0),
      color: const Color(0xFFF1F5F9),
      strokeWidth: 4.5,
    ));
    lines.add(Line3D(
      start: const Vector3(length / 2, 0, 0),
      end: const Vector3(length / 2 + 50, 0, 0),
      color: const Color(0xFFF1F5F9),
      strokeWidth: 4.5,
    ));

    // Ceramic Porcelain Core Cylinder
    _buildCylinder(faces, Vector3(-length / 2, 0, 0), length, radius, segments,
        const Color(0xFFF8FAFC));

    // Vitreous protective enamel coating collars (green)
    _buildCylinder(faces, Vector3(-length / 2, 0, 0), 14, radius + 1.5, segments,
        const Color(0xFF166534), isMetallic: true);
    _buildCylinder(faces, Vector3(length / 2 - 14, 0, 0), 14, radius + 1.5, segments,
        const Color(0xFF166534), isMetallic: true);

    // Realistic Coiled Wire Windings
    const coils = 18;
    for (int i = 0; i < coils; i++) {
      final x = -length / 2 + 16 + i * ((length - 32) / coils);
      for (int s = 0; s < segments; s++) {
        final a1 = (s / segments) * 2 * math.pi;
        final a2 = ((s + 1) / segments) * 2 * math.pi;
        lines.add(Line3D(
          start: Vector3(x, math.cos(a1) * (radius + 1.2), math.sin(a1) * (radius + 1.2)),
          end: Vector3(x + 1.4, math.cos(a2) * (radius + 1.2), math.sin(a2) * (radius + 1.2)),
          color: const Color(0xFFD97706), // Nichrome copper alloy
          strokeWidth: 2.4,
        ));
      }
    }
  }

  /// 3. Potentiometer (Stamped housing, threaded brass collar, hex nut, rotating shaft, 3 lugs)
  void _buildPotentiometer(List<Face3D> faces, List<Line3D> lines) {
    // Metal Round Body
    _buildCylinder(faces, const Vector3(0, -10, -16), 32, 32, 16,
        const Color(0xFF64748B), isMetallic: true);

    // Hexagonal Locking Nut (6-sided 3D prism)
    _buildCylinder(faces, const Vector3(0, -10, 16), 6, 20, 6,
        const Color(0xFFE2E8F0), isMetallic: true);

    // Threaded Brass Collar Bushing
    _buildCylinder(faces, const Vector3(0, -10, 22), 16, 13, 16,
        const Color(0xFFCA8A04), isMetallic: true);

    // Rotating Shaft with flat notch
    _buildCylinder(faces, const Vector3(0, -10, 38), 30, 8, 12,
        const Color(0xFFE2E8F0), isMetallic: true);

    // Shaft Flat notch line
    lines.add(Line3D(
      start: const Vector3(-5, -10, 68),
      end: const Vector3(5, -10, 68),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.0,
    ));

    // 3 Stamped Terminal Solder Lugs (Bottom) with Eyelets
    for (int i = -1; i <= 1; i++) {
      final x = i * 16.0;
      _buildBox(faces, Vector3(x - 3.5, 22, -14), const Vector3(7, 28, 3),
          const Color(0xFFCBD5E1), isMetallic: true);

      // Terminal Eyelet hole outline
      lines.add(Line3D(
        start: Vector3(x - 2, 44, -12),
        end: Vector3(x + 2, 44, -12),
        color: const Color(0xFF0F172A),
        strokeWidth: 2.5,
      ));
    }
  }

  /// 4. Rheostat (Industrial ceramic porcelain tube, windings, guide rail, wiper carriage)
  void _buildRheostat(List<Face3D> faces, List<Line3D> lines) {
    const length = 92.0;
    const radius = 20.0;

    // Ceramic Porcelain Coil Tube
    _buildCylinder(faces, Vector3(-length / 2, 6, 0), length, radius, 16,
        const Color(0xFFF1F5F9));

    // Wire winding coils
    for (double x = -length / 2 + 6; x < length / 2 - 6; x += 3.2) {
      for (int s = 0; s < 12; s++) {
        final a1 = (s / 12) * 2 * math.pi;
        final a2 = ((s + 1) / 12) * 2 * math.pi;
        lines.add(Line3D(
          start: Vector3(x, 6 + math.cos(a1) * (radius + 0.8), math.sin(a1) * (radius + 0.8)),
          end: Vector3(x, 6 + math.cos(a2) * (radius + 0.8), math.sin(a2) * (radius + 0.8)),
          color: const Color(0xFFB45309),
          strokeWidth: 1.8,
        ));
      }
    }

    // Top Chrome Slider Guide Rod
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 12, -22, 0),
      end: const Vector3(length / 2 + 12, -22, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 5.0,
    ));

    // Wiper Slider Carriage Block (Cyan / Blue)
    _buildBox(faces, const Vector3(-9, -29, -9), const Vector3(18, 14, 18),
        const Color(0xFF0284C7), isMetallic: true);

    // Brass Wiper Contact Finger
    _buildBox(faces, const Vector3(-5, -15, -4), const Vector3(10, 10, 8),
        const Color(0xFFCA8A04), isMetallic: true);

    // Heavy Brass Terminal Binding Posts
    _buildCylinder(faces, Vector3(-length / 2 - 6, 22, -6), 12, 6, 8,
        const Color(0xFFEAB308), isMetallic: true);
    _buildCylinder(faces, Vector3(length / 2 - 6, 22, -6), 12, 6, 8,
        const Color(0xFFEAB308), isMetallic: true);
  }

  /// 5. Preset Trimmer (Bourns 3296 sealed cermet trimmer)
  void _buildTrimmer(List<Face3D> faces, List<Line3D> lines) {
    // Ultramarine Blue Casing
    _buildBox(faces, const Vector3(-26, -26, -18), const Vector3(52, 50, 36),
        const Color(0xFF1D4ED8));

    // Top Brass Adjustment Screw Head
    _buildCylinder(faces, const Vector3(12, -33, 0), 7, 7, 12,
        const Color(0xFFEAB308), isMetallic: true);

    // Cross Screw Slot (+)
    lines.add(Line3D(
      start: const Vector3(8, -34, -4),
      end: const Vector3(16, -34, 4),
      color: const Color(0xFF713F12),
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(12, -34, -4),
      end: const Vector3(12, -34, 4),
      color: const Color(0xFF713F12),
      strokeWidth: 2.0,
    ));

    // 3 Gold-Plated PCB Solder Pins (Bottom)
    for (int i = -1; i <= 1; i++) {
      final x = i * 14.0;
      lines.add(Line3D(
        start: Vector3(x, 24, 0),
        end: Vector3(x, 48, 0),
        color: const Color(0xFFFBBF24),
        strokeWidth: 3.2,
      ));
    }
  }

  /// 6. LDR (Light Dependent Resistor)
  void _buildLDR(List<Face3D> faces, List<Line3D> lines) {
    const radius = 32.0;
    const segments = 20;

    // Ceramic Base Disc
    _buildCylinder(faces, const Vector3(0, 0, -4), 8, radius, segments,
        const Color(0xFFE2E8F0));

    // Gold Bezel Rim
    _buildCylinder(faces, const Vector3(0, 0, 4), 3, radius + 1, segments,
        const Color(0xFFCA8A04), isMetallic: true);

    // Clear Epoxy Optical Top Face
    final topCenter = const Vector3(0, 0, 7);
    for (int i = 0; i < segments; i++) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;
      faces.add(Face3D(
        vertices: [
          topCenter,
          Vector3(math.cos(a1) * radius, math.sin(a1) * radius, 7),
          Vector3(math.cos(a2) * radius, math.sin(a2) * radius, 7),
        ],
        baseColor: const Color(0xFFFEF08A),
      ));
    }

    // Serpentine Zigzag CdS Photoconductive Track Pattern
    final pts = <Vector3>[
      const Vector3(-20, -18, 7.5),
      const Vector3(20, -18, 7.5),
      const Vector3(20, -9, 7.5),
      const Vector3(-20, -9, 7.5),
      const Vector3(-20, 0, 7.5),
      const Vector3(20, 0, 7.5),
      const Vector3(20, 9, 7.5),
      const Vector3(-20, 9, 7.5),
      const Vector3(-20, 18, 7.5),
      const Vector3(20, 18, 7.5),
    ];
    for (int i = 0; i < pts.length - 1; i++) {
      lines.add(Line3D(
        start: pts[i],
        end: pts[i + 1],
        color: const Color(0xFFDC2626), // Cadmium Sulfide track
        strokeWidth: 2.8,
      ));
    }

    // 2 Rear Leads
    lines.add(Line3D(
      start: const Vector3(-12, 0, -4),
      end: const Vector3(-12, 0, -52),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.2,
    ));
    lines.add(Line3D(
      start: const Vector3(12, 0, -4),
      end: const Vector3(12, 0, -52),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.2,
    ));
  }

  /// 7. Thermistor (Glossy organic teardrop bead with dual leads)
  void _buildThermistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 22.0;
    const segments = 14;

    for (int ring = 0; ring < 7; ring++) {
      final r1 = radius * math.sin((ring / 7) * math.pi);
      final r2 = radius * math.sin(((ring + 1) / 7) * math.pi);
      final z1 = radius * math.cos((ring / 7) * math.pi);
      final z2 = radius * math.cos(((ring + 1) / 7) * math.pi);

      for (int i = 0; i < segments; i++) {
        final a1 = (i / segments) * 2 * math.pi;
        final a2 = ((i + 1) / segments) * 2 * math.pi;

        faces.add(Face3D(
          vertices: [
            Vector3(math.cos(a1) * r1, math.sin(a1) * r1, z1),
            Vector3(math.cos(a2) * r1, math.sin(a2) * r1, z1),
            Vector3(math.cos(a2) * r2, math.sin(a2) * r2, z2),
            Vector3(math.cos(a1) * r2, math.sin(a1) * r2, z2),
          ],
          baseColor: const Color(0xFF0D9488), // Glossy Dark Emerald
          isMetallic: true,
        ));
      }
    }

    // Kinked Wire Leads
    lines.add(Line3D(
      start: const Vector3(-7, radius - 2, 0),
      end: const Vector3(-10, radius + 46, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.2,
    ));
    lines.add(Line3D(
      start: const Vector3(7, radius - 2, 0),
      end: const Vector3(10, radius + 46, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.2,
    ));
  }

  /// 8. Varistor (MOV Radial Disc with Silkscreen markings)
  void _buildVaristor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 34.0;
    const segments = 20;

    // Disc Body (Classic High-Voltage Blue MOV)
    _buildCylinder(faces, const Vector3(0, -6, -4), 8, radius, segments,
        const Color(0xFF1D4ED8));

    // 2 Radial Leads with strain-relief crimp
    lines.add(Line3D(
      start: const Vector3(-12, radius - 6, 0),
      end: const Vector3(-14, radius + 44, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));
    lines.add(Line3D(
      start: const Vector3(12, radius - 6, 0),
      end: const Vector3(14, radius + 44, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));

    // Stamped markings silkscreen
    lines.add(Line3D(
      start: const Vector3(-16, -12, 5),
      end: const Vector3(16, -12, 5),
      color: const Color(0xFF93C5FD),
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(-11, -4, 5),
      end: const Vector3(11, -4, 5),
      color: const Color(0xFF93C5FD),
      strokeWidth: 2.0,
    ));
  }

  /// 9. Cement Power Resistor (Ceramic Block)
  void _buildCementResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 86.0;
    const width = 28.0;
    const height = 28.0;

    // White Ceramic Prism Brick
    _buildBox(
      faces,
      Vector3(-length / 2, -height / 2, -width / 2),
      const Vector3(length, height, width),
      const Color(0xFFF8FAFC),
    );

    // Stamped wattage markings lines
    lines.add(Line3D(
      start: const Vector3(-25, -4, width / 2 + 0.6),
      end: const Vector3(25, -4, width / 2 + 0.6),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(-18, 5, width / 2 + 0.6),
      end: const Vector3(18, 5, width / 2 + 0.6),
      color: const Color(0xFF0F172A),
      strokeWidth: 2.2,
    ));

    // Heavy Tinned Leads
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 46, 0, 0),
      end: const Vector3(-length / 2, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 4.5,
    ));
    lines.add(Line3D(
      start: const Vector3(length / 2, 0, 0),
      end: const Vector3(length / 2 + 46, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 4.5,
    ));
  }

  /// 10. SMD Resistor (0805 Surface Mount Chip)
  void _buildSMDResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 70.0;
    const height = 13.0;
    const width = 36.0;
    const capWidth = 13.0;

    // Black Ceramic Body (Center)
    _buildBox(
      faces,
      Vector3(-length / 2 + capWidth, -height / 2, -width / 2),
      const Vector3(length - capWidth * 2, height, width),
      const Color(0xFF0F172A),
    );

    // Silver Wrap-Around Solder Terminations (Left & Right)
    _buildBox(
      faces,
      Vector3(-length / 2, -height / 2, -width / 2),
      const Vector3(capWidth, height, width),
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );
    _buildBox(
      faces,
      Vector3(length / 2 - capWidth, -height / 2, -width / 2),
      const Vector3(capWidth, height, width),
      const Color(0xFFE2E8F0),
      isMetallic: true,
    );

    // Stamped "103" SMD Code
    lines.add(Line3D(
      start: const Vector3(-10, -height / 2 - 0.6, -7),
      end: const Vector3(-10, -height / 2 - 0.6, 7),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(0, -height / 2 - 0.6, -7),
      end: const Vector3(0, -height / 2 - 0.6, 7),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
    lines.add(Line3D(
      start: const Vector3(10, -height / 2 - 0.6, -7),
      end: const Vector3(10, -height / 2 - 0.6, 7),
      color: Colors.white,
      strokeWidth: 2.2,
    ));
  }

  // ===========================================================================
  // 3D PRIMITIVE HELPERS
  // ===========================================================================

  void _buildCylinder(
    List<Face3D> faces,
    Vector3 origin,
    double length,
    double radius,
    int segments,
    Color color, {
    bool isMetallic = false,
    bool isShaded = true,
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

      faces.add(Face3D(
        vertices: [p1, p2, p3, p4],
        baseColor: color,
        isMetallic: isMetallic,
        isShaded: isShaded,
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
        isShaded: isShaded,
      ));
      faces.add(Face3D(
        vertices: [rightCenter, rightCap[i], rightCap[next]],
        baseColor: color,
        isMetallic: isMetallic,
        isShaded: isShaded,
      ));
    }
  }

  void _buildTaperedCylinder(
    List<Face3D> faces,
    Vector3 origin,
    double length, {
    required double radius1,
    required double radius2,
    required int segments,
    required Color color,
    bool isMetallic = false,
  }) {
    for (int i = 0; i < segments; i++) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;

      final y1a = math.cos(a1) * radius1;
      final z1a = math.sin(a1) * radius1;
      final y2a = math.cos(a2) * radius1;
      final z2a = math.sin(a2) * radius1;

      final y1b = math.cos(a1) * radius2;
      final z1b = math.sin(a1) * radius2;
      final y2b = math.cos(a2) * radius2;
      final z2b = math.sin(a2) * radius2;

      final p1 = origin + Vector3(0, y1a, z1a);
      final p2 = origin + Vector3(0, y2a, z2a);
      final p3 = origin + Vector3(length, y2b, z2b);
      final p4 = origin + Vector3(length, y1b, z1b);

      faces.add(Face3D(
        vertices: [p1, p2, p3, p4],
        baseColor: color,
        isMetallic: isMetallic,
        isShaded: true,
      ));
    }
  }

  void _buildBox(
    List<Face3D> faces,
    Vector3 origin,
    Vector3 size,
    Color color, {
    bool isMetallic = false,
  }) {
    final v000 = origin;
    final v100 = origin + Vector3(size.x, 0, 0);
    final v110 = origin + Vector3(size.x, size.y, 0);
    final v010 = origin + Vector3(0, size.y, 0);
    final v001 = origin + Vector3(0, 0, size.z);
    final v101 = origin + Vector3(size.x, 0, size.z);
    final v111 = origin + size;
    final v011 = origin + Vector3(0, size.y, size.z);

    faces.add(Face3D(vertices: [v001, v101, v111, v011], baseColor: color, isMetallic: isMetallic));
    faces.add(Face3D(vertices: [v100, v000, v010, v110], baseColor: color, isMetallic: isMetallic));
    faces.add(Face3D(vertices: [v000, v100, v101, v001], baseColor: color, isMetallic: isMetallic));
    faces.add(Face3D(vertices: [v010, v011, v111, v110], baseColor: color, isMetallic: isMetallic));
    faces.add(Face3D(vertices: [v000, v001, v011, v010], baseColor: color, isMetallic: isMetallic));
    faces.add(Face3D(vertices: [v100, v110, v111, v101], baseColor: color, isMetallic: isMetallic));
  }

  @override
  bool shouldRepaint(covariant _Resistor3DPainter oldDelegate) =>
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.zoom != zoom ||
      oldDelegate.type != type;
}

class _Renderable {
  final double z;
  final Face3D? face;
  final Line3D? line;

  _Renderable({required this.z, this.face, this.line});
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
      return 'Contoured flared ceramic body, tinned axial copper leads, and 4-band color coding.';
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
