import 'dart:math' as math;
import 'package:flutter/material.dart';
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

/// A 3D line segment (e.g. for leads or coils).
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
  final bool autoRotate;
  final bool showInspectButton;
  final String? title;

  const Resistor3DViewer({
    super.key,
    required this.type,
    this.height = 160,
    this.enableGesture = true,
    this.autoRotate = true,
    this.showInspectButton = true,
    this.title,
  });

  @override
  State<Resistor3DViewer> createState() => _Resistor3DViewerState();
}

class _Resistor3DViewerState extends State<Resistor3DViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _yaw = 0.45;
  double _pitch = -0.30;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        if (widget.autoRotate && !_isInteracting) {
          setState(() {
            _yaw += 0.008;
            if (_yaw > math.pi * 2) _yaw -= math.pi * 2;
          });
        }
      });

    if (widget.autoRotate) {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openInspectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => _Resistor3DInspectorDialog(
        type: widget.type,
        title: widget.title ?? _getResistorName(widget.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Subtle holographic viewport grid
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewportGridPainter(),
            ),
          ),

          // Interactive 3D Model Viewport
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (_) {
                if (widget.enableGesture) setState(() => _isInteracting = true);
              },
              onPanUpdate: (details) {
                if (widget.enableGesture) {
                  setState(() {
                    _yaw += details.delta.dx * 0.015;
                    _pitch = (_pitch - details.delta.dy * 0.015)
                        .clamp(-math.pi / 2.2, math.pi / 2.2);
                  });
                }
              },
              onPanEnd: (_) {
                if (widget.enableGesture) setState(() => _isInteracting = false);
              },
              onDoubleTap: () {
                setState(() {
                  _yaw = 0.45;
                  _pitch = -0.30;
                });
              },
              child: CustomPaint(
                painter: _Resistor3DPainter(
                  type: widget.type,
                  yaw: _yaw,
                  pitch: _pitch,
                  zoom: 1.0,
                ),
              ),
            ),
          ),

          // Top-Left CAD Tag
          Positioned(
            top: 8,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.30),
                  width: 0.8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_in_ar_rounded, size: 12, color: Color(0xFF00E5FF)),
                  SizedBox(width: 4),
                  Text(
                    '3D CAD MODEL',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E5FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_full_rounded, size: 12, color: Color(0xFFCBD5E1)),
                        SizedBox(width: 4),
                        Text(
                          'Inspect 3D',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCBD5E1),
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
    );
  }
}

/// Full screen interactive 3D model inspection dialog.
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

class _Resistor3DInspectorDialogState extends State<_Resistor3DInspectorDialog> {
  double _yaw = 0.5;
  double _pitch = -0.3;
  double _zoom = 1.35;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Interactive 360° Structural Inspection',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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

                      // HUD Overlay
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            'YAW: ${(_yaw * 180 / math.pi % 360).round()}° | PITCH: ${(_pitch * 180 / math.pi).round()}°',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10,
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Controls & Zoom Slider
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
                        max: 2.2,
                        onChanged: (v) => setState(() => _zoom = v),
                      ),
                    ),
                  ),
                  const Icon(Icons.zoom_in_rounded, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _yaw = 0.5;
                        _pitch = -0.3;
                        _zoom = 1.35;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCBD5E1),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Technical Callout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getResistorCallout(widget.type),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCBD5E1),
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

/// Canvas painter for the 3D resistor model.
class _Resistor3DPainter extends CustomPainter {
  final Resistor3DType type;
  final double yaw;
  final double pitch;
  final double zoom;

  // Camera focal length for perspective projection
  static const double focalLength = 320.0;

  // Directional Light Vector (normalized, pointing towards scene)
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

    // Build the 3D geometry based on the component type
    _generateGeometry(faces, lines);

    // Transform vertices: Rotate pitch, then yaw, then scale
    final transformedFaces = <Face3D>[];
    for (final face in faces) {
      final tVerts = face.vertices.map((v) {
        final rot = v.rotateX(pitch).rotateY(yaw) * zoom;
        return rot;
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

    // Combine renderable objects for Painter's Algorithm sorting
    final renderables = <_Renderable>[];
    for (final face in transformedFaces) {
      renderables.add(_Renderable(z: face.avgZ, face: face));
    }
    for (final line in transformedLines) {
      renderables.add(_Renderable(z: line.avgZ, line: line));
    }

    // Sort back-to-front (smaller Z is farther away, larger Z is closer to camera)
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

    // Normal calculation for lighting
    final v0 = face.vertices[0];
    final v1 = face.vertices[1];
    final v2 = face.vertices[2];

    final edge1 = v1 - v0;
    final edge2 = v2 - v0;
    final normal = edge1.cross(edge2).normalized;

    // Back-face culling for solid meshes
    // If normal points away from viewer (normal.z <= 0) and not wireframe, we can still render or cull.
    // For transparent/open meshes, we allow both sides.

    Color renderColor = face.baseColor;
    if (face.isShaded) {
      final diffuse = math.max(0.25, normal.dot(lightDir));
      final spec = face.isMetallic
          ? math.pow(math.max(0.0, normal.dot(lightDir)), 6) * 0.45
          : 0.0;

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
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawPath(path, borderPaint);
    }
  }

  Offset _project(Offset center, Vector3 v) {
    // Standard perspective projection formula
    final scale = focalLength / (focalLength + v.z);
    return Offset(center.dx + v.x * scale, center.dy + v.y * scale);
  }

  /// Builds true 3D meshes for each of the 12 resistor kinds.
  void _generateGeometry(List<Face3D> faces, List<Line3D> lines) {
    switch (type) {
      case Resistor3DType.carbonComposition:
        _buildAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFF2C241E), // Dark phenolic charcoal
          bands: [
            const Color(0xFF8B5A2B), // Brown
            Colors.black,            // Black
            const Color(0xFFFFA500), // Orange
            const Color(0xFFFFD700), // Gold
          ],
        );
        break;

      case Resistor3DType.carbonFilm:
        _buildAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFFD6B27C), // Tan / Beige ceramic
          hasHelicalGroove: true,
          bands: [
            const Color(0xFF8B5A2B), // Brown
            Colors.black,            // Black
            const Color(0xFFE53935), // Red
            const Color(0xFFFFD700), // Gold
          ],
        );
        break;

      case Resistor3DType.metalFilm:
        _buildAxialResistor(
          faces,
          lines,
          bodyColor: const Color(0xFF0284C7), // High precision sky-blue
          bands: [
            const Color(0xFF8B5A2B), // Brown
            Colors.black,            // Black
            Colors.black,            // Black
            const Color(0xFF8B5A2B), // Brown
            const Color(0xFF8B5A2B), // Brown (1%)
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

  // ===========================================================================
  // 3D GEOMETRY GENERATORS
  // ===========================================================================

  /// 1. Axial Resistor (Carbon Comp, Carbon Film, Metal Film)
  void _buildAxialResistor(
    List<Face3D> faces,
    List<Line3D> lines, {
    required Color bodyColor,
    required List<Color> bands,
    bool hasHelicalGroove = false,
  }) {
    const radius = 18.0;
    const halfLen = 42.0;
    const segments = 16;

    // Metallic Leads extending out both ends
    lines.add(Line3D(
      start: const Vector3(-halfLen - 50, 0, 0),
      end: const Vector3(-halfLen, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));
    lines.add(Line3D(
      start: const Vector3(halfLen, 0, 0),
      end: const Vector3(halfLen + 50, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));

    // End caps (silver metallic caps)
    _buildCylinder(faces, const Vector3(-halfLen - 4, 0, 0), 4, radius + 1, segments,
        const Color(0xFF94A3B8), isMetallic: true);
    _buildCylinder(faces, const Vector3(halfLen, 0, 0), 4, radius + 1, segments,
        const Color(0xFF94A3B8), isMetallic: true);

    // Main Body Cylinder
    _buildCylinder(faces, const Vector3(-halfLen, 0, 0), halfLen * 2, radius,
        segments, bodyColor);

    // Color Bands
    final bandWidth = halfLen * 2 / (bands.length + 3);
    for (int i = 0; i < bands.length; i++) {
      final startX = -halfLen + 8.0 + i * (bandWidth + 5.0);
      _buildCylinder(faces, Vector3(startX, 0, 0), 4.5, radius + 0.5, segments,
          bands[i], isShaded: true);
    }

    // Helical groove for Carbon Film
    if (hasHelicalGroove) {
      for (double x = -halfLen + 10; x < halfLen - 10; x += 1.5) {
        final angle = (x * 0.4);
        final p = Vector3(x, math.cos(angle) * (radius + 0.8),
            math.sin(angle) * (radius + 0.8));
        lines.add(Line3D(
          start: p,
          end: p + const Vector3(1.2, 0.5, 0.5),
          color: const Color(0xFF451A03),
          strokeWidth: 1.5,
        ));
      }
    }
  }

  /// 2. Wire Wound Resistor with visible 3D coils
  void _buildWireWoundResistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 22.0;
    const length = 90.0;
    const segments = 16;

    // Heavy Leads
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 45, 0, 0),
      end: const Vector3(-length / 2, 0, 0),
      color: const Color(0xFFE2E8F0),
      strokeWidth: 4.5,
    ));
    lines.add(Line3D(
      start: const Vector3(length / 2, 0, 0),
      end: const Vector3(length / 2 + 45, 0, 0),
      color: const Color(0xFFE2E8F0),
      strokeWidth: 4.5,
    ));

    // Ceramic Core Cylinder
    _buildCylinder(faces, Vector3(-length / 2, 0, 0), length, radius, segments,
        const Color(0xFFF1F5F9));

    // Protective vitreous enamel ends
    _buildCylinder(faces, Vector3(-length / 2, 0, 0), 12, radius + 1.5, segments,
        const Color(0xFF15803D));
    _buildCylinder(faces, Vector3(length / 2 - 12, 0, 0), 12, radius + 1.5, segments,
        const Color(0xFF15803D));

    // Coiled Wire Windings around the core
    const coils = 16;
    for (int i = 0; i < coils; i++) {
      final x = -length / 2 + 14 + i * ((length - 28) / coils);
      for (int s = 0; s < segments; s++) {
        final a1 = (s / segments) * 2 * math.pi;
        final a2 = ((s + 1) / segments) * 2 * math.pi;
        lines.add(Line3D(
          start: Vector3(x, math.cos(a1) * (radius + 1.2), math.sin(a1) * (radius + 1.2)),
          end: Vector3(x + 1.2, math.cos(a2) * (radius + 1.2), math.sin(a2) * (radius + 1.2)),
          color: const Color(0xFFD97706), // Nichrome copper alloy
          strokeWidth: 2.2,
        ));
      }
    }
  }

  /// 3. Potentiometer (Rotary Pot)
  void _buildPotentiometer(List<Face3D> faces, List<Line3D> lines) {
    // Metal Round Body
    _buildCylinder(faces, const Vector3(0, -10, -15), 30, 32, 16,
        const Color(0xFF64748B), isMetallic: true);

    // Threaded Bushing Collar
    _buildCylinder(faces, const Vector3(0, -10, 15), 18, 14, 16,
        const Color(0xFF94A3B8), isMetallic: true);

    // Rotating Shaft
    _buildCylinder(faces, const Vector3(0, -10, 33), 32, 8, 12,
        const Color(0xFFE2E8F0), isMetallic: true);

    // 3 Terminal Solder Lugs (Bottom)
    for (int i = -1; i <= 1; i++) {
      final x = i * 16.0;
      _buildBox(faces, Vector3(x - 3, 22, -15), const Vector3(6, 26, 3),
          const Color(0xFFCBD5E1), isMetallic: true);

      // Terminal Eyelet hole outline
      lines.add(Line3D(
        start: Vector3(x - 2, 42, -14),
        end: Vector3(x + 2, 42, -14),
        color: const Color(0xFF0F172A),
        strokeWidth: 2.0,
      ));
    }
  }

  /// 4. Rheostat (High-Power Variable Wirewound)
  void _buildRheostat(List<Face3D> faces, List<Line3D> lines) {
    const length = 90.0;
    const radius = 20.0;

    // Ceramic Coil Tube
    _buildCylinder(faces, Vector3(-length / 2, 5, 0), length, radius, 16,
        const Color(0xFFE2E8F0));

    // Wire windings
    for (double x = -length / 2 + 5; x < length / 2 - 5; x += 3.5) {
      for (int s = 0; s < 12; s++) {
        final a1 = (s / 12) * 2 * math.pi;
        final a2 = ((s + 1) / 12) * 2 * math.pi;
        lines.add(Line3D(
          start: Vector3(x, 5 + math.cos(a1) * (radius + 0.8), math.sin(a1) * (radius + 0.8)),
          end: Vector3(x, 5 + math.cos(a2) * (radius + 0.8), math.sin(a2) * (radius + 0.8)),
          color: const Color(0xFFB45309),
          strokeWidth: 1.8,
        ));
      }
    }

    // Top Slide Metal Bar
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 10, -22, 0),
      end: const Vector3(length / 2 + 10, -22, 0),
      color: const Color(0xFF94A3B8),
      strokeWidth: 4.5,
    ));

    // Wiper Contact Block & Slider Knob (centered)
    _buildBox(faces, const Vector3(-8, -28, -8), const Vector3(16, 12, 16),
        const Color(0xFF0284C7), isMetallic: true);
    _buildBox(faces, const Vector3(-5, -16, -4), const Vector3(10, 10, 8),
        const Color(0xFFD97706), isMetallic: true);

    // End Terminal Posts
    _buildBox(faces, Vector3(-length / 2 - 8, 20, -5), const Vector3(8, 14, 10),
        const Color(0xFF64748B), isMetallic: true);
    _buildBox(faces, Vector3(length / 2, 20, -5), const Vector3(8, 14, 10),
        const Color(0xFF64748B), isMetallic: true);
  }

  /// 5. Preset Trimmer (Trimpot)
  void _buildTrimmer(List<Face3D> faces, List<Line3D> lines) {
    // Blue Box Body (Classic Bourns 3296)
    _buildBox(faces, const Vector3(-25, -25, -18), const Vector3(50, 48, 36),
        const Color(0xFF1D4ED8));

    // Top Brass Adjustment Screw
    _buildCylinder(faces, const Vector3(10, -32, 0), 7, 7, 12,
        const Color(0xFFEAB308), isMetallic: true);

    // Screw Slot
    lines.add(Line3D(
      start: const Vector3(6, -33, -5),
      end: const Vector3(14, -33, 5),
      color: const Color(0xFF713F12),
      strokeWidth: 2.0,
    ));

    // Dial Arrow / Markings
    lines.add(Line3D(
      start: const Vector3(-12, -26, -6),
      end: const Vector3(-4, -26, 0),
      color: Colors.white,
      strokeWidth: 1.5,
    ));

    // 3 PCB Pins (Bottom)
    for (int i = -1; i <= 1; i++) {
      final x = i * 14.0;
      lines.add(Line3D(
        start: Vector3(x, 23, 0),
        end: Vector3(x, 46, 0),
        color: const Color(0xFFE2E8F0),
        strokeWidth: 3.0,
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

    // Metal Bezel Ring
    _buildCylinder(faces, const Vector3(0, 0, 4), 3, radius + 1, segments,
        const Color(0xFF64748B), isMetallic: true);

    // Clear Epoxy Top Face
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
        baseColor: const Color(0xFFFDE68A),
      ));
    }

    // Serpentine Zigzag CdS Photoconductive Track
    final pts = <Vector3>[
      const Vector3(-20, -16, 7.5),
      const Vector3(20, -16, 7.5),
      const Vector3(20, -8, 7.5),
      const Vector3(-20, -8, 7.5),
      const Vector3(-20, 0, 7.5),
      const Vector3(20, 0, 7.5),
      const Vector3(20, 8, 7.5),
      const Vector3(-20, 8, 7.5),
      const Vector3(-20, 16, 7.5),
      const Vector3(20, 16, 7.5),
    ];
    for (int i = 0; i < pts.length - 1; i++) {
      lines.add(Line3D(
        start: pts[i],
        end: pts[i + 1],
        color: const Color(0xFFDC2626), // Cadmium Sulfide track
        strokeWidth: 2.5,
      ));
    }

    // 2 Rear Leads
    lines.add(Line3D(
      start: const Vector3(-12, 0, -4),
      end: const Vector3(-12, 0, -50),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.0,
    ));
    lines.add(Line3D(
      start: const Vector3(12, 0, -4),
      end: const Vector3(12, 0, -50),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.0,
    ));
  }

  /// 7. Thermistor (NTC/PTC Dipped Bead)
  void _buildThermistor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 22.0;
    const segments = 14;

    // Teardrop / spherical dipped bead body
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
          baseColor: const Color(0xFF0F766E), // Glossy Dark Teal epoxy
          isMetallic: true,
        ));
      }
    }

    // Two downward wire leads
    lines.add(Line3D(
      start: const Vector3(-7, radius - 2, 0),
      end: const Vector3(-10, radius + 45, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.0,
    ));
    lines.add(Line3D(
      start: const Vector3(7, radius - 2, 0),
      end: const Vector3(10, radius + 45, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.0,
    ));
  }

  /// 8. Varistor (MOV Radial Disc)
  void _buildVaristor(List<Face3D> faces, List<Line3D> lines) {
    const radius = 34.0;
    const segments = 20;

    // Disc Body (Classic Blue MOV)
    _buildCylinder(faces, const Vector3(0, -6, -4), 8, radius, segments,
        const Color(0xFF1E40AF));

    // 2 Radial Leads extending out bottom
    lines.add(Line3D(
      start: const Vector3(-12, radius - 6, 0),
      end: const Vector3(-14, radius + 42, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));
    lines.add(Line3D(
      start: const Vector3(12, radius - 6, 0),
      end: const Vector3(14, radius + 42, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 3.5,
    ));

    // Stamped component markings on front face
    lines.add(Line3D(
      start: const Vector3(-15, -12, 5),
      end: const Vector3(15, -12, 5),
      color: const Color(0xFF93C5FD),
      strokeWidth: 1.5,
    ));
    lines.add(Line3D(
      start: const Vector3(-10, -4, 5),
      end: const Vector3(10, -4, 5),
      color: const Color(0xFF93C5FD),
      strokeWidth: 1.5,
    ));
  }

  /// 9. Cement Power Resistor (Ceramic Block)
  void _buildCementResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 85.0;
    const width = 28.0;
    const height = 28.0;

    // White Ceramic Prism
    _buildBox(
      faces,
      Vector3(-length / 2, -height / 2, -width / 2),
      const Vector3(length, height, width),
      const Color(0xFFF8FAFC),
    );

    // Stamped Wattage / Resistance Silkscreen Text Lines
    lines.add(Line3D(
      start: const Vector3(-24, -3, width / 2 + 0.5),
      end: const Vector3(24, -3, width / 2 + 0.5),
      color: const Color(0xFF1E293B),
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(-18, 5, width / 2 + 0.5),
      end: const Vector3(18, 5, width / 2 + 0.5),
      color: const Color(0xFF1E293B),
      strokeWidth: 2.0,
    ));

    // Heavy Metal Leads
    lines.add(Line3D(
      start: const Vector3(-length / 2 - 45, 0, 0),
      end: const Vector3(-length / 2, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 4.5,
    ));
    lines.add(Line3D(
      start: const Vector3(length / 2, 0, 0),
      end: const Vector3(length / 2 + 45, 0, 0),
      color: const Color(0xFFCBD5E1),
      strokeWidth: 4.5,
    ));
  }

  /// 10. SMD Resistor (0805 / 1206 Surface Mount Chip)
  void _buildSMDResistor(List<Face3D> faces, List<Line3D> lines) {
    const length = 68.0;
    const height = 12.0;
    const width = 36.0;
    const capWidth = 12.0;

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

    // Stamped "103" (10 kΩ) 3-digit SMD code lines on top
    lines.add(Line3D(
      start: const Vector3(-10, -height / 2 - 0.5, -6),
      end: const Vector3(-10, -height / 2 - 0.5, 6),
      color: Colors.white,
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(0, -height / 2 - 0.5, -6),
      end: const Vector3(0, -height / 2 - 0.5, 6),
      color: Colors.white,
      strokeWidth: 2.0,
    ));
    lines.add(Line3D(
      start: const Vector3(10, -height / 2 - 0.5, -6),
      end: const Vector3(10, -height / 2 - 0.5, 6),
      color: Colors.white,
      strokeWidth: 2.0,
    ));
  }

  // ===========================================================================
  // 3D PRIMITIVE HELPERS
  // ===========================================================================

  /// Builds a 3D polygonal cylinder along the X-axis (or specified direction).
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

    // Caps
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

  /// Builds a 3D box (prism) at origin with given dimensions.
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

    // Front
    faces.add(Face3D(
        vertices: [v001, v101, v111, v011], baseColor: color, isMetallic: isMetallic));
    // Back
    faces.add(Face3D(
        vertices: [v100, v000, v010, v110], baseColor: color, isMetallic: isMetallic));
    // Top
    faces.add(Face3D(
        vertices: [v000, v100, v101, v001], baseColor: color, isMetallic: isMetallic));
    // Bottom
    faces.add(Face3D(
        vertices: [v010, v011, v111, v110], baseColor: color, isMetallic: isMetallic));
    // Left
    faces.add(Face3D(
        vertices: [v000, v001, v011, v010], baseColor: color, isMetallic: isMetallic));
    // Right
    faces.add(Face3D(
        vertices: [v100, v110, v111, v101], baseColor: color, isMetallic: isMetallic));
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

/// Custom painter for the futuristic holographic 3D viewport grid.
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

    // Corner crosshairs
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
      return 'Drag with your finger to rotate in 360°. Observe phenolic solid core, metal end-caps, and axial lead wires.';
    case Resistor3DType.carbonFilm:
      return 'Notice the helical spiral groove cut into the pure carbon film to precisely set resistance value.';
    case Resistor3DType.metalFilm:
      return 'Precision laser-trimmed Nichrome film on alumina ceramic rod, featuring tight 5-band color tolerances.';
    case Resistor3DType.wireWound:
      return 'High-power Nichrome wire tightly wound around an insulated ceramic core with protective enamel coating.';
    case Resistor3DType.potentiometer:
      return 'Features a rotating central control shaft, threaded mounting collar, and 3 terminal solder lugs.';
    case Resistor3DType.rheostat:
      return 'High-current variable resistor with heavy wound coil, metal guide rail, and adjustable slider wiper.';
    case Resistor3DType.trimmer:
      return 'PCB trimpot with top brass adjustment screw and 3 through-hole terminal solder pins.';
    case Resistor3DType.ldr:
      return 'Cadmium Sulfide (CdS) photoconductive serpentine track visible beneath clear epoxy sealing lens.';
    case Resistor3DType.thermistor:
      return 'Semiconductor ceramic bead dipped in protective epoxy with negative/positive temperature response.';
    case Resistor3DType.varistor:
      return 'Zinc-oxide radial disc designed for transient voltage surge clamping and lightning protection.';
    case Resistor3DType.cementPower:
      return 'Heavy-duty ceramic block filled with non-flammable cement around a wirewound core.';
    case Resistor3DType.smd:
      return 'Surface-mount chip resistor featuring silver end termination solder pads and numeric code silkscreen.';
  }
}
