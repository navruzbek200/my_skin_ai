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
    test('oily → thorough foam cleanse', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.morning.first.title.uz, 'Penka bilan yuzni yaxshilab yuving');
    });

    test('dry → warm-water cleanse', () {
      final r = RoutineEngine.generate(skinType: 'Quruq', concerns: {}, date: _mon);
      expect(r.morning.first.title.uz, 'Yuzni iliq suv bilan yuving');
    });

    test('normal → foam cleanse', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      expect(r.morning.first.title.uz, 'Penka bilan yuzni yuving');
    });

    test('pigmentation/aging concern → Vitamin C serum in AM', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'W'}, date: _mon);
      expect(r.morning[2].title.uz, contains('C-vitamin serum'));
    });

    test('no aging concern + oily → pore-minimizing serum in AM', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.morning[2].title.uz, contains('teri teshikchalarini kichraytiradi'));
    });
  });

  // ── PM moisturizer ───────────────────────────────────────────────────

  group('PM labels — moisturizer', () {
    test('dry → rich night cream in pm_moist slot', () {
      final r = RoutineEngine.generate(skinType: 'Quruq', concerns: {}, date: _mon);
      expect(r.evening[3].title.uz, contains('Tungi kremni qalin qilib surting'));
    });

    test('oily → light moisturizer in pm_moist slot', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _mon);
      expect(r.evening[3].title.uz, contains('Yengil namlantiruvchi surting'));
    });
  });

  // ── Active nights ────────────────────────────────────────────────────

  group('active nights (Tue / Thu / Sat)', () {
    test('oily + blackheads on Tue → exfoliating treatment', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'Bh'}, date: _tue);
      expect(r.evening[2].title.uz, contains('Piling surting'));
    });

    test('oily + blackheads on Mon (not active) → hydrating serum', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'Bh'}, date: _mon);
      expect(r.evening[2].title.uz, 'Namlantiruvchi serum surting');
    });

    test('aging concern on Thu → retinol treatment', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'W'}, date: _thu);
      expect(r.evening[2].title.uz, contains('Retinol serum surting'));
    });

    test('retinol preferred over exfoliation when both concerns on active night', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {'W', 'Bh'}, date: _tue);
      expect(r.evening[2].title.uz, contains('Retinol serum surting'));
    });
  });

  // ── Sensitive skin ───────────────────────────────────────────────────

  group('sensitive skin', () {
    test('sensitive blocks exfoliation even on active night', () {
      final r = RoutineEngine.generate(
        skinType: "Yog'li",
        concerns: {'S', 'Bh'},
        date: _tue, // active night
      );
      expect(r.evening[2].title.uz, contains('Tinchlantiruvchi serum'));
    });

    test('sensitive calming serum every day of the week', () {
      // Jan 15–21 = Mon–Sun
      for (var day = 15; day <= 21; day++) {
        final r = RoutineEngine.generate(
          skinType: 'Normal',
          concerns: {'S'},
          date: DateTime(2024, 1, day),
        );
        expect(
          r.evening[2].title.uz,
          contains('Tinchlantiruvchi serum'),
          reason: 'day=$day',
        );
      }
    });
  });

  // ── Sunday mask night ────────────────────────────────────────────────

  group('Sunday mask night', () {
    test('oily + Sunday → clay mask in pm_last', () {
      final r = RoutineEngine.generate(skinType: "Yog'li", concerns: {}, date: _sun);
      expect(r.evening.last.title.uz, contains('Loy niqob'));
    });

    test('normal/dry + Sunday → hydrating mask in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _sun);
      expect(r.evening.last.title.uz, contains('Namlantiruvchi niqob'));
    });

    test('eye concern overrides Sunday mask (eye cream wins)', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ew'}, date: _sun);
      expect(r.evening.last.title.uz, contains("Ko'z atrofiga maxsus krem"));
    });
  });

  // ── Eye concern ──────────────────────────────────────────────────────

  group('eye concern', () {
    test('Ew concern on weekday → eye cream in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ew'}, date: _mon);
      expect(r.evening.last.title.uz, contains("Ko'z atrofiga maxsus krem"));
    });

    test('Ed concern on weekday → eye cream in pm_last', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {'Ed'}, date: _mon);
      expect(r.evening.last.title.uz, contains("Ko'z atrofiga maxsus krem"));
    });

    test('no eye concern weekday → night mask fallback', () {
      final r = RoutineEngine.generate(skinType: 'Normal', concerns: {}, date: _mon);
      expect(r.evening.last.title.uz, "Tungi namlantiruvchi niqob qo'ying");
    });
  });
}
