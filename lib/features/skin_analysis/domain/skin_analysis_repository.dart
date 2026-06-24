import 'dart:io';
import 'skin_analysis_result.dart';

export 'skin_analysis_result.dart';

/// Throws [SkinAnalysisException] on any failure.
abstract class SkinAnalysisRepository {
  Future<CloudSkinData> analyze(File image);
}
