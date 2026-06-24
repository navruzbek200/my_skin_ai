import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:real_beauty_ai/features/skin_analysis/domain/skin_analysis_result.dart';

abstract class SkinAnalysisRemoteDataSource {
  Future<CloudSkinData> analyze(File image);
}

class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  late final HttpsCallable _callable;

  SkinAnalysisRemoteDataSourceImpl() {
    _callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(
          'analyzeSkin',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 25)),
        );
  }

  @override
  Future<CloudSkinData> analyze(File image) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minWidth: 1080,
      minHeight: 1080,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) {
      throw const SkinAnalysisException('image_compression_failed');
    }

    final base64Str = base64Encode(compressed);
    final response =
        await _callable.call<Map<Object?, Object?>>({'imageBase64': base64Str});
    final data = Map<String, dynamic>.from(response.data);

    return _parseContract(data);
  }

  CloudSkinData _parseContract(Map<String, dynamic> data) {
    if (data['ok'] != true) {
      throw SkinAnalysisException(
        data['reason'] as String? ?? 'api_returned_not_ok',
      );
    }

    final rawConcerns = data['concerns'];
    final Map<SkinConcern, int>? concerns = rawConcerns == null
        ? null
        : _parseConcerns(Map<String, dynamic>.from(rawConcerns as Map));

    return CloudSkinData(
      concerns: concerns,
      overallScore: _asInt(data['overallScore']),
      detectedSkinType: data['skinType'] as String? ?? 'normal',
      takenAt: DateTime.now(),
    );
  }

  Map<SkinConcern, int> _parseConcerns(Map<String, dynamic> raw) => {
        SkinConcern.acne: _asInt(raw['acne']),
        SkinConcern.darkSpots: _asInt(raw['darkSpots']),
        SkinConcern.pores: _asInt(raw['pores']),
        SkinConcern.wrinkles: _asInt(raw['wrinkles']),
        SkinConcern.darkCircles: _asInt(raw['darkCircles']),
        SkinConcern.eyeBags: _asInt(raw['eyeBags']),
        SkinConcern.blackheads: _asInt(raw['blackheads']),
        SkinConcern.oiliness: _asInt(raw['oiliness']),
      };

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return 0;
  }
}
