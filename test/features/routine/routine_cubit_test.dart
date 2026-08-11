import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/features/routine/presentation/bloc/routine_cubit.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oily skin, one blackhead concern — enough for the engine to produce its
/// fixed 4 + 5 shape without wandering into the sensitive-skin branch.
const _profileJson =
    '{"skinType":"Yog\'li","skinTypeCode":"O","baseRecommendation":"test",'
    '"additionalBlocks":[{"code":"Bh","title":"t","text":"t"}]}';

/// A Tuesday, so the weekday-dependent steps (active night) are pinned.
final _tuesday = DateTime(2026, 8, 11, 9);

Future<void> _setPrefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  await LocalStore.instance.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('load', () {
    test('no skin profile → RoutineNoProfile', () async {
      await _setPrefs({});
      final cubit = RoutineCubit(clock: () => _tuesday);

      await cubit.load();

      expect(cubit.state, isA<RoutineNoProfile>());
      await cubit.close();
    });

    test('the whole plan lands in a single emit', () async {
      await _setPrefs({'skin_profile_v1': _profileJson});
      final cubit = RoutineCubit(clock: () => _tuesday);

      final states = <RoutineState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.load();
      // The cubit's stream is an async broadcast: the last emit needs one more
      // turn of the loop before a listener sees it.
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.length, 1, reason: 'nothing is loaded off-device');
      expect((states.single as RoutineReady).total, 9);
      await cubit.close();
    });

    test('previously ticked steps come back from storage', () async {
      final day = LocalStore.dateKey(_tuesday);
      await _setPrefs({
        'skin_profile_v1': _profileJson,
        'routine:$day': '{"am_spf":true,"pm_toner":true}',
      });
      final cubit = RoutineCubit(clock: () => _tuesday);

      await cubit.load();

      final state = cubit.state as RoutineReady;
      expect(state.doneCount, 2);
      expect(state.progress, closeTo(2 / 9, 0.001));
      await cubit.close();
    });
  });

  group('toggle', () {
    late RoutineCubit cubit;

    setUp(() async {
      await _setPrefs({'skin_profile_v1': _profileJson});
      cubit = RoutineCubit(clock: () => _tuesday);
      await cubit.load();
    });

    tearDown(() => cubit.close());

    test('flips a step and writes it through', () async {
      await cubit.toggle('am_toner');

      expect((cubit.state as RoutineReady).doneCount, 1);
      expect(
        LocalStore.instance.getRoutine(
          LocalStore.dateKey(_tuesday),
        )['am_toner'],
        isTrue,
      );
    });

    test('flips back', () async {
      await cubit.toggle('am_toner');
      await cubit.toggle('am_toner');

      expect((cubit.state as RoutineReady).doneCount, 0);
      expect(
        LocalStore.instance.getRoutine(
          LocalStore.dateKey(_tuesday),
        )['am_toner'],
        isFalse,
      );
    });

    test('an unknown id changes nothing', () async {
      await cubit.toggle('not_a_step');

      expect((cubit.state as RoutineReady).doneCount, 0);
    });

    test('7 of 9 clears the streak threshold, 6 does not', () async {
      const ids = [
        'am_cleanse',
        'am_toner',
        'am_serum',
        'am_spf',
        'pm_cleanse',
        'pm_toner',
      ];
      for (final id in ids) {
        await cubit.toggle(id);
      }
      final day = LocalStore.dateKey(_tuesday);
      expect((cubit.state as RoutineReady).streaks[day], isFalse);

      await cubit.toggle('pm_treatment');
      expect((cubit.state as RoutineReady).streaks[day], isTrue);
    });
  });

  group('day rollover', () {
    test('refreshIfDayChanged rebuilds once the date moves on', () async {
      await _setPrefs({'skin_profile_v1': _profileJson});
      var now = _tuesday;
      final cubit = RoutineCubit(clock: () => now);
      await cubit.load();
      await cubit.toggle('am_spf');
      expect((cubit.state as RoutineReady).doneCount, 1);

      now = _tuesday.add(const Duration(days: 1));
      await cubit.refreshIfDayChanged();

      final state = cubit.state as RoutineReady;
      expect(state.day, LocalStore.dateKey(now));
      expect(state.doneCount, 0, reason: "yesterday's ticks stay on yesterday");
      await cubit.close();
    });

    test(
      'a tap after midnight rebuilds instead of writing to yesterday',
      () async {
        await _setPrefs({'skin_profile_v1': _profileJson});
        var now = _tuesday;
        final cubit = RoutineCubit(clock: () => now);
        await cubit.load();

        now = _tuesday.add(const Duration(days: 1));
        await cubit.toggle('am_spf');

        final state = cubit.state as RoutineReady;
        expect(state.day, LocalStore.dateKey(now));
        expect(state.doneCount, 0);
        expect(
          LocalStore.instance.getRoutine(
            LocalStore.dateKey(_tuesday),
          )['am_spf'],
          isNull,
          reason: 'nothing was filed under yesterday',
        );
        await cubit.close();
      },
    );
  });

  group('currentStreak', () {
    test('counts consecutive qualifying days ending today', () async {
      final today = DateTime.now();
      String key(int daysAgo) =>
          LocalStore.dateKey(today.subtract(Duration(days: daysAgo)));
      const allDone =
          '{"am_cleanse":true,"am_toner":true,"am_serum":true,'
          '"am_spf":true,"pm_cleanse":true,"pm_toner":true,'
          '"pm_treatment":true,"pm_moist":true,"pm_last":true}';

      await _setPrefs({
        'skin_profile_v1': _profileJson,
        'routine:${key(0)}': allDone,
        'routine:${key(1)}': allDone,
        'routine:${key(2)}': allDone,
        // Gap on day 3 — the streak must stop here, not skip over it.
        'routine:${key(4)}': allDone,
      });
      final cubit = RoutineCubit(clock: DateTime.now);
      await cubit.load();

      expect((cubit.state as RoutineReady).currentStreak, 3);
      await cubit.close();
    });
  });
}
