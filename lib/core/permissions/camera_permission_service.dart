import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionResult { granted, denied, permanentlyDenied, restricted }

class CameraPermissionService {
  const CameraPermissionService();

  /// Returns current status without triggering the OS dialog.
  Future<CameraPermissionResult> check() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return CameraPermissionResult.granted;
    if (status.isRestricted) return CameraPermissionResult.restricted;
    if (status.isPermanentlyDenied) return CameraPermissionResult.permanentlyDenied;
    return CameraPermissionResult.denied;
  }

  /// Triggers the OS permission dialog (if not already granted/denied permanently).
  /// On iOS: after first denial the OS won't show the dialog again — returns permanentlyDenied.
  /// On Android: returns denied for soft-denial, permanentlyDenied for "don't ask again".
  Future<CameraPermissionResult> ensure() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return CameraPermissionResult.granted;
    if (status.isRestricted) return CameraPermissionResult.restricted;
    if (status.isPermanentlyDenied) return CameraPermissionResult.permanentlyDenied;

    final result = await Permission.camera.request();
    return switch (result) {
      PermissionStatus.granted || PermissionStatus.limited =>
        CameraPermissionResult.granted,
      PermissionStatus.permanentlyDenied =>
        CameraPermissionResult.permanentlyDenied,
      PermissionStatus.restricted => CameraPermissionResult.restricted,
      // On iOS a denial after the first native prompt is effectively permanent.
      // On Android this is a soft denial — caller decides whether to retry.
      _ => CameraPermissionResult.denied,
    };
  }

  Future<bool> openSettings() => openAppSettings();
}
