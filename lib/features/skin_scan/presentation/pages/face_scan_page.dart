import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/permissions/camera_permission_service.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/skin_scan/domain/nv21_converter.dart';

enum _ScanPhase { idle, scanning, analyzing, complete }

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

  // ── Camera ────────────────────────────────────────────────────
  CameraController? _cam;
  bool _isCameraInitializing = false;
  FaceDetector? _detector;
  bool _isDetecting = false;
  bool _isDone = false;
  bool _dialogVisible = false;
  int _lastRotationDeg = 0;
  double _lightLevel = 0.5;
  int _frameSkip = 0;
  bool _hasFace = false;
  Timer? _scanTickTimer;

  // ── State ─────────────────────────────────────────────────────
  _ScanPhase _phase = _ScanPhase.idle;
  // Seeded null and filled from didChangeDependencies: the first guidance
  // sentence is a localised string, and localisations are not reachable from a
  // field initialiser.
  final _guidanceNotifier = ValueNotifier<String?>(null);
  final _analysisTextNotifier = ValueNotifier<String>('');

  List<String> get _analysisPhrases => [
        context.l10n.faceScanStep1,
        context.l10n.faceScanStep2,
        context.l10n.faceScanStep3,
        context.l10n.faceScanStep4,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only while the scanner is still waiting for a face: overwriting a live
    // instruction ("come closer") on a language change would be a jarring
    // reset in the middle of a scan.
    _guidanceNotifier.value ??= context.l10n.faceScanAlign;
  }

  // ── Timers ────────────────────────────────────────────────────
  Timer? _stabilityTimer;
  Timer? _timeoutTimer;
  Timer? _analysisTimer;

  // ── Rotation segments (Face ID style) ────────────────────────
  static const _kSegments = 60;
  final _segFilled = List<bool>.filled(60, false);
  int _filledCount = 0;

  // ── Animation controllers (all in parent — no child ticker widgets) ──
  late final AnimationController _ambientCtrl; // breathing glow, repeat
  late final AnimationController _morphCtrl;   // face-detected glow
  late final AnimationController _scanCtrl;    // segment fill progress
  late final AnimationController _fadeCtrl;    // analysis overlay fade-in
  late final AnimationController _dotsCtrl;    // analysis dots loop

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _detector = FaceDetector(
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
    if (_dialogVisible || !mounted) return;
    _dialogVisible = true;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PopScope(
        canPop: false,
        child: _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.faceScanPermissionTitle,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              context.l10n.faceScanPermissionBody,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.white60, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: context.l10n.commonAllow,
              onTap: () {
                Navigator.of(ctx).pop();
                _initCameraWithPermission();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _navigateToAnalysis();
              },
              child: Text(context.l10n.faceScanContinueWithQuiz,
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.white30)),
            ),
          ],
        ),
        ),
      ),
    ).whenComplete(() => _dialogVisible = false);
  }

  void _showSettingsDialog() {
    if (_dialogVisible || !mounted) return;
    _dialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
        backgroundColor: const Color(0xFF0D0D1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.faceScanPermissionDeniedTitle,
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          context.l10n.faceScanPermissionDeniedBody,
          style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToAnalysis();
            },
            child: Text(context.l10n.commonSkip,
                style: GoogleFonts.nunito(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.permissionService.openSettings();
            },
            child: Text(context.l10n.commonSettingsApp,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF9D7FEA), fontWeight: FontWeight.w700)),
          ),
        ],
        ),
      ),
    ).whenComplete(() => _dialogVisible = false);
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
      final target = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        target,
        ResolutionPreset.medium,
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
      AppLogger.error('Camera init error', e, st);
      if (mounted) _showNoCameraDialog();
    } finally {
      _isCameraInitializing = false;
    }
  }

  void _showNoCameraDialog() {
    if (_dialogVisible || !mounted) return;
    _dialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
        backgroundColor: const Color(0xFF0D0D1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.faceScanNoCameraTitle,
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          context.l10n.faceScanNoCameraBody,
          style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToAnalysis();
            },
            child: Text(context.l10n.commonContinue,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF9D7FEA), fontWeight: FontWeight.w700)),
          ),
        ],
        ),
      ),
    ).whenComplete(() => _dialogVisible = false);
  }

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDone) return;
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
    _cancelStabilityTimer();
    _timeoutTimer?.cancel();
    final cam = _cam;
    if (cam == null) return;
    _cam = null;
    try {
      await cam.stopImageStream();
    } catch (_) {}
    try {
      await cam.dispose();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _resumeCamera() async {
    if (_isDone || _cam != null || _isCameraInitializing) return;
    final result = await widget.permissionService.check();
    if (!mounted) return;
    if (result == CameraPermissionResult.granted) {
      if (_dialogVisible) {
        // User granted permission from system settings — close the stale
        // settings dialog/rationale sheet before starting the camera.
        Navigator.of(context, rootNavigator: true).pop();
      }
      await _initCamera();
    } else if (result == CameraPermissionResult.permanentlyDenied ||
        result == CameraPermissionResult.restricted) {
      _showSettingsDialog();
    } else {
      _showRationaleSheet();
    }
  }

  // ── Frame processing ──────────────────────────────────────────

  Future<void> _processFrame(CameraImage image) async {
    _frameSkip = (_frameSkip + 1) % 2;
    if (_frameSkip != 0) return;
    if (_isDetecting || _isDone || _dialogVisible) return;
    if (_phase == _ScanPhase.analyzing || _phase == _ScanPhase.complete) return;

    _isDetecting = true;
    try {
      _updateLuminance(image);
      final inputImage = _buildInputImage(image);
      if (inputImage == null || _detector == null) return;

      final faces = await _detector?.processImage(inputImage);
      if (faces == null || !mounted || _isDone) return;

      final guidance = _evaluateGuidance(faces, image);

      if (_phase == _ScanPhase.scanning) {
        _hasFace = guidance == null;
        _guidanceNotifier.value = guidance ?? context.l10n.faceScanHold;
        return;
      }
      _guidanceNotifier.value = guidance;

      // Idle phase
      if (guidance == null) {
        _morphCtrl.forward();
        _ensureStabilityTimer();
      } else {
        _morphCtrl.reverse();
        _cancelStabilityTimer();
      }
    } catch (e, st) {
      AppLogger.error('Frame error', e, st);
    } finally {
      _isDetecting = false;
    }
  }

  String? _evaluateGuidance(List<Face> faces, CameraImage image) {
    if (_lightLevel < 0.12) return context.l10n.faceScanTooDark;
    if (faces.isEmpty) return context.l10n.faceScanAlign;
    if (faces.length > 1) return context.l10n.faceScanOneFace;
    final face = faces.first;
    // ML Kit returns coordinates in the upright (rotated) frame — swap
    // buffer dimensions for 90/270 rotations before comparing.
    final swapDims = _lastRotationDeg == 90 || _lastRotationDeg == 270;
    final iw = (swapDims ? image.height : image.width).toDouble();
    final ih = (swapDims ? image.width : image.height).toDouble();
    final refDim = math.min(iw, ih);
    final faceRatio = face.boundingBox.width / refDim;
    if (faceRatio < 0.18) return context.l10n.faceScanCloser;
    if (faceRatio > 0.90) return context.l10n.faceScanFurther;
    final xOff = ((face.boundingBox.center.dx - iw / 2) / iw).abs();
    final yOff = ((face.boundingBox.center.dy - ih / 2) / ih).abs();
    if (xOff > 0.25 || yOff > 0.25) return context.l10n.faceScanCenter;
    // Skip euler/eye checks during scanning — user is actively rotating head.
    if (_phase != _ScanPhase.scanning) {
      final eulerY = face.headEulerAngleY ?? 0.0;
      final eulerZ = face.headEulerAngleZ ?? 0.0;
      if (eulerY.abs() > 30 || eulerZ.abs() > 25) return context.l10n.faceScanLookStraight;
      final lEye = face.leftEyeOpenProbability;
      final rEye = face.rightEyeOpenProbability;
      if (lEye != null && rEye != null && lEye < 0.2 && rEye < 0.2) {
        return context.l10n.faceScanOpenEyes;
      }
    }
    return null;
  }

  // ── Stability & scan ──────────────────────────────────────────

  void _ensureStabilityTimer() {
    if (_stabilityTimer != null) return;
    _stabilityTimer = Timer(const Duration(milliseconds: 900), () {
      _stabilityTimer = null;
      if (_isDone || !mounted || _dialogVisible) return;
      if (_guidanceNotifier.value != null) return;
      if (_morphCtrl.value < 0.85) return;
      _startScan();
    });
  }

  void _cancelStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  void _startScan() {
    if (_isDone || _dialogVisible || _phase != _ScanPhase.idle || !mounted) {
      return;
    }
    HapticFeedback.mediumImpact();
    _segFilled.fillRange(0, _kSegments, false);
    _filledCount = 0;
    _scanCtrl.value = 0;
    _hasFace = true;
    setState(() => _phase = _ScanPhase.scanning);
    _guidanceNotifier.value = context.l10n.faceScanHold;
    _startScanTicker();
  }

  void _startScanTicker() {
    _scanTickTimer?.cancel();
    _scanTickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isDone || !mounted || _dialogVisible) return;
      if (_phase != _ScanPhase.scanning || !_hasFace) return;
      for (int i = 0; i < _kSegments; i++) {
        if (!_segFilled[i]) {
          _segFilled[i] = true;
          _filledCount++;
          final progress = _filledCount / _kSegments;
          _scanCtrl.animateTo(progress,
              duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
          if (progress >= 0.75 && !_isDone) _startAnalysis();
          break;
        }
      }
    });
  }

  void _stopScanTicker() {
    _scanTickTimer?.cancel();
    _scanTickTimer = null;
  }

  // ── Analysis ──────────────────────────────────────────────────

  void _startAnalysis() {
    if (_isDone || !mounted) return;
    _timeoutTimer?.cancel();
    _stopScanTicker();
    setState(() => _phase = _ScanPhase.analyzing);
    HapticFeedback.heavyImpact();
    _fadeCtrl.forward();
    _dotsCtrl.repeat();
    _analysisTextNotifier.value = _analysisPhrases[0];
    int idx = 0;
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted || _isDone) {
        t.cancel();
        return;
      }
      idx++;
      if (idx < _analysisPhrases.length) {
        _analysisTextNotifier.value = _analysisPhrases[idx];
      } else {
        t.cancel();
        _completeAnalysis();
      }
    });
  }

  void _completeAnalysis() {
    if (_isDone || !mounted) return;
    _isDone = true;
    _timeoutTimer?.cancel();
    setState(() => _phase = _ScanPhase.complete);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _navigateToAnalysis();
    });
  }

  // ── Timeout ───────────────────────────────────────────────────

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 50), () {
      if (_isDone || !mounted) return;
      _showTimeoutDialog();
    });
  }

  void _showTimeoutDialog() {
    if (_dialogVisible || !mounted) return;
    _dialogVisible = true;
    _cancelStabilityTimer();
    _stopScanTicker();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
        backgroundColor: const Color(0xFF0D0D1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.faceScanTimeoutTitle,
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          context.l10n.faceScanTimeoutBody,
          style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _reset();
            },
            child: Text(context.l10n.commonRetryShort,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF9D7FEA), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToAnalysis();
            },
            child: Text(context.l10n.commonContinue,
                style: GoogleFonts.nunito(color: Colors.white30)),
          ),
        ],
        ),
      ),
    ).whenComplete(() => _dialogVisible = false);
  }

  Future<void> _reset() async {
    if (!mounted) return;
    _isDone = false;
    _frameSkip = 0;
    _lightLevel = 0.5;
    _morphCtrl.value = 0;
    _guidanceNotifier.value = context.l10n.faceScanAlign;
    _segFilled.fillRange(0, _kSegments, false);
    _filledCount = 0;
    _scanCtrl.value = 0;
    _fadeCtrl.value = 0;
    _dotsCtrl.stop();
    _analysisTimer?.cancel();
    _cancelStabilityTimer();
    _stopScanTicker();
    _hasFace = false;
    if (!_ambientCtrl.isAnimating) _ambientCtrl.repeat(reverse: true);
    setState(() => _phase = _ScanPhase.idle);

    final cam = _cam;
    if (cam != null && cam.value.isInitialized) {
      try {
        if (!cam.value.isStreamingImages) {
          await cam.startImageStream(_processFrame);
        }
        _startTimeout();
      } catch (_) {
        await _pauseCamera();
        await _initCamera();
      }
    } else {
      await _initCamera();
    }
  }

  // ── Navigation ────────────────────────────────────────────────

  void _stopAnims() {
    _ambientCtrl.stop();
    _morphCtrl.stop();
    _scanCtrl.stop();
    _fadeCtrl.stop();
    _dotsCtrl.stop();
  }

  void _navigateToAnalysis() {
    if (!mounted) return;
    _isDone = true; // stop frame processing during the route transition
    _stopAnims();
    // Camera teardown happens in dispose() when the route is removed —
    // disposing here would leave CameraPreview painting a dead controller
    // (red error screen in debug builds).
    // Defer to post-frame: ensures any pending rebuild (setState) fully commits
    // before pushReplacement triggers route deactivation. Prevents the
    // _EffectiveTickerMode InheritedElement unmounting while AnimatedSwitcher
    // dependents are still registered (_dependents.isEmpty assertion).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacement('/analysis',
          extra: AnalysisArgs(quizAnswers: widget.quizAnswers));
    });
  }


  // ── Luminance ─────────────────────────────────────────────────

  void _updateLuminance(CameraImage image) {
    try {
      if (Platform.isAndroid && image.planes.isNotEmpty) {
        final yBytes = image.planes[0].bytes;
        final stride = image.planes[0].bytesPerRow;
        int sum = 0, count = 0;
        for (int row = 0; row < image.height; row += 8) {
          for (int col = 0; col < image.width; col += 8) {
            final idx = row * stride + col;
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

  // ── InputImage ────────────────────────────────────────────────

  InputImage? _buildInputImage(CameraImage image) {
    final cam = _cam;
    if (cam == null || image.planes.isEmpty) return null;
    final camera = cam.description;
    // Rotation per the official ML Kit sample: iOS uses sensorOrientation
    // directly; on Android the device-orientation compensation term is always
    // 0 because the app is portrait-locked, so front and back cameras both
    // reduce to sensorOrientation as well.
    final int rawRotation = camera.sensorOrientation % 360;
    _lastRotationDeg = rawRotation;
    final rotation = InputImageRotationValue.fromRawValue(rawRotation) ??
        InputImageRotation.rotation0deg;
    if (Platform.isAndroid) return _buildInputImageAndroid(image, rotation);
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
    // The repacking itself lives in a pure function so it can be tested
    // against the plane layouts real phones produce; see nv21_converter.dart.
    final nv21 = yuv420ToNv21(
      width: image.width,
      height: image.height,
      yBytes: yPlane.bytes,
      uBytes: uPlane.bytes,
      vBytes: vPlane.bytes,
      yRowStride: yPlane.bytesPerRow,
      uRowStride: uPlane.bytesPerRow,
      vRowStride: vPlane.bytesPerRow,
      uPixelStride: uPlane.bytesPerPixel ?? 1,
      vPixelStride: vPlane.bytesPerPixel ?? 1,
    );
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
    _isDone = true;
    WidgetsBinding.instance.removeObserver(this);
    _timeoutTimer?.cancel();
    _stabilityTimer?.cancel();
    _analysisTimer?.cancel();
    _scanTickTimer?.cancel();
    _ambientCtrl.stop();
    _morphCtrl.stop();
    _scanCtrl.stop();
    _fadeCtrl.stop();
    _dotsCtrl.stop();
    _ambientCtrl.dispose();
    _morphCtrl.dispose();
    _scanCtrl.dispose();
    _fadeCtrl.dispose();
    _dotsCtrl.dispose();
    _guidanceNotifier.dispose();
    _analysisTextNotifier.dispose();
    _detector?.close();
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
    final mq = MediaQuery.of(context);
    final top = mq.padding.top;
    final bottom = mq.padding.bottom;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera feed
          RepaintBoundary(child: _buildCameraPreview()),

          // 2. Scan overlay (CustomPainter)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_ambientCtrl, _morphCtrl, _scanCtrl]),
              builder: (_, _) => CustomPaint(
                painter: _ScanPainter(
                  phase: _phase,
                  ambient: _ambientCtrl.value,
                  morphProgress: _morphCtrl.value,
                  segments: _segFilled,
                  filledCount: _filledCount,
                ),
              ),
            ),
          ),

          // 3. Analysis overlay — inlined, uses parent controllers (no child tickers)
          if (_phase == _ScanPhase.analyzing || _phase == _ScanPhase.complete)
            FadeTransition(
              opacity: _fadeCtrl,
              child: _buildAnalysisOverlay(h),
            ),

          // 4. Guidance badge — no AnimatedSwitcher (avoids TickerMode dependency)
          if (_phase == _ScanPhase.idle || _phase == _ScanPhase.scanning)
            Positioned(
              bottom: bottom + 60,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _guidanceNotifier,
                  builder: (_, text, _) => AnimatedOpacity(
                    opacity: text != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: _GuidanceBadge(text: text ?? ''),
                  ),
                ),
              ),
            ),

          // 5. Scan progress badge — visible only while scanning
          if (_phase == _ScanPhase.scanning)
            Positioned(
              top: top + 64,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _scanCtrl,
                builder: (_, _) => Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${(_filledCount / _kSegments * 100).round()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4ADE80),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 6. Top bar — fades during analysis so it doesn't overlap overlay
          Positioned(
            top: top + 14,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: (_phase == _ScanPhase.analyzing ||
                      _phase == _ScanPhase.complete)
                  ? 0.0
                  : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Spacer(),
                  _GlassIconButton(
                      icon: Icons.help_outline_rounded,
                      onTap: () => _showHelpSheet(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisOverlay(double h) {
    // Oval bottom: cy + ry = h*0.45 + h*0.37 = h*0.82
    final textTop = h * 0.82 + 32;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black.withValues(alpha: 0.35)),
        Positioned(
          top: textTop,
          left: 32,
          right: 32,
          child: Column(
            children: [
              Text(
                context.l10n.faceScanPreparingResult,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<String>(
                valueListenable: _analysisTextNotifier,
                builder: (_, text, _) => Text(
                  text,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Dots — driven by parent _dotsCtrl, no child StatefulWidget
              AnimatedBuilder(
                animation: _dotsCtrl,
                builder: (_, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final p = (_dotsCtrl.value * 3 - i).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9D7FEA).withValues(
                            alpha: math.sin(p * math.pi).clamp(0.2, 1.0)),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraLoadingView() {
    return Container(
      color: Colors.black,
      child: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (_, _) {
          final pulse = 0.25 + _ambientCtrl.value * 0.45;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9D7FEA).withValues(alpha: pulse),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_front_outlined,
                    color: const Color(0xFF9D7FEA).withValues(alpha: pulse),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.faceScanPreparingCamera,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: pulse * 0.7),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) {
      return _buildCameraLoadingView();
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

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faceScanHowTitle,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              context.l10n.faceScanHowBody,
              style: GoogleFonts.nunito(
                  fontSize: 14, color: Colors.white54, height: 1.7),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9D7FEA).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF9D7FEA).withValues(alpha: 0.25)),
              ),
              child: Text(
                context.l10n.faceScanDisclaimer,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: const Color(0xFF9D7FEA), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Scan Painter
// ─────────────────────────────────────────────────────────────

class _ScanPainter extends CustomPainter {
  final _ScanPhase phase;
  final double ambient;
  final double morphProgress;
  final List<bool> segments;
  final int filledCount;

  const _ScanPainter({
    required this.phase,
    required this.ambient,
    required this.morphProgress,
    required this.segments,
    required this.filledCount,
  });

  static const _purple = Color(0xFF9D7FEA);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final rx = size.width * 0.44;
    final ry = size.height * 0.37;
    final ovalRect =
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);

    // Vignette
    final vRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      vRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.05),
          radius: 0.9,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
        ).createShader(vRect),
    );

    // Dark overlay with oval cutout
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(ovalRect)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );

    // Purple glow when face detected
    if (morphProgress > 0.05) {
      canvas.drawOval(
        ovalRect.inflate(1),
        Paint()
          ..color =
              _purple.withValues(alpha: morphProgress * (0.10 + ambient * 0.08))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Oval border
    final isScanning = phase == _ScanPhase.scanning;
    final borderA = isScanning
        ? 0.35 + ambient * 0.15
        : (0.10 + morphProgress * 0.25 + ambient * 0.06).clamp(0.0, 1.0);
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = Colors.white.withValues(alpha: borderA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    if (isScanning || phase == _ScanPhase.analyzing) {
      _drawWireMesh(canvas, cx, cy, rx, ry);
      _drawSegmentRing(canvas, cx, cy, rx, ry);
    }
  }

  void _drawWireMesh(
      Canvas canvas, double cx, double cy, double rx, double ry) {
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCenter(
          center: Offset(cx, cy), width: rx * 2, height: ry * 2)));

    final paint = Paint()
      ..color = Colors.white
          .withValues(alpha: (0.055 + ambient * 0.035).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i < 13; i++) {
      final t = i / 13;
      final y = (cy - ry) + ry * 2 * t;
      final ny = (y - cy) / ry;
      final hw = rx * math.sqrt(math.max(0.0, 1 - ny * ny));
      final bow = ny.abs() > 0.5 ? -5.0 : 7.0;
      canvas.drawPath(
        Path()
          ..moveTo(cx - hw, y)
          ..quadraticBezierTo(cx, y + bow * (1 - ny.abs()), cx + hw, y),
        paint,
      );
    }

    for (int i = 1; i < 8; i++) {
      final t = i / 8;
      final x = (cx - rx) + rx * 2 * t;
      final nx = (x - cx) / rx;
      final hh = ry * math.sqrt(math.max(0.0, 1 - nx * nx));
      final bow = nx.abs() > 0.5 ? -3.0 : 4.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, cy - hh)
          ..quadraticBezierTo(x + bow * (1 - nx.abs()), cy, x, cy + hh),
        paint,
      );
    }

    canvas.restore();
  }

  void _drawSegmentRing(
      Canvas canvas, double cx, double cy, double rx, double ry) {
    final n = segments.length;
    const innerS = 1.038;
    const outerS = 1.095;

    final filledPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt;

    final emptyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.butt
      ..color = Colors.white.withValues(alpha: 0.22);

    for (int i = 0; i < n; i++) {
      final theta = (i / n) * 2 * math.pi - math.pi / 2;
      final c = math.cos(theta);
      final s = math.sin(theta);
      canvas.drawLine(
        Offset(cx + rx * innerS * c, cy + ry * innerS * s),
        Offset(cx + rx * outerS * c, cy + ry * outerS * s),
        segments[i]
            ? (filledPaint
              ..color = const Color(0xFF4ADE80)
                  .withValues(alpha: 0.85 + ambient * 0.15))
            : emptyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.phase != phase ||
      old.ambient != ambient ||
      old.morphProgress != morphProgress ||
      old.filledCount != filledCount;
}

// ─────────────────────────────────────────────────────────────
// Reusable UI components
// ─────────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.10),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.90), size: 17.6),
      ),
    );
  }
}

class _GuidanceBadge extends StatelessWidget {
  final String text;
  const _GuidanceBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.90),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9D7FEA),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}
