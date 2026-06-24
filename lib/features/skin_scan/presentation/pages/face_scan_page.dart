import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/permissions/camera_permission_service.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';

enum _FaceState {
  waiting,
  tooFar,
  tooClose,
  offCenter,
  notFrontal,
  eyesClosed,
  tooDark,
  ready,
  countdown,
  done,
  timedOut,
}

class FaceScanScreen extends StatefulWidget {
  final List<dynamic> quizAnswers;
  final CameraPermissionService permissionService;
  const FaceScanScreen({
    super.key,
    required this.quizAnswers,
    this.permissionService = const CameraPermissionService(),
  });

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  CameraController? _cam;
  bool _isCameraInitializing = false;
  FaceDetector? _fastDetector;
  bool _isDetecting = false;
  bool _isDone = false;
  double _lightLevel = 0.5;
  int _frameSkip = 0;

  Timer? _stabilityTimer;
  Timer? _countdownTimer;
  Timer? _timeoutTimer;

  late final AnimationController _pulseCtrl;

  final ValueNotifier<_FaceState> _faceStateNotifier =
      ValueNotifier(_FaceState.waiting);
  final ValueNotifier<int?> _countdownNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _captureEnabledNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fastDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.2,
      ),
    );

    _initCameraWithPermission();
  }

  // ── Permission ────────────────────────────────────────────────

  Future<void> _initCameraWithPermission() async {
    final result = await widget.permissionService.ensure();
    if (!mounted) return;
    switch (result) {
      case CameraPermissionResult.granted:
        await _initCamera();
      case CameraPermissionResult.denied:
        _showRationaleSheet();
      case CameraPermissionResult.permanentlyDenied:
      case CameraPermissionResult.restricted:
        _showSettingsDialog();
    }
  }

  void _showRationaleSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kamera ruxsati kerak',
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Teri tahlili uchun old kamera bilan yuzingizni skanerlashimiz kerak.',
              style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white70, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _initCameraWithPermission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  elevation: 0,
                ),
                child: Text(
                  'Ruxsat berish',
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _navigateFallback();
              },
              child: Text(
                'Anketa bilan davom etish',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Kamera ruxsati o'chirilgan",
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'Teri tahlili uchun Sozlamalardan "Kamera" ruxsatini yoqing.',
          style: GoogleFonts.nunito(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateFallback();
            },
            child: Text('Anketa bilan davom etish',
                style: GoogleFonts.nunito(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.permissionService.openSettings();
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
    if (_isCameraInitializing || _cam != null) return;
    _isCameraInitializing = true;
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await ctrl.initialize();

      if (!mounted) {
        ctrl.dispose();
        return;
      }

      setState(() => _cam = ctrl);
      ctrl.startImageStream(_processFrame);
      _startTimeout();
    } on CameraException catch (e, st) {
      AppLogger.error('Camera init failed', e, st);
      if (mounted) _showNoCameraDialog();
    } catch (e, st) {
      AppLogger.error('Camera init unexpected error', e, st);
      if (mounted) _showNoCameraDialog();
    } finally {
      _isCameraInitializing = false;
    }
  }

  void _showNoCameraDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kamera topilmadi',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'Qurilmangizda kamera ishlamayapti. Anketa asosida davom etish mumkin.',
          style: GoogleFonts.nunito(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateFallback();
            },
            child: Text('Davom etish',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────

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
    _cancelStabilityTimers();
    final cam = _cam;
    if (cam == null) return;
    _cam = null;
    try { await cam.stopImageStream(); } catch (_) {}
    try { await cam.dispose(); } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _resumeCamera() async {
    if (_isDone || _cam != null || _isCameraInitializing) return;
    final result = await widget.permissionService.check();
    if (!mounted) return;
    if (result == CameraPermissionResult.granted) {
      await _initCamera();
    }
  }

  // ── Frame processing ──────────────────────────────────────────

  Future<void> _processFrame(CameraImage image) async {
    _frameSkip = (_frameSkip + 1) % 3;
    if (_frameSkip != 0) return;
    if (_isDetecting || _isDone) return;
    _isDetecting = true;
    try {
      _updateLuminance(image);

      final inputImage = _buildInputImage(image);
      if (inputImage == null || _fastDetector == null) return;

      final faces = await _fastDetector!.processImage(inputImage);
      if (!mounted || _isDone) return;

      final state = _evaluateState(faces, image);
      _faceStateNotifier.value = state;
      _captureEnabledNotifier.value = faces.isNotEmpty;

      if (state == _FaceState.ready) {
        _ensureStabilityTimer();
      } else {
        _cancelStabilityTimers();
      }
    } catch (_) {
    } finally {
      _isDetecting = false;
    }
  }

  _FaceState _evaluateState(List<Face> faces, CameraImage image) {
    if (_lightLevel < 0.18) return _FaceState.tooDark;
    if (faces.isEmpty) return _FaceState.waiting;
    if (faces.length > 1) return _FaceState.waiting;

    final face = faces.first;
    final refDim = math.min(image.width, image.height).toDouble();
    final faceRatio = face.boundingBox.width / refDim;

    if (faceRatio < 0.35) return _FaceState.tooFar;
    if (faceRatio > 0.80) return _FaceState.tooClose;

    final xOff =
        ((face.boundingBox.center.dx - image.width / 2) / image.width).abs();
    final yOff =
        ((face.boundingBox.center.dy - image.height / 2) / image.height).abs();
    if (xOff > 0.15 || yOff > 0.15) return _FaceState.offCenter;

    final eulerY = face.headEulerAngleY ?? 0.0;
    final eulerZ = face.headEulerAngleZ ?? 0.0;
    if (eulerY.abs() > 12 || eulerZ.abs() > 12) return _FaceState.notFrontal;

    final leftEye = face.leftEyeOpenProbability;
    final rightEye = face.rightEyeOpenProbability;
    if (leftEye != null && rightEye != null) {
      if (leftEye < 0.4 && rightEye < 0.4) return _FaceState.eyesClosed;
    }

    return _FaceState.ready;
  }

  void _ensureStabilityTimer() {
    if (_stabilityTimer != null) return;
    _stabilityTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_isDone || !mounted) return;
      _startCountdown();
    });
  }

  void _cancelStabilityTimers() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (_faceStateNotifier.value == _FaceState.countdown) {
      _faceStateNotifier.value = _FaceState.waiting;
    }
    _countdownNotifier.value = null;
  }

  void _startCountdown() {
    if (_isDone || !mounted) return;
    _faceStateNotifier.value = _FaceState.countdown;
    _countdownNotifier.value = 3;

    int count = 3;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 333), (t) {
      count--;
      if (count > 0) {
        _countdownNotifier.value = count;
      } else {
        t.cancel();
        _countdownTimer = null;
        _countdownNotifier.value = null;
        _captureNow();
      }
    });
  }

  // ── Capture ───────────────────────────────────────────────────

  Future<void> _captureNow() async {
    if (_isDone) return;
    _isDone = true;
    _timeoutTimer?.cancel();
    _cancelStabilityTimers();
    _faceStateNotifier.value = _FaceState.done;
    HapticFeedback.heavyImpact();

    final cam = _cam;
    if (cam == null) {
      _navigateFallback();
      return;
    }

    try { await cam.stopImageStream(); } catch (_) {}

    XFile? xfile;
    try {
      xfile = await cam.takePicture();
    } catch (e, st) {
      AppLogger.error('takePicture failed', e, st);
    }

    if (xfile == null) {
      _showCaptureErrorDialog();
      return;
    }

    await _validateAndNavigate(xfile.path);
  }

  Future<void> _validateAndNavigate(String path) async {
    FaceDetector? accurateDetector;
    try {
      accurateDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableClassification: true,
        ),
      );
      final inputImage = InputImage.fromFilePath(path);
      final faces = await accurateDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.length == 1) {
        final face = faces.first;
        final eulerY = face.headEulerAngleY ?? 0.0;
        final eulerZ = face.headEulerAngleZ ?? 0.0;
        if (eulerY.abs() <= 20 && eulerZ.abs() <= 20) {
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) _navigateToAnalysis(path);
          return;
        }
      }

      _showRetryDialog("Yuz aniq chiqmadi, qayta urinib ko'ring");
    } catch (e, st) {
      AppLogger.error('Final validation failed', e, st);
      if (mounted) _showRetryDialog("Tekshirishda xato, qayta urinib ko'ring");
    } finally {
      accurateDetector?.close();
    }
  }

  void _showCaptureErrorDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Suratga olib bo'lmadi",
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('Kamera xatosi yuz berdi.',
            style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); _resetCapture(); },
            child: Text('Qayta urinish',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); _navigateFallback(); },
            child: Text('Anketa bilan davom etish',
                style: GoogleFonts.nunito(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(String msg) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Surat mos kelmadi',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(msg,
            style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); _resetCapture(); },
            child: Text('Qayta urinish',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); _navigateFallback(); },
            child: Text('Anketa bilan davom etish',
                style: GoogleFonts.nunito(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetCapture() async {
    if (!mounted) return;
    _isDone = false;
    _frameSkip = 0;
    _faceStateNotifier.value = _FaceState.waiting;
    _captureEnabledNotifier.value = false;
    _countdownNotifier.value = null;

    final cam = _cam;
    if (cam != null && cam.value.isInitialized) {
      try {
        await cam.startImageStream(_processFrame);
        _startTimeout();
      } catch (_) {
        await _pauseCamera();
        await _initCamera();
      }
    } else {
      await _initCamera();
    }
  }

  // ── Timeout ───────────────────────────────────────────────────

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 40), () {
      if (_isDone || !mounted) return;
      _cancelStabilityTimers();
      _faceStateNotifier.value = _FaceState.timedOut;
      _showTimeoutDialog();
    });
  }

  void _showTimeoutDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Suratga olib bo'lmadi",
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          "Qayta urinasizmi yoki anketa bo'yicha davom etasizmi?",
          style: GoogleFonts.nunito(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetCapture();
            },
            child: Text('Qayta urinish',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateFallback();
            },
            child: Text('Anketa bilan davom etish',
                style: GoogleFonts.nunito(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────

  void _navigateToAnalysis(String imagePath) {
    if (!mounted) return;
    context.pushReplacement(
      '/analysis',
      extra: AnalysisArgs(quizAnswers: widget.quizAnswers, imagePath: imagePath),
    );
  }

  void _navigateFallback() {
    if (!mounted) return;
    context.pushReplacement(
      '/analysis',
      extra: AnalysisArgs(quizAnswers: widget.quizAnswers),
    );
  }

  void _goBack() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home', extra: 1);
    }
  }

  // ── Luminance ─────────────────────────────────────────────────

  void _updateLuminance(CameraImage image) {
    try {
      if (Platform.isAndroid && image.planes.isNotEmpty) {
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

  // ── InputImage (stream, NV21/BGRA for live guidance) ──────────

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

  InputImage? _buildInputImageAndroid(
      CameraImage image, InputImageRotation rotation) {
    if (image.planes.length < 3) return null;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int ySize = image.width * image.height;
    final nv21 = Uint8List(ySize + ySize ~/ 2);

    int nv21Idx = 0;
    for (int row = 0; row < image.height; row++) {
      nv21.setRange(nv21Idx, nv21Idx + image.width,
          yPlane.bytes, row * yPlane.bytesPerRow);
      nv21Idx += image.width;
    }

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

  // ── Dispose ───────────────────────────────────────────────────

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeoutTimer?.cancel();
    _stabilityTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseCtrl.dispose();
    _faceStateNotifier.dispose();
    _countdownNotifier.dispose();
    _captureEnabledNotifier.dispose();
    _fastDetector?.close();
    final cam = _cam;
    _cam = null;
    if (cam != null) {
      cam.stopImageStream().catchError((_) {}).whenComplete(cam.dispose);
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
          // Camera preview — only rebuilt when _cam changes
          RepaintBoundary(child: _buildCameraLayer()),

          // Oval mask + state-colored border — isolated repaint
          RepaintBoundary(
            child: ValueListenableBuilder<_FaceState>(
              valueListenable: _faceStateNotifier,
              builder: (_, state, _) => AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _ScanPainter(
                    state: state,
                    pulseValue: _pulseCtrl.value,
                  ),
                ),
              ),
            ),
          ),

          // Countdown number
          ValueListenableBuilder<int?>(
            valueListenable: _countdownNotifier,
            builder: (_, count, _) {
              if (count == null) return const SizedBox.shrink();
              return Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.nunito(
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 20),
                    ],
                  ),
                ),
              );
            },
          ),

          // Top bar — static, never rebuilt by animation ticks
          Positioned(
            top: top + 14,
            left: 20,
            right: 20,
            child: Row(
              children: [
                _CircleBtn(
                  onTap: _goBack,
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
                const Spacer(),
                _CircleBtn(
                  onTap: () => _showHelp(context),
                  child: const Icon(Icons.help_outline_rounded,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          // Bottom: status pill + manual capture button
          Positioned(
            bottom: bottom + 32,
            left: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<_FaceState>(
                  valueListenable: _faceStateNotifier,
                  builder: (_, state, _) => _buildStatus(state),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: _captureEnabledNotifier,
                  builder: (_, enabled, _) => GestureDetector(
                    onTap: enabled && !_isDone ? _captureNow : null,
                    child: AnimatedOpacity(
                      opacity: enabled ? 1.0 : 0.35,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.camera_alt_rounded,
                              color: Colors.black87, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) {
      return Container(color: Colors.black);
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cam.value.previewSize!.height,
          height: cam.value.previewSize!.width,
          child: CameraPreview(cam),
        ),
      ),
    );
  }

  Widget _buildStatus(_FaceState state) {
    return switch (state) {
      _FaceState.waiting => const _StatusPill(
          text: 'Yuzingizni ramka ichiga joylang',
          color: Colors.white,
        ),
      _FaceState.tooFar => const _StatusPill(
          text: 'Yaqinroq keling',
          icon: Icons.zoom_in_rounded,
          color: Colors.white,
        ),
      _FaceState.tooClose => const _StatusPill(
          text: 'Sal uzoqlashing',
          icon: Icons.zoom_out_rounded,
          color: Colors.white,
        ),
      _FaceState.offCenter => const _StatusPill(
          text: 'Yuzni markazga oling',
          icon: Icons.center_focus_strong_rounded,
          color: Colors.white,
        ),
      _FaceState.notFrontal => const _StatusPill(
          text: "To'g'ri qarang",
          icon: Icons.face_rounded,
          color: Colors.white,
        ),
      _FaceState.eyesClosed => const _StatusPill(
          text: "Ko'zingizni oching",
          icon: Icons.remove_red_eye_outlined,
          color: Color(0xFFFFC107),
        ),
      _FaceState.tooDark => const _StatusPill(
          text: "Yorug'roq joyga o'ting",
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFFFC107),
        ),
      _FaceState.ready => const _StatusPill(
          text: 'Qimirlamang...',
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF4CAF50),
        ),
      _FaceState.countdown => const _StatusPill(
          text: 'Suratga olinmoqda',
          color: Color(0xFF4CAF50),
        ),
      _FaceState.done => const _StatusPill(
          text: 'Tahlil qilinmoqda...',
          icon: Icons.check_circle_rounded,
          color: Color(0xFF4CAF50),
        ),
      _FaceState.timedOut => const _StatusPill(
          text: 'Vaqt tugadi',
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFFF8A35),
        ),
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
              "• Yuzingizni oval ichiga joylang\n"
              "• To'g'ri va frontal qarang\n"
              "• Ko'zingizni oching\n"
              "• Yaxshi yorug'lik bo'lsin\n"
              "• Avtomatik suratga olinadi yoki tugmani bosing",
              style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white54, height: 1.7),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.30)),
              ),
              child: Text(
                "Bu kosmetik tahlil bo'lib, tibbiy tashxis hisoblanmaydi. "
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color),
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
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ── Scan painter — oval cutout + state border ─────────────────

class _ScanPainter extends CustomPainter {
  final _FaceState state;
  final double pulseValue;

  const _ScanPainter({required this.state, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final ovalRx = size.width * 0.365;
    final ovalRy = size.height * 0.265;

    final ovalRect = Rect.fromCenter(
        center: Offset(cx, cy), width: ovalRx * 2, height: ovalRy * 2);

    // Dark overlay with oval cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.72));

    final isGood = state == _FaceState.ready ||
        state == _FaceState.countdown ||
        state == _FaceState.done;
    final isWarn =
        state == _FaceState.tooDark || state == _FaceState.eyesClosed;

    final borderColor = isGood
        ? const Color(0xFF4CAF50)
        : isWarn
            ? const Color(0xFFFFC107)
            : Colors.white;
    final borderAlpha =
        isGood ? 0.55 + pulseValue * 0.45 : 0.28 + pulseValue * 0.12;

    // Glow when ready/countdown
    if (isGood) {
      canvas.drawOval(
        ovalRect,
        Paint()
          ..color = const Color(0xFF4CAF50)
              .withValues(alpha: 0.12 + pulseValue * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, 14 + pulseValue * 8),
      );
    }

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor.withValues(alpha: borderAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.state != state || old.pulseValue != pulseValue;
}
