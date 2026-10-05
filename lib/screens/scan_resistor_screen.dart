import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/resistor_scanner_service.dart';
import '../services/scanner/scanner_coordinator.dart';
import '../widgets/glass_components.dart';
import '../widgets/interactive_band_overlay.dart';

/// Screen for scanning resistors via camera or gallery image.
class ScanResistorScreen extends StatefulWidget {
  final Uint8List? initialImageBytesForTesting;

  const ScanResistorScreen({
    super.key,
    this.initialImageBytesForTesting,
  });

  @override
  State<ScanResistorScreen> createState() => _ScanResistorScreenState();
}

class _ScanResistorScreenState extends State<ScanResistorScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  // Interactive Image Positioning state
  bool _isAdjustingImage = false;
  Uint8List? _selectedImageBytes;
  final TransformationController _transformationController = TransformationController();
  double _viewportWidth = 320;
  double _viewportHeight = 290;

  Uint8List? _capturedImageBytes;
  bool _hasScanError = false;
  String? _errorMessage;

  // Detected band count from scanner, and the user's post-scan override (starts same)
  int _detectedBandCount = 4;
  int _selectedBandCount = 4;
  List<double>? _detectedBandPositions;
  int _band1 = 1; // Default Brown
  int _band2 = 7; // Default Violet
  int _band3 = 2; // Default Red
  int _band4 = 2; // Default Gold
  int _band5 = 0; // Default Brown (±1%)
  int _band6 = 0; // Default Brown (100 ppm/K)

  final ImagePicker _picker = ImagePicker();

  // Camera Controls State: Zoom, Flash/Torch, Tap-to-Focus
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 5.0;
  double _baseScale = 1.0;
  FlashMode _currentFlashMode = FlashMode.off;
  Offset? _tapFocusOffset;
  bool _showFocusRing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageBytesForTesting != null) {
      _selectedImageBytes = widget.initialImageBytesForTesting;
      _isAdjustingImage = true;
    } else {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await controller.initialize();
        
        double minZ = 1.0;
        double maxZ = 5.0;
        try {
          minZ = await controller.getMinZoomLevel();
          maxZ = await controller.getMaxZoomLevel();
          if (maxZ > 5.0) maxZ = 5.0;
        } catch (_) {}

        if (mounted) {
          setState(() {
            _cameraController = controller;
            _isCameraInitialized = true;
            _minZoom = minZ;
            _maxZoom = maxZ;
            _currentZoom = minZ;
            _currentFlashMode = FlashMode.off;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_cameraController == null || !_isCameraInitialized) return;
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    try {
      await _cameraController!.setZoomLevel(clamped);
      if (mounted) {
        setState(() => _currentZoom = clamped);
      }
    } catch (_) {}
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      final newMode = _currentFlashMode == FlashMode.off
          ? FlashMode.torch
          : (_currentFlashMode == FlashMode.torch ? FlashMode.auto : FlashMode.off);
      await _cameraController!.setFlashMode(newMode);
      if (mounted) {
        setState(() => _currentFlashMode = newMode);
      }
    } catch (_) {}
  }

  Future<void> _turnOffFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    if (_currentFlashMode != FlashMode.off) {
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
        if (mounted) {
          setState(() => _currentFlashMode = FlashMode.off);
        }
      } catch (_) {}
    }
  }

  Future<void> _onTapToFocus(TapDownDetails details, BoxConstraints constraints) async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      final double x = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
      final double y = (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);
      final point = Offset(x, y);

      await _cameraController!.setFocusPoint(point);
      await _cameraController!.setExposurePoint(point);
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (mounted) {
        setState(() {
          _tapFocusOffset = details.localPosition;
          _showFocusRing = true;
        });
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() => _showFocusRing = false);
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_cameraController != null && _isCameraInitialized && _currentFlashMode != FlashMode.off) {
      try {
        _cameraController!.setFlashMode(FlashMode.off);
      } catch (_) {}
    }
    _cameraController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _handleCameraAction() async {
    if (_isProcessing) return;

    // If camera is not yet initialized, try to initialize it first (requests permissions)
    if (!_isCameraInitialized) {
      setState(() => _isProcessing = true);
      await _initCamera();
      setState(() => _isProcessing = false);
      
      // If initialization succeeded, the preview will now show. Return so user can aim and click capture.
      if (_isCameraInitialized && _cameraController != null) {
        return;
      } else {
        // If it failed (e.g., permission denied or no camera), fallback to native picker
        _fallbackToNativeCamera();
        return;
      }
    }

    // If live camera controller is already initialized and ready, take a picture
    if (_cameraController != null) {
      try {
        setState(() => _isProcessing = true);
        final file = await _cameraController!.takePicture();
        // Turn off flash / torch immediately after photo is captured so it never stays on forever
        await _turnOffFlash();
        final bytes = await file.readAsBytes();
        _startAdjustment(bytes);
      } catch (e) {
        await _turnOffFlash();
        _handleScanFailure("Failed to capture image: $e");
      }
    }
  }

  Future<void> _fallbackToNativeCamera() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        _startAdjustment(bytes);
      }
    } catch (e) {
      _handleScanFailure("Camera not available: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    await _turnOffFlash();
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        _startAdjustment(bytes);
      }
    } catch (e) {
      _handleScanFailure("Could not load image: $e");
    }
  }

  void _startAdjustment(Uint8List bytes) {
    setState(() {
      _selectedImageBytes = bytes;
      _isAdjustingImage = true;
      _isProcessing = false;
      _hasScanError = false;
      _errorMessage = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _cancelAdjustment() {
    setState(() {
      _isAdjustingImage = false;
      _selectedImageBytes = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _zoomBy(double factor) {
    final Matrix4 current = _transformationController.value;
    final double currentScale = current.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(0.8, 8.0);
    final double actualFactor = targetScale / currentScale;

    final double cx = _viewportWidth / 2.0;
    final double cy = _viewportHeight / 2.0;

    final Matrix4 translationToCenter = Matrix4.translationValues(-cx, -cy, 0);
    final Matrix4 scaleMatrix = Matrix4.diagonal3Values(actualFactor, actualFactor, 1.0);
    final Matrix4 translationBack = Matrix4.translationValues(cx, cy, 0);

    final Matrix4 newTransform = translationBack * scaleMatrix * translationToCenter * current;
    setState(() {
      _transformationController.value = newTransform;
    });
  }

  void _zoomIn() => _zoomBy(1.3);
  void _zoomOut() => _zoomBy(1.0 / 1.3);

  void _resetPosition() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _scanAdjustedImage() {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isProcessing = true;
      _isAdjustingImage = false;
    });

    final processedBytes = _extractPositionedRegion(
      sourceBytes: _selectedImageBytes!,
      transform: _transformationController.value,
      viewportWidth: _viewportWidth > 0 ? _viewportWidth : 320,
      viewportHeight: _viewportHeight > 0 ? _viewportHeight : 290,
    );

    _processImageBytes(processedBytes);
  }

  /// Extracts the viewport region corresponding to the guide box from the
  /// user-adjusted image transformation and passes it to resistor detection.
  Uint8List _extractPositionedRegion({
    required Uint8List sourceBytes,
    required Matrix4 transform,
    required double viewportWidth,
    required double viewportHeight,
  }) {
    try {
      final srcImg = img.decodeImage(sourceBytes);
      if (srcImg == null) return sourceBytes;

      final double srcW = srcImg.width.toDouble();
      final double srcH = srcImg.height.toDouble();

      final double scaleFit = math.min(viewportWidth / srcW, viewportHeight / srcH);
      final double fittedW = srcW * scaleFit;
      final double fittedH = srcH * scaleFit;
      final double offsetX = (viewportWidth - fittedW) / 2.0;
      final double offsetY = (viewportHeight - fittedH) / 2.0;

      final Matrix4 inv = Matrix4.inverted(transform);

      final int outW = math.max(640, math.min((viewportWidth * 1.5).round(), 1080));
      final int outH = (outW * (viewportHeight / viewportWidth)).round().clamp(200, 1080);
      final outImg = img.Image(width: outW, height: outH);

      final double invScaleX = inv.storage[0];
      final double invTransX = inv.storage[12];
      final double invScaleY = inv.storage[5];
      final double invTransY = inv.storage[13];

      for (int y = 0; y < outH; y++) {
        final double vpY = (y / outH) * viewportHeight;
        final double childY = invScaleY * vpY + invTransY;
        final double imgY = (childY - offsetY) / scaleFit;
        final int srcYInt = imgY.round();
        final bool validY = srcYInt >= 0 && srcYInt < srcImg.height;

        for (int x = 0; x < outW; x++) {
          final double vpX = (x / outW) * viewportWidth;
          final double childX = invScaleX * vpX + invTransX;
          final double imgX = (childX - offsetX) / scaleFit;
          final int srcXInt = imgX.round();

          if (validY && srcXInt >= 0 && srcXInt < srcImg.width) {
            outImg.setPixel(x, y, srcImg.getPixel(srcXInt, srcYInt));
          } else {
            outImg.setPixelRgb(x, y, 220, 200, 170);
          }
        }
      }

      return Uint8List.fromList(img.encodePng(outImg));
    } catch (_) {
      return sourceBytes;
    }
  }

  
  Future<void> _processImageBytes(Uint8List bytes) async {
    ResistorScanResult result = await ScannerCoordinator.detect(bytes);

    setState(() {
      _capturedImageBytes = bytes;
      _isProcessing = false;
      if (result.isSuccess) {
        _hasScanError = false;
        _errorMessage = null;
        _detectedBandCount = result.bandCount;
        _selectedBandCount = (result.bandCount >= 4 && result.bandCount <= 6)
            ? result.bandCount
            : 4;
        _band1 = result.band1Index;
        _band2 = result.band2Index;
        _band3 = result.band3Index;
        _band4 = result.band4Index;
        _band5 = result.band5Index ?? 0;
        _band6 = result.band6Index ?? 0;
        if (result.detectedCandidates.isNotEmpty) {
          final positions = result.detectedCandidates
              .map((c) => c.axisPosition)
              .where((p) => p > 0.05 && p < 0.95)
              .toList();
          _detectedBandPositions =
              positions.length == _selectedBandCount ? positions : null;
        } else {
          _detectedBandPositions = null;
        }
        _clampBandIndices();
      } else {
        _hasScanError = true;
        _errorMessage = result.errorMessage ?? "Resistor not detected clearly.";
        _detectedBandPositions = null;
      }
    });
  }

  void _handleScanFailure(String message) {
    setState(() {
      _isProcessing = false;
      _isAdjustingImage = false;
      _hasScanError = true;
      _errorMessage = message;
      _detectedBandPositions = null;
    });
  }

  void _resetScan() {
    setState(() {
      _selectedImageBytes = null;
      _capturedImageBytes = null;
      _detectedBandPositions = null;
      _isAdjustingImage = false;
      _hasScanError = false;
      _errorMessage = null;
      _isProcessing = false;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _clampBandIndices() {
    _selectedBandCount = _selectedBandCount.clamp(4, 6);
    if (_selectedBandCount == 4) {
      _band1 = _band1.clamp(0, 9);
      _band2 = _band2.clamp(0, 9);
      _band3 = _band3.clamp(0, ResistorScannerService.multiplierColors.length - 1);
      _band4 = _band4.clamp(0, ResistorScannerService.toleranceColors.length - 1);
    } else {
      _band1 = _band1.clamp(0, 9);
      _band2 = _band2.clamp(0, 9);
      _band3 = _band3.clamp(0, 9);
      _band4 = _band4.clamp(0, ResistorScannerService.multiplierColors.length - 1);
      _band5 = _band5.clamp(0, ResistorScannerService.toleranceColors.length - 1);
      if (_selectedBandCount == 6) {
        _band6 = _band6.clamp(0, ResistorScannerService.tempCoColors.length - 1);
      }
    }
  }

  void _onBandColorChanged(int bandIndex, int newColorIndex) {
    setState(() {
      switch (bandIndex) {
        case 0:
          _band1 = newColorIndex;
          break;
        case 1:
          _band2 = newColorIndex;
          break;
        case 2:
          _band3 = newColorIndex;
          break;
        case 3:
          _band4 = newColorIndex;
          break;
        case 4:
          _band5 = newColorIndex;
          break;
        case 5:
          _band6 = newColorIndex;
          break;
      }
      _clampBandIndices();
    });
  }

  void _openBandColorPicker(int bandIndex) {
    int curVal = 0;
    switch (bandIndex) {
      case 0: curVal = _band1; break;
      case 1: curVal = _band2; break;
      case 2: curVal = _band3; break;
      case 3: curVal = _band4; break;
      case 4: curVal = _band5; break;
      case 5: curVal = _band6; break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BandColorPickerModal(
        bandIndex: bandIndex,
        bandCount: _selectedBandCount,
        currentValue: curVal,
        onColorSelected: (newVal) => _onBandColorChanged(bandIndex, newVal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ResistorScannerService.calculate(
      bandCount: _selectedBandCount,
      band1Index: _band1,
      band2Index: _band2,
      band3Index: _band3,
      band4Index: _band4,
      band5Index: _band5,
      band6Index: _band6,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scan Resistor'),
        leading: _isAdjustingImage
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: _cancelAdjustment,
              )
            : null,
        actions: [
          if (!_isAdjustingImage)
            IconButton(
              icon: const Icon(Icons.photo_library_rounded),
              tooltip: 'Pick from Gallery',
              onPressed: _pickFromGallery,
            ),
        ],
      ),
      body: FuturisticBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.0,
                14.0,
                16.0,
                MediaQuery.paddingOf(context).bottom + 40.0,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Camera / Image Viewfinder Container
                    _buildViewfinderContainer(),
                    const SizedBox(height: 14),

                    // Guide / Instruction text
                    Center(
                      child: Text(
                        _isAdjustingImage
                            ? 'Move and zoom the image until the resistor is inside the guide.'
                            : 'Place the resistor inside the guide and make sure the color bands are clearly visible.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action State (Scanning, Adjusting, Error, or Results)
                    if (_isProcessing)
                      _buildProcessingIndicator()
                    else if (_isAdjustingImage)
                      _buildAdjustmentControls()
                    else if (_hasScanError)
                      _buildErrorView()
                    else if (_capturedImageBytes != null)
                      _buildResultsSection(calculation)
                    else
                      _buildCaptureControls(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildZoomPill(double targetZoom, String label) {
    final bool isSelected = (_currentZoom - targetZoom).abs() < 0.25;
    return GestureDetector(
      onTap: () => _setZoomLevel(targetZoom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF) : Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF080D1A) : Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Viewfinder frame showing live preview, interactive image adjustment, captured image, or placeholder.
  Widget _buildViewfinderContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 290,
        width: double.infinity,
        color: const Color(0xFF0A0F1D),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _viewportWidth = constraints.maxWidth;
            _viewportHeight = constraints.maxHeight;

            final double guideWidth = _viewportWidth * 0.60;
            final double guideHeight = _viewportHeight * 0.30;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Background Content (Interactive Image, Captured Image, CameraPreview, or Placeholder)
                if (_isAdjustingImage && _selectedImageBytes != null)
                  InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 8.0,
                    boundaryMargin: const EdgeInsets.all(240),
                    panEnabled: true,
                    scaleEnabled: true,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _viewportWidth,
                      height: _viewportHeight,
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else if (_capturedImageBytes != null)
                  Image.memory(
                    _capturedImageBytes!,
                    fit: BoxFit.cover,
                  )
                else if (_isCameraInitialized && _cameraController != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _onTapToFocus(details, constraints),
                    onScaleStart: (_) => _baseScale = _currentZoom,
                    onScaleUpdate: (details) => _setZoomLevel((_baseScale * details.scale).clamp(_minZoom, _maxZoom)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraController!),
                        if (_showFocusRing && _tapFocusOffset != null)
                          Positioned(
                            left: _tapFocusOffset!.dx - 26,
                            top: _tapFocusOffset!.dy - 26,
                            child: IgnorePointer(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.center_focus_strong_rounded, color: Color(0xFF00E5FF), size: 24),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF101726),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Optical Sensor Viewfinder',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Layer 2: Fixed Visual Resistor Alignment Guide Box (Overlay)
                IgnorePointer(
                  child: Center(
                    child: Container(
                      key: const Key('resistor_alignment_guide'),
                      width: guideWidth,
                      height: guideHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00E5FF),
                          width: 2.0,
                        ),
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                      child: Center(
                        child: Container(
                          height: 1.5,
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 2b: Interactive Band Overlay with Pointing Arrows & Color Selector
                if (_capturedImageBytes != null && !_hasScanError)
                  Positioned.fill(
                    child: InteractiveBandOverlay(
                      key: const Key('interactive_band_overlay'),
                      bandCount: _selectedBandCount,
                      band1Index: _band1,
                      band2Index: _band2,
                      band3Index: _band3,
                      band4Index: _band4,
                      band5Index: _band5,
                      band6Index: _band6,
                      detectedAxisPositions: _detectedBandPositions,
                      capturedImageBytes: _capturedImageBytes,
                      onBandColorChanged: _onBandColorChanged,
                      viewportWidth: _viewportWidth,
                      viewportHeight: _viewportHeight,
                    ),
                  ),

                // Layer 3: Top Status Badge (Left) - Only in live guide view
                if (_capturedImageBytes == null)
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isAdjustingImage
                                ? const Color(0xFFF59E0B)
                                : (_capturedImageBytes != null ? const Color(0xFF10B981) : const Color(0xFF00E5FF)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAdjustingImage
                              ? 'Adjust Framing'
                              : (_capturedImageBytes != null ? 'Captured Frame' : 'Live Sensor Guide'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Layer 4: Top Flash / Torch Button (Right)
                if (_isCameraInitialized && _cameraController != null && !_isAdjustingImage && _capturedImageBytes == null)
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFlash,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _currentFlashMode == FlashMode.torch
                                ? const Color(0xFFF59E0B)
                                : Colors.black.withValues(alpha: 0.70),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentFlashMode == FlashMode.torch
                                  ? const Color(0xFFF59E0B)
                                  : Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            _currentFlashMode == FlashMode.torch
                                ? Icons.flash_on_rounded
                                : (_currentFlashMode == FlashMode.auto ? Icons.flash_auto_rounded : Icons.flash_off_rounded),
                            color: _currentFlashMode == FlashMode.torch ? const Color(0xFF080D1A) : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Layer 5: Quick Zoom Level Selector (1x, 2x, 3x) at Bottom Center
                if (_isCameraInitialized && _cameraController != null && !_isAdjustingImage && _capturedImageBytes == null)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildZoomPill(1.0, '1x'),
                            const SizedBox(width: 6),
                            _buildZoomPill(2.0, '2x'),
                            const SizedBox(width: 6),
                            _buildZoomPill(3.0, '3x'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Interactive adjustment toolbar and action buttons for gallery/camera images.
  Widget _buildAdjustmentControls() {
    return Column(
      children: [
        // Pan & Zoom tool buttons
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _zoomOut,
                icon: const Icon(Icons.zoom_out_rounded),
                tooltip: 'Zoom Out',
                color: const Color(0xFF334155),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _zoomIn,
                icon: const Icon(Icons.zoom_in_rounded),
                tooltip: 'Zoom In',
                color: const Color(0xFF334155),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: 'Reset Position',
                child: TextButton.icon(
                  onPressed: _resetPosition,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons: Back and Scan
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: _cancelAdjustment,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _scanAdjustedImage,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Scan Resistor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  /// Initial camera capture buttons before a photo is taken.
  Widget _buildCaptureControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleCameraAction,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_isCameraInitialized ? 'Capture Photo' : 'Start Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Loading state indicator during image decoding and detection.
  Widget _buildProcessingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF00E5FF)),
          SizedBox(height: 14),
          Text(
            'Analyzing resistor color bands...',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Friendly error view when detection is unclear.
  Widget _buildErrorView() {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage ?? "Resistor not detected clearly.",
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFCD34D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Scanning Tips for Better Accuracy:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(height: 6),
          _buildTipItem('Move the resistor closer to the camera guide'),
          _buildTipItem('Use good, uniform lighting without harsh reflections'),
          _buildTipItem('Keep all resistor color bands clearly visible inside the guide'),
          _buildTipItem('Place the resistor on a plain, light background'),
          const SizedBox(height: 16),
          if (_selectedImageBytes != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasScanError = false;
                    _errorMessage = null;
                    _isAdjustingImage = true;
                  });
                },
                icon: const Icon(Icons.crop_free_rounded),
                label: const Text('Adjust Position Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFCD34D),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_capturedImageBytes != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasScanError = false;
                    _errorMessage = null;
                  });
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Enter Bands Manually'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E5FF),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  /// Results card showing detected bands, calculated values, and manual correction controls.
  Widget _buildResultsSection(ResistorCalculationResult calculation) {
    final b1 = ResistorScannerService.digitColors[_band1.clamp(0, 9)];
    final b2 = ResistorScannerService.digitColors[_band2.clamp(0, 9)];
    final b3Digit = ResistorScannerService.digitColors[_band3.clamp(0, 9)];
    final b3Mult = ResistorScannerService.multiplierColors[_band3.clamp(0, ResistorScannerService.multiplierColors.length - 1)];
    final b4Mult = ResistorScannerService.multiplierColors[_band4.clamp(0, ResistorScannerService.multiplierColors.length - 1)];
    final b4Tol = ResistorScannerService.toleranceColors[_band4.clamp(0, ResistorScannerService.toleranceColors.length - 1)];
    final b5Tol = ResistorScannerService.toleranceColors[_band5.clamp(0, ResistorScannerService.toleranceColors.length - 1)];
    final b6Temp = ResistorScannerService.tempCoColors[_band6.clamp(0, ResistorScannerService.tempCoColors.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Detected Bands Summary GlassContainer with Band Count Selector
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DETECTED COLOR BANDS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detected $_detectedBandCount bands',
                          key: const Key('detected_band_count_text'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Bands: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      DropdownButton<int>(
                        key: const Key('scanner_band_count_dropdown'),
                        value: const [4, 5, 6].contains(_selectedBandCount)
                            ? _selectedBandCount
                            : null,
                        dropdownColor: const Color(0xFF0F172A),
                        underline: const SizedBox(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                        items: const [
                          DropdownMenuItem(value: 4, child: Text('4 bands')),
                          DropdownMenuItem(value: 5, child: Text('5 bands')),
                          DropdownMenuItem(value: 6, child: Text('6 bands')),
                        ],
                        onChanged: (newCount) {
                          if (newCount != null) {
                            setState(() {
                              _selectedBandCount = newCount;
                              if (newCount != _detectedBandCount) {
                                _detectedBandPositions = null;
                              }
                              _clampBandIndices();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF00E5FF)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Tap any band arrow on the image above (or tap chips below) to change colors directly.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBandChip('Band 1', b1.name, b1.color, onTap: () => _openBandColorPicker(0)),
                  _buildBandChip('Band 2', b2.name, b2.color, onTap: () => _openBandColorPicker(1)),
                  if (_selectedBandCount == 4) ...[
                    _buildBandChip('Band 3', b3Mult.name, b3Mult.color, onTap: () => _openBandColorPicker(2)),
                    _buildBandChip('Band 4', b4Tol.name, b4Tol.color, onTap: () => _openBandColorPicker(3)),
                  ] else ...[
                    _buildBandChip('Band 3', b3Digit.name, b3Digit.color, onTap: () => _openBandColorPicker(2)),
                    _buildBandChip('Band 4', b4Mult.name, b4Mult.color, onTap: () => _openBandColorPicker(3)),
                    _buildBandChip('Band 5', b5Tol.name, b5Tol.color, onTap: () => _openBandColorPicker(4)),
                    if (_selectedBandCount == 6)
                      _buildBandChip('Band 6', b6Temp.name, b6Temp.color, onTap: () => _openBandColorPicker(5)),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Calculated Value GlassContainer
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'CALCULATED VALUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${calculation.readableNominal} ${calculation.toleranceLabel}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${ResistorScannerService.formatResistance(calculation.nominalOhms)} nominal',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
              if (_selectedBandCount == 6 && calculation.tempCoLabel != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Temp. Coefficient: ${calculation.tempCoLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF67E8F9),
                    ),
                  ),
                ),
              ],
              const Divider(height: 24, color: Colors.white12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLimitText('Minimum', calculation.readableMin),
                  _buildLimitText('Maximum', calculation.readableMax),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Manual Correction GlassContainer
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: Color(0xFF00E5FF), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Manual Correction',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'If camera lighting affected any band, adjust it below:',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),

              if (_selectedBandCount == 4) ...[
                // 4-band: Band 1 (Digit), Band 2 (Digit), Band 3 (Multiplier), Band 4 (Tolerance)
                _buildDigitCorrectionDropdown(
                  label: 'Band 1 (1st Digit)',
                  value: _band1,
                  onChanged: (val) => setState(() => _band1 = val!),
                ),
                const SizedBox(height: 10),
                _buildDigitCorrectionDropdown(
                  label: 'Band 2 (2nd Digit)',
                  value: _band2,
                  onChanged: (val) => setState(() => _band2 = val!),
                ),
                const SizedBox(height: 10),
                _buildMultiplierCorrectionDropdown(
                  label: 'Band 3 (Multiplier)',
                  value: _band3,
                  onChanged: (val) => setState(() => _band3 = val!),
                ),
                const SizedBox(height: 10),
                _buildToleranceCorrectionDropdown(
                  label: 'Band 4 (Tolerance)',
                  value: _band4,
                  onChanged: (val) => setState(() => _band4 = val!),
                ),
              ] else if (_selectedBandCount == 5) ...[
                // 5-band: Band 1 (Digit), Band 2 (Digit), Band 3 (Digit), Band 4 (Multiplier), Band 5 (Tolerance)
                _buildDigitCorrectionDropdown(
                  label: 'Band 1 (1st Digit)',
                  value: _band1,
                  onChanged: (val) => setState(() => _band1 = val!),
                ),
                const SizedBox(height: 10),
                _buildDigitCorrectionDropdown(
                  label: 'Band 2 (2nd Digit)',
                  value: _band2,
                  onChanged: (val) => setState(() => _band2 = val!),
                ),
                const SizedBox(height: 10),
                _buildDigitCorrectionDropdown(
                  label: 'Band 3 (3rd Digit)',
                  value: _band3,
                  onChanged: (val) => setState(() => _band3 = val!),
                ),
                const SizedBox(height: 10),
                _buildMultiplierCorrectionDropdown(
                  label: 'Band 4 (Multiplier)',
                  value: _band4,
                  onChanged: (val) => setState(() => _band4 = val!),
                ),
                const SizedBox(height: 10),
                _buildToleranceCorrectionDropdown(
                  label: 'Band 5 (Tolerance)',
                  value: _band5,
                  onChanged: (val) => setState(() => _band5 = val!),
                ),
              ] else ...[
                // 6-band: Band 1 (Digit), Band 2 (Digit), Band 3 (Digit), Band 4 (Multiplier), Band 5 (Tolerance), Band 6 (TempCo)
                _buildDigitCorrectionDropdown(
                  label: 'Band 1 (1st Digit)',
                  value: _band1,
                  onChanged: (val) => setState(() => _band1 = val!),
                ),
                const SizedBox(height: 10),
                _buildDigitCorrectionDropdown(
                  label: 'Band 2 (2nd Digit)',
                  value: _band2,
                  onChanged: (val) => setState(() => _band2 = val!),
                ),
                const SizedBox(height: 10),
                _buildDigitCorrectionDropdown(
                  label: 'Band 3 (3rd Digit)',
                  value: _band3,
                  onChanged: (val) => setState(() => _band3 = val!),
                ),
                const SizedBox(height: 10),
                _buildMultiplierCorrectionDropdown(
                  label: 'Band 4 (Multiplier)',
                  value: _band4,
                  onChanged: (val) => setState(() => _band4 = val!),
                ),
                const SizedBox(height: 10),
                _buildToleranceCorrectionDropdown(
                  label: 'Band 5 (Tolerance)',
                  value: _band5,
                  onChanged: (val) => setState(() => _band5 = val!),
                ),
                const SizedBox(height: 10),
                _buildTempCoCorrectionDropdown(
                  label: 'Band 6 (Temp. Coefficient)',
                  value: _band6,
                  onChanged: (val) => setState(() => _band6 = val!),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Action Buttons (Scan Again / Use These Bands)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetScan,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final confirmText = calculation.tempCoLabel != null
                      ? 'Values Confirmed: ${calculation.readableNominal} ${calculation.toleranceLabel}, ${calculation.tempCoLabel}'
                      : 'Values Confirmed: ${calculation.readableNominal} ${calculation.toleranceLabel}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(confirmText),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Use These Bands'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF080D1A),
                  elevation: 4,
                  shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildLimitText(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildBandChip(String label, String colorName, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == Colors.white ? Colors.grey : Colors.white24,
                    width: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$label: $colorName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.edit_outlined, size: 12, color: Color(0xFF00E5FF)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitCorrectionDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = value.clamp(0, ResistorScannerService.digitColors.length - 1);
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      ),
      items: List.generate(ResistorScannerService.digitColors.length, (i) {
        final b = ResistorScannerService.digitColors[i];
        return DropdownMenuItem<int>(
          value: i,
          child: Row(
            children: [
              _buildColorCircle(b.color),
              const SizedBox(width: 8),
              Text('${b.name} (${b.value})'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildMultiplierCorrectionDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = value.clamp(0, ResistorScannerService.multiplierColors.length - 1);
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      ),
      items: List.generate(ResistorScannerService.multiplierColors.length, (i) {
        final b = ResistorScannerService.multiplierColors[i];
        return DropdownMenuItem<int>(
          value: i,
          child: Row(
            children: [
              _buildColorCircle(b.color),
              const SizedBox(width: 8),
              Text('${b.name} (×${ResistorScannerService.formatResistance(b.multiplier)})'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildToleranceCorrectionDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = value.clamp(0, ResistorScannerService.toleranceColors.length - 1);
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      ),
      items: List.generate(ResistorScannerService.toleranceColors.length, (i) {
        final b = ResistorScannerService.toleranceColors[i];
        final tolText = b.tolerance != null
            ? (b.tolerance! < 1.0 ? '±${b.tolerance}%' : '±${b.tolerance!.toStringAsFixed(0)}%')
            : '';
        return DropdownMenuItem<int>(
          value: i,
          child: Row(
            children: [
              _buildColorCircle(b.color),
              const SizedBox(width: 8),
              Text('${b.name} ($tolText)'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildTempCoCorrectionDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = value.clamp(0, ResistorScannerService.tempCoColors.length - 1);
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      ),
      items: List.generate(ResistorScannerService.tempCoColors.length, (i) {
        final b = ResistorScannerService.tempCoColors[i];
        return DropdownMenuItem<int>(
          value: i,
          child: Row(
            children: [
              _buildColorCircle(b.color),
              const SizedBox(width: 8),
              Text('${b.name} (${b.value} ppm/K)'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: color == Colors.white ? Colors.grey : Colors.black12,
          width: 0.5,
        ),
      ),
    );
  }
}
