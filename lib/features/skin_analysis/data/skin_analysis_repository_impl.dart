import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/skin_analysis/domain/skin_analysis_repository.dart';
import 'skin_analysis_remote_data_source.dart';

class SkinAnalysisRepositoryImpl implements SkinAnalysisRepository {
  final SkinAnalysisRemoteDataSource _ds;

  const SkinAnalysisRepositoryImpl(this._ds);

  @override
  Future<CloudSkinData> analyze(File image) async {
    try {
      return await _ds.analyze(image);
    } on SkinAnalysisException {
      rethrow;
    } on FirebaseFunctionsException catch (e, st) {
      AppLogger.error('SkinAnalysis cloud function error', e, st);
      throw SkinAnalysisException('cloud_error:${e.code}');
    } catch (e, st) {
      AppLogger.error('SkinAnalysis unexpected error', e, st);
      throw SkinAnalysisException('unexpected:$e');
    }
  }
}
