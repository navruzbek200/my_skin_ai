import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';

enum _FaceState { waiting, tooDark, tracking, timedOut, done }

class FaceScanScreen extends StatefulWidget {
  final List<dynamic> quizAnswers;
  const FaceScanScreen({super.key, required this.quizAnswers});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  CameraController? _cam;
  FaceDetector? _detector;
  bool _isDetecting = false;
  // Plain bool used as a synchronous guard in async paths after dispose
  bool _isDone = false;
  double _lightLevel = 0.5;
  bool _trackingStarted = false;
  Timer? _scanTimeoutTimer;

  static const int _totalSegments = 60;
  final Set<int> _doneSegments = {};

  late final AnimationController _morphCtrl; // 0 = rect, 1 = oval
  late final AnimationController _rotCtrl;   // rotating scanner arc
  late final AnimationController _pulseCtrl; // border glow pulse

  // ValueNotifiers drive the overlay/status without rebuilding CameraPreview
  final ValueNotifier<_FaceState> _faceStateNotifier =
      ValueNotifier(_FaceState.waiting);
  final ValueNotifier<bool> _isDoneNotifier = ValueNotifier(false);
  final ValueNotifier<Set<int>> _segmentsNotifier = ValueNotifier(const {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _initCameraWithPermission();
  }

  // ── Permission ────────────────────────────────────────────────

  Future<void> _initCameraWithPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      await _initCamera();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else {
      _goToScanTab();
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kamera ruxsati kerak',
          style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Teri tahlili uchun kameraga ruxsat bering. '
          'Sozlamalarda "Kamera" ruxsatini yoqing.',
          style: GoogleFonts.nunito(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _goToScanTab();
            },
            child: Text('Bekor qilish',
                style: GoogleFonts.nunito(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: Text('Sozlamalar',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Camera ────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) { _goToScanTab(); return; }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        // Android ML Kit requires NV21/YUV420; iOS uses BGRA8888
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await ctrl.initialize();

      if (!mounted) {
        // Widget disposed during async init — must release camera
        ctrl.dispose();
        return;
      }

      setState(() => _cam = ctrl);
      ctrl.startImageStream(_processFrame);
    } on CameraException catch (e, st) {
      AppLogger.error('Camera init failed', e, st);
      if (mounted) _goToScanTab();
    } catch (e, st) {
      AppLogger.error('Camera init unexpected error', e, st);
      if (mounted) _goToScanTab();
    }
  }

  // ── App lifecycle ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pauseCamera();
      case AppLifecycleState.resumed:
        _resumeCamera();
      default:
        break;
    }
  }

  Future<void> _pauseCamera() async {
    final cam = _cam;
    if (cam == null) return;
    _cam = null;
    try { await cam.stopImageStream(); } catch (_) {}
    try { await cam.dispose(); } catch (_) {}
    // Redraw so the preview slot shows black while backgrounded
    if (mounted) setState(() {});
  }

  Future<void> _resumeCamera() async {
    if (_isDone || _cam != null) return;
    await _initCamera();
  }

  void _goToScanTab() {
    if (!mounted) return;
    context.go('/home', extra: 1);
  }

  // ── Frame processing ──────────────────────────────────────────

  Future<void> _processFrame(CameraImage image) async {
    if (_isDetecting || _isDone) return;
    _isDetecting = true;
    try {
      _updateLuminance(image);

      final inputImage = _buildInputImage(image);
      if (inputImage == null || _detector == null) return;

      final faces = await _detector!.processImage(inputImage);
      if (!mounted || _isDone) return;

      final hasFace = faces.isNotEmpty;
      final lightOk = _lightLevel > 0.18;
      final canTrack = hasFace && lightOk;

      if (canTrack) {
        _faceStateNotifier.value = _FaceState.tracking;

        if (_morphCtrl.status != AnimationStatus.forward &&
            _morphCtrl.status != AnimationStatus.completed) {
          _morphCtrl.forward();
        }
        if (!_rotCtrl.isAnimating) {
          _rotCtrl.repeat();
        }
        if (!_trackingStarted) {
          _trackingStarted = true;
          _startScanTimeout();
        }

        // Map head Euler angles to a ring segment
        final face = faces.first;
        final y = face.headEulerAngleY ?? 0.0;
        final x = face.headEulerAngleX ?? 0.0;
        final theta = math.atan2(x / 30.0, y / 90.0);
        final normalized = (theta + math.pi) / (2 * math.pi);
        final seg = (normalized * _totalSegments).floor() % _totalSegments;

        bool changed = false;
        for (int d = -2; d <= 2; d++) {
          changed =
              _doneSegments.add((seg + d + _totalSegments) % _totalSegments) ||
              changed;
        }
        if (changed) {
          _segmentsNotifier.value = Set<int>.unmodifiable(_doneSegments);
        }

        if (_doneSegments.length >= _totalSegments) {
          _finishScan();
        }
      } else {
        _faceStateNotifier.value =
            hasFace ? _FaceState.tooDark : _FaceState.waiting;

        if (_morphCtrl.status != AnimationStatus.reverse &&
            _morphCtrl.status != AnimationStatus.dismissed) {
          _morphCtrl.reverse();
        }
        if (_rotCtrl.isAnimating) {
          _rotCtrl.stop();
          _rotCtrl.reset();
        }
      }
    } catch (_) {
    } finally {
      _isDetecting = false;
    }
  }

  void _updateLuminance(CameraImage image) {
    try {
      if (Platform.isAndroid && image.planes.isNotEmpty) {
        // YUV420: Y plane (index 0) is luminance directly
        final yBytes = image.planes[0].bytes;
        final yStride = image.planes[0].bytesPerRow;
        int sum = 0, count = 0;
        for (int row = 0; row < image.height; row += 8) {
          for (int col = 0; col < image.width; col += 8) {
            final idx = row * yStride + col;
            if (idx < yBytes.length) {
              sum += yBytes[idx] & 0xFF;
              count++;
            }
          }
        }
        if (count > 0) _lightLevel = (sum / count / 255.0).clamp(0.0, 1.0);
      } else if (image.planes.isNotEmpty) {
        // iOS BGRA8888: compute luminance from RGB channels
        final bytes = image.planes.first.bytes;
        final stride = image.planes.first.bytesPerRow;
        int sum = 0, count = 0;
        for (int row = 0; row < image.height; row += 8) {
          for (int col = 0; col < image.width; col += 8) {
            final idx = row * stride + col * 4;
            if (idx + 2 < bytes.length) {
              sum += (0.299 * bytes[idx + 2] +
                      0.587 * bytes[idx + 1] +
                      0.114 * bytes[idx])
                  .round();
              count++;
            }
          }
        }
        if (count > 0) _lightLevel = (sum / count / 255.0).clamp(0.0, 1.0);
      }
    } catch (_) {}
  }

  void _startScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = Timer(const Duration(seconds: 45), () {
      if (_isDone || !mounted) return;
      _faceStateNotifier.value = _FaceState.timedOut;
      _rotCtrl.stop();
      _rotCtrl.reset();
      if (_morphCtrl.status != AnimationStatus.reverse &&
          _morphCtrl.status != AnimationStatus.dismissed) {
        _morphCtrl.reverse();
      }
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _goToScanTab();
      });
    });
  }

  InputImage? _buildInputImage(CameraImage image) {
    if (_cam == null || image.planes.isEmpty) return null;
    final camera = _cam!.description;
    final sensorOrientation = camera.sensorOrientation;
    final int rawRotation = camera.lensDirection == CameraLensDirection.front
        ? (360 - sensorOrientation) % 360
        : sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(rawRotation)
        ?? InputImageRotation.rotation0deg;

    if (Platform.isAndroid) {
      return _buildInputImageAndroid(image, rotation);
    }
    // iOS: BGRA8888 single-plane format
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Converts YUV420 planes to NV21 byte buffer for Android ML Kit.
  /// Camera frames are processed in-memory only — never written to disk or transmitted.
  InputImage? _buildInputImageAndroid(
      CameraImage image, InputImageRotation rotation) {
    if (image.planes.length < 3) return null;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int ySize = image.width * image.height;
    final nv21 = Uint8List(ySize + ySize ~/ 2);

    // Y plane — copy row by row to handle stride ≠ width
    int nv21Idx = 0;
    for (int row = 0; row < image.height; row++) {
      nv21.setRange(
          nv21Idx, nv21Idx + image.width, yPlane.bytes, row * yPlane.bytesPerRow);
      nv21Idx += image.width;
    }

    // Interleave V then U (NV21 = Y…VU…)
    final vRowStride = vPlane.bytesPerRow;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    final uRowStride = uPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final uvHeight = image.height ~/ 2;
    final uvWidth = image.width ~/ 2;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        nv21[nv21Idx++] = vPlane.bytes[row * vRowStride + col * vPixelStride];
        nv21[nv21Idx++] = uPlane.bytes[row * uRowStride + col * uPixelStride];
      }
    }

    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      ),
    );
  }

  Future<void> _finishScan() async {
    if (_isDone) return;
    _isDone = true;
    _isDoneNotifier.value = true;
    _faceStateNotifier.value = _FaceState.done;
    _scanTimeoutTimer?.cancel();
    _rotCtrl.stop();
    HapticFeedback.heavyImpact();
    try { await _cam?.stopImageStream(); } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.pushReplacement('/analysis', extra: widget.quizAnswers);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimeoutTimer?.cancel();
    _morphCtrl.dispose();
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    _segmentsNotifier.dispose();
    _faceStateNotifier.dispose();
    _isDoneNotifier.dispose();
    _detector?.close();
    final cam = _cam;
    _cam = null;
    if (cam != null) {
      cam.stopImageStream()
          .catchError((_) {})
          .whenComplete(cam.dispose);
    }
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview — only rebuilt when _cam changes via setState in
          // _initCamera / _pauseCamera. Not affected by animation ticks.
          if (_cam != null && _cam!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cam!.value.previewSize!.height,
                  height: _cam!.value.previewSize!.width,
                  child: CameraPreview(_cam!),
                ),
              ),
            )
          else
            Container(color: Colors.black),

          // Morphing overlay — RepaintBoundary isolates its 60-fps repaint
          // from the camera layer. Rebuilt only by the merged listenable.
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _morphCtrl,
                _rotCtrl,
                _pulseCtrl,
                _segmentsNotifier,
                _faceStateNotifier,
                _isDoneNotifier,
              ]),
              builder: (_, _) => CustomPaint(
                painter: _ScanPainter(
                  morphValue: _morphCtrl.value,
                  rotValue: _rotCtrl.value,
                  pulseValue: _pulseCtrl.value,
                  doneSegments: _segmentsNotifier.value,
                  totalSegments: _totalSegments,
                  faceState: _faceStateNotifier.value,
                  isDone: _isDoneNotifier.value,
                ),
              ),
            ),
          ),

          // Top bar — static widget, never rebuilt by animation ticks
          Positioned(
            top: top + 14, left: 20, right: 20,
            child: Row(
              children: [
                _CircleBtn(
                  child: const Icon(Icons.help_outline_rounded,
                      color: Colors.white, size: 18),
                  onTap: () => _showHelp(context),
                ),
                const Spacer(),
                _CircleBtn(
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Bottom status — only rebuilds when state/done notifiers fire
          Positioned(
            bottom: bottom + 44, left: 32, right: 32,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isDoneNotifier,
              builder: (_, isDone, _) => ValueListenableBuilder<_FaceState>(
                valueListenable: _faceStateNotifier,
                builder: (_, state, _) => _buildStatus(state, isDone),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(_FaceState state, bool isDone) {
    if (isDone) {
      return _StatusPill(
        text: 'Tahlil qilinmoqda...',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF4CAF50),
      );
    }
    return switch (state) {
      _FaceState.waiting => const _StatusPill(
          text: 'Yuzingizni kameraga tutib turing',
          color: Colors.white,
        ),
      _FaceState.tooDark => const _StatusPill(
          text: 'Ko\'proq yorug\'lik kerak',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFFFC107),
        ),
      _FaceState.tracking => const _StatusPill(
          text: 'Boshingizni sekin aylantiring',
          color: Color(0xFF4CAF50),
        ),
      _FaceState.timedOut => const _StatusPill(
          text: 'Aniqlashda muammo — qayta urinib ko\'ring',
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFFF8A35),
        ),
      _FaceState.done => const SizedBox.shrink(),
    };
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qanday ishlaydi?',
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              '• Yuzingizni oval ichiga joylashtiring\n'
              '• Boshingizni sekin doira bo\'ylab aylantiring\n'
              '• Yashil segmentlar to\'ldiriladi\n'
              '• Tahlil avtomatik boshlanadi',
              style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white54, height: 1.7),
            ),
            const SizedBox(height: 20),
            // Non-medical disclaimer — required by App Store review guidelines
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.orange.withValues(alpha: 0.30)),
              ),
              child: Text(
                'Bu kosmetik tahlil bo\'lib, tibbiy tashxis hisoblanmaydi. '
                'Teri muammolari bo\'lsa mutaxassisga murojaat qiling.',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.orange.shade300,
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const _StatusPill({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Circle button ─────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _CircleBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ── Main painter ──────────────────────────────────────────────

class _ScanPainter extends CustomPainter {
  final double morphValue;
  final double rotValue;
  final double pulseValue;
  final Set<int> doneSegments;
  final int totalSegments;
  final _FaceState faceState;
  final bool isDone;

  const _ScanPainter({
    required this.morphValue,
    required this.rotValue,
    required this.pulseValue,
    required this.doneSegments,
    required this.totalSegments,
    required this.faceState,
    required this.isDone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.40;

    final ovalRx = size.width * 0.365;
    final ovalRy = size.height * 0.265;

    final rectW = size.width * 0.78;
    final rectH = size.height * 0.50;

    final curW = lerpDouble(rectW, ovalRx * 2, morphValue)!;
    final curH = lerpDouble(rectH, ovalRy * 2, morphValue)!;
    final maxR = math.min(curW, curH) / 2;
    final cornerR = lerpDouble(28.0, maxR, morphValue)!;

    final cutoutRect =
        Rect.fromCenter(center: Offset(cx, cy), width: curW, height: curH);
    final cutoutRRect =
        RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerR));

    // Dark overlay with morphing cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRRect);
    overlayPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(
        overlayPath, Paint()..color = Colors.black.withValues(alpha: 0.75));

    final isTracking = faceState == _FaceState.tracking;

    // Tick ring
    if (morphValue > 0.3) {
      final ringOpacity = ((morphValue - 0.3) / 0.7).clamp(0.0, 1.0);
      const innerGap = 5.0;
      const tickLen = 14.0;

      for (int i = 0; i < totalSegments; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / totalSegments);
        final px = cx + ovalRx * math.cos(angle);
        final py = cy + ovalRy * math.sin(angle);
        final nx = ovalRy * math.cos(angle);
        final ny = ovalRx * math.sin(angle);
        final nLen = math.sqrt(nx * nx + ny * ny);
        final nnx = nx / nLen;
        final nny = ny / nLen;

        final filled = doneSegments.contains(i) || isDone;
        final unfillAlpha = (0.28 + pulseValue * 0.14) * ringOpacity;

        canvas.drawLine(
          Offset(px + nnx * innerGap, py + nny * innerGap),
          Offset(px + nnx * (innerGap + tickLen), py + nny * (innerGap + tickLen)),
          Paint()
            ..color = filled
                ? const Color(0xFF4CAF50).withValues(alpha: ringOpacity)
                : Colors.white.withValues(alpha: unfillAlpha)
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
      }

      // Comet sweep arc
      if (isTracking && !isDone && morphValue > 0.8) {
        final fadeIn = ((morphValue - 0.8) / 0.2).clamp(0.0, 1.0);
        const tickMid = innerGap + tickLen / 2;
        final cometRx = ovalRx + tickMid;
        final cometRy = ovalRy + tickMid;
        final cRect = Rect.fromCenter(
            center: Offset(cx, cy),
            width: cometRx * 2,
            height: cometRy * 2);
        final arcStart = -math.pi / 2 + rotValue * 2 * math.pi;
        for (int t = 3; t >= 0; t--) {
          final alpha = (1.0 - t * 0.26) * fadeIn;
          canvas.drawArc(
            cRect,
            arcStart - t * 0.28,
            0.50 - t * 0.08,
            false,
            Paint()
              ..color = const Color(0xFF69F0AE)
                  .withValues(alpha: alpha * (t == 0 ? 1.0 : 0.38))
              ..style = PaintingStyle.stroke
              ..strokeWidth = t == 0 ? 5.5 : 3.5
              ..strokeCap = StrokeCap.round
              ..maskFilter = t == 0
                  ? const MaskFilter.blur(BlurStyle.normal, 6)
                  : null,
          );
        }
      }

      // Oval border glow when tracking
      if (isTracking || isDone) {
        final glowA = (0.35 + pulseValue * 0.3) *
            ((morphValue - 0.5) / 0.5).clamp(0.0, 1.0);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, cy),
              width: ovalRx * 2,
              height: ovalRy * 2),
          Paint()
            ..color = const Color(0xFF4CAF50).withValues(alpha: glowA)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, 5.0 + pulseValue * 4.0),
        );
      }
    }

    // Cutout border
    final borderColor = isDone || isTracking
        ? const Color(0xFF4CAF50)
        : faceState == _FaceState.tooDark
            ? const Color(0xFFFFC107)
            : Colors.white;
    final borderAlpha = isTracking || isDone
        ? 0.55 + pulseValue * 0.45
        : 0.28 + pulseValue * 0.12;
    canvas.drawRRect(
      cutoutRRect,
      Paint()
        ..color = borderColor.withValues(alpha: borderAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.morphValue != morphValue ||
      old.rotValue != rotValue ||
      old.pulseValue != pulseValue ||
      old.doneSegments.length != doneSegments.length ||
      old.faceState != faceState ||
      old.isDone != isDone;
}
