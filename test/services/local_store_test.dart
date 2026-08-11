import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _profileJson =
    '{"skinType":"Yog\'li","skinTypeCode":"O","baseRecommendation":"test",'
    '"additionalBlocks":[]}';

void main() {
  group('clearAllUserData', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'skin_profile_v1': _profileJson,
        'scan_history_v1': '[]',
        'routine:2026-08-04': '{"am_0":true}',
        'routine:2026-08-05': '{"pm_1":true}',
        'privacy_accepted_v1': true,
      });
      await LocalStore.instance.init();
    });

    test('wipes every account-scoped key', () async {
      await LocalStore.instance.clearAllUserData();

      final store = LocalStore.instance;
      expect(store.hasSkinProfile, isFalse);
      expect(store.getAnalysisHistory(), isEmpty);
      expect(store.getRoutine('2026-08-04'), isEmpty);
      expect(store.getRoutine('2026-08-05'), isEmpty);
    });

    test('keeps device-level privacy consent', () async {
      await LocalStore.instance.clearAllUserData();

      expect(LocalStore.instance.privacyAccepted, isTrue);
    });
  });
}
