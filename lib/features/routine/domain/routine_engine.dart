import 'routine_step.dart';

/// Generates a personalized daily routine from the user's skin profile.
/// FIXED shape: 4 morning + 5 evening steps so the Bugun UI and streak math
/// stay identical. Only the *labels* of each slot adapt to skin type, concerns
/// and weekday. Dermatologically safe: SPF only AM, actives only PM and only on
/// scheduled nights (3x/week), no harsh actives for sensitive skin.
class RoutineEngine {
  // Concern codes come from SkinResult.additionalBlocks[*]['code'].
  static const _eye = {'Ew', 'Ed'};
  static const _exfoliate = {'Bh', 'Wh', 'P0', 'Ao', 'Ad'};
  static const _retinol = {'P', 'W'};
  static const _sensitiveCodes = {'S'};

  // Active treatment nights: Tue, Thu, Sat (3x/week, spaced out).
  static const _activeWeekdays = {DateTime.tuesday, DateTime.thursday, DateTime.saturday};

  static DailyRoutine generate({
    required String skinType,
    required Set<String> concerns,
    required DateTime date,
  }) {
    final isOily = skinType == "Yog'li";
    final isDry  = skinType == 'Quruq';
    final sensitive = concerns.any(_sensitiveCodes.contains);
    final hasEye = concerns.any(_eye.contains);
    final wantsVitC = concerns.any(_retinol.contains);
    final wd = date.weekday;
    final isActiveNight = _activeWeekdays.contains(wd) && !sensitive;
    final isMaskNight = wd == DateTime.sunday;

    // ── Morning (4 fixed slots) ──
    final amCleanse = isDry
        ? 'Yumshoq kremsimon tozalash'
        : isOily ? "Ko'pikli tozalash" : 'Yumshoq gel tozalash';
    final amToner = isOily ? 'Balanslovchi toner' : 'Namlovchi toner';
    final amSerum = wantsVitC
        ? 'C-vitamin serum'
        : isOily ? 'Niasinamid serum' : 'Gialuron serum';

    final morning = <RoutineStep>[
      RoutineStep(id: 'am_cleanse', title: amCleanse),
      RoutineStep(id: 'am_toner',   title: amToner),
      RoutineStep(id: 'am_serum',   title: amSerum),
      const RoutineStep(id: 'am_spf', title: 'SPF 50 quyosh kremi'),
    ];

    // ── Evening (5 fixed slots) ──
    final pmCleanse = isOily
        ? "Ikki bosqichli tozalash (yog' + ko'pik)"
        : isDry ? 'Yumshoq kremsimon tozalash' : 'Yumshoq tozalash';
    final pmToner = isOily ? 'Balanslovchi toner' : 'Namlovchi toner';

    final String pmTreatment;
    if (sensitive) {
      pmTreatment = 'Tinchlantiruvchi baryer serum';
    } else if (isActiveNight && concerns.any(_retinol.contains)) {
      pmTreatment = 'Retinol (haftada 3 marta)';
    } else if (isActiveNight && concerns.any(_exfoliate.contains)) {
      pmTreatment = 'BHA/AHA eksfoliatsiya';
    } else {
      pmTreatment = 'Tiklovchi namlovchi serum';
    }

    final pmMoist = isDry
        ? 'Boy tungi krem'
        : isOily ? 'Yengil gel krem' : 'Namlovchi krem';

    final String pmLast;
    if (hasEye) {
      pmLast = "Ko'z kremi";
    } else if (isMaskNight) {
      pmLast = isOily ? 'Loy niqob' : 'Namlovchi niqob';
    } else {
      pmLast = 'Tungi namlovchi niqob';
    }

    final evening = <RoutineStep>[
      RoutineStep(id: 'pm_cleanse',   title: pmCleanse),
      RoutineStep(id: 'pm_toner',     title: pmToner),
      RoutineStep(id: 'pm_treatment', title: pmTreatment),
      RoutineStep(id: 'pm_moist',     title: pmMoist),
      RoutineStep(id: 'pm_last',      title: pmLast),
    ];

    return DailyRoutine(morning: morning, evening: evening);
  }
}
