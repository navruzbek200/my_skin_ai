import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_engine.dart';

// Jan 2024: Mon=15, Tue=16, Wed=17, Thu=18, Fri=19, Sat=20, Sun=21
final _mon = DateTime(2024, 1, 15);
final _tue = DateTime(2024, 1, 16);
final _thu = DateTime(2024, 1, 18);
final _sun = DateTime(2024, 1, 21);

void main() {
  // ── Fixed shape ──────────────────────────────────────────────────────

  group('fixed shape', () {
    test('always 4 AM + 5 PM steps', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      expect(r.morning.length, 4);
      expect(r.evening.length, 5);
    });

    test('all 9 step IDs are unique', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      final ids = [...r.morning, ...r.evening].map((s) => s.id).toList();
      expect(ids.toSet().length, 9);
    });

    test('AM last slot is always am_spf', () {
      for (final skin in ['Normal', 'Quruq', "Yog'li", 'Aralash']) {
        final r = RoutineEngine.generate(skinType: skin, concerns: {}, date: _mon);
        expect(r.morning.last.id, 'am_spf');
      }
    });

    test('slot IDs are stable regardless of skin type', () {
      final r1 = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      final r2 = RoutineEngine.generate(skinType: "Yog'li", concerns: {'Bh'}, date: _tue);
      final ids1 = r1.morning.map((s) => s.id).toList();
      final ids2 = r2.morning.map((s) => s.id).toList();
      expect(ids1, ids2);
    });
  });

  // ── Skin-type AM labels ──────────────────────────────────────────────

  group('AM labels by skin type', () {
    test('oily → oil-control foam cleanse', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.morning.first.title, "Ko'pikli tozalash");
    });

    test('dry → gentle cream cleanse', () {
      final r = RoutineEngine.generate(skinType: 'Quruq', concerns: {}, date: _mon);
      expect(r.morning.first.title, 'Yumshoq kremsimon tozalash');
    });

    test('normal → soft gel cleanse', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      expect(r.morning.first.title, 'Yumshoq gel tozalash');
    });

    test('pigmentation/aging concern → Vitamin C serum in AM', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'W'}, date: _mon);
      expect(r.morning[2].title, 'C-vitamin serum');
    });

    test('no aging concern + oily → niacinamide serum in AM', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.morning[2].title, 'Niasinamid serum');
    });
  });

  // ── PM dry skin ──────────────────────────────────────────────────────

  group('PM labels — dry skin', () {
    test('dry → rich night cream in pm_moist slot', () {
      final r = RoutineEngine.generate(skinType: 'Quruq', concerns: {}, date: _mon);
      expect(r.evening[3].title, 'Boy tungi krem');
    });

    test('oily → light gel cream in pm_moist slot', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.evening[3].title, 'Yengil gel krem');
    });
  });

  // ── Active nights ────────────────────────────────────────────────────

  group('active nights (Tue / Thu / Sat)', () {
    test('oily + blackheads on Tue → BHA/AHA treatment', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'Bh'}, date: _tue);
      expect(r.evening[2].title, 'BHA/AHA eksfoliatsiya');
    });

    test('oily + blackheads on Mon (not active) → restorative serum', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'Bh'}, date: _mon);
      expect(r.evening[2].title, 'Tiklovchi namlovchi serum');
    });

    test('aging concern on Thu → retinol treatment', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'W'}, date: _thu);
      expect(r.evening[2].title, 'Retinol (haftada 3 marta)');
    });

    test('retinol preferred over BHA when both aging+exfoliate concerns on active night', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'W', 'Bh'}, date: _tue);
      expect(r.evening[2].title, 'Retinol (haftada 3 marta)');
    });
  });

  // ── Sensitive skin ───────────────────────────────────────────────────

  group('sensitive skin', () {
    test('sensitive blocks BHA even on active night', () {
      final r = RoutineEngine.generate(
        skinType: "Yog'li",
        concerns: {'S', 'Bh'},
        date: _tue, // active night
      );
      expect(r.evening[2].title, 'Tinchlantiruvchi baryer serum');
    });

    test('sensitive barrier serum every day of the week', () {
      // Jan 15–21 = Mon–Sun
      for (var day = 15; day <= 21; day++) {
        final r = RoutineEngine.generate(
          skinType: 'Normal',
          concerns: {'S'},
          date: DateTime(2024, 1, day),
        );
        expect(
          r.evening[2].title,
          'Tinchlantiruvchi baryer serum',
          reason: 'day=$day',
        );
      }
    });
  });

  // ── Sunday mask night ────────────────────────────────────────────────

  group('Sunday mask night', () {
    test('oily + Sunday → clay mask in pm_last', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _sun);
      expect(r.evening.last.title, 'Loy niqob');
    });

    test('normal/dry + Sunday → hydrating mask in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _sun);
      expect(r.evening.last.title, 'Namlovchi niqob');
    });

    test('eye concern overrides Sunday mask (eye cream wins)', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ew'}, date: _sun);
      expect(r.evening.last.title, "Ko'z kremi");
    });
  });

  // ── Eye concern ──────────────────────────────────────────────────────

  group('eye concern', () {
    test('Ew concern on weekday → eye cream in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ew'}, date: _mon);
      expect(r.evening.last.title, "Ko'z kremi");
    });

    test('Ed concern on weekday → eye cream in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ed'}, date: _mon);
      expect(r.evening.last.title, "Ko'z kremi");
    });

    test('no eye concern weekday → tungi niqob fallback', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      expect(r.evening.last.title, 'Tungi namlovchi niqob');
    });
  });
}
