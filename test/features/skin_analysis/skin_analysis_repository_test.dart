import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/skin_analysis/data/skin_analysis_remote_data_source.dart';
import 'package:real_beauty_ai/features/skin_analysis/data/skin_analysis_repository_impl.dart';
import 'package:real_beauty_ai/features/skin_analysis/domain/skin_analysis_result.dart';

class _MockDs extends Mock implements SkinAnalysisRemoteDataSource {}

final _fakeData = CloudSkinData(
  concerns: {
    SkinConcern.acne: 30,
    SkinConcern.darkSpots: 10,
    SkinConcern.pores: 40,
    SkinConcern.wrinkles: 5,
    SkinConcern.darkCircles: 20,
    SkinConcern.eyeBags: 15,
    SkinConcern.blackheads: 25,
    SkinConcern.oiliness: 60,
  },
  overallScore: 72,
  detectedSkinType: 'oily',
  takenAt: DateTime(2026, 6, 24),
);

void main() {
  late _MockDs ds;
  late SkinAnalysisRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  setUp(() {
    ds = _MockDs();
    repo = SkinAnalysisRepositoryImpl(ds);
  });

  group('SkinAnalysisRepositoryImpl', () {
    test('data source success → returns CloudSkinData unchanged', () async {
      when(() => ds.analyze(any())).thenAnswer((_) async => _fakeData);

      final result = await repo.analyze(File('fake.jpg'));

      expect(result.detectedSkinType, 'oily');
      expect(result.overallScore, 72);
      expect(result.concerns?[SkinConcern.acne], 30);
      expect(result.concerns?[SkinConcern.pores], 40);
    });

    test('data source throws SkinAnalysisException → rethrows', () {
      when(() => ds.analyze(any()))
          .thenThrow(const SkinAnalysisException('api_not_ok'));

      expect(
        () => repo.analyze(File('fake.jpg')),
        throwsA(
          isA<SkinAnalysisException>()
              .having((e) => e.reason, 'reason', 'api_not_ok'),
        ),
      );
    });

    test('data source throws generic Exception → wraps in SkinAnalysisException',
        () {
      when(() => ds.analyze(any())).thenThrow(Exception('network'));

      expect(
        () => repo.analyze(File('fake.jpg')),
        throwsA(isA<SkinAnalysisException>()),
      );
    });

    test('data source throws StateError → wraps in SkinAnalysisException', () {
      when(() => ds.analyze(any())).thenThrow(StateError('bad state'));

      expect(
        () => repo.analyze(File('fake.jpg')),
        throwsA(isA<SkinAnalysisException>()),
      );
    });
  });

  group('SkinAnalysisException', () {
    test('toString includes reason', () {
      const e = SkinAnalysisException('timeout');
      expect(e.toString(), contains('timeout'));
    });
  });

  group('CloudSkinData concerns', () {
    test('all 8 SkinConcern values present in fake data', () {
      final concerns = _fakeData.concerns!;
      for (final concern in SkinConcern.values) {
        expect(concerns.containsKey(concern), isTrue,
            reason: '${concern.name} missing');
      }
    });

    test('overallScore within 0-100', () {
      expect(_fakeData.overallScore, inInclusiveRange(0, 100));
    });
  });
}
