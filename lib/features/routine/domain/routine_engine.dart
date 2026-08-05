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
    final isOily  = skinType == "Yog'li";
    final isDry   = skinType == 'Quruq';
    final isCombo = skinType == 'Aralash';
    final sensitive = concerns.any(_sensitiveCodes.contains);
    final hasEye = concerns.any(_eye.contains);
    final wantsVitC = concerns.any(_retinol.contains);
    final wd = date.weekday;
    final isActiveNight = _activeWeekdays.contains(wd) && !sensitive;
    final isMaskNight = wd == DateTime.sunday;

    // ── Morning (4 fixed slots) ──
    final amCleanse = isDry
        ? 'Yuzni iliq suv bilan yuving'
        : isOily
            ? 'Penka bilan yuzni yaxshilab yuving'
            : isCombo
                ? 'Penka bilan yuving, burun va peshonaga ko\'proq e\'tibor bering'
                : 'Penka bilan yuzni yuving';
    final amToner = isOily
        ? 'Toner surting — yog\'ni kamaytiradi'
        : isCombo
            ? 'Toner surting — burun va peshonaga yaxshilab, yanoqlarga yengil'
            : 'Toner surting — namlaydi';
    final amSerum = wantsVitC
        ? 'C-vitamin serum surting — yuz rangini yorqinlashtiradi'
        : isOily
            ? 'Serum surting — teri teshikchalarini kichraytiradi'
            : isCombo
                ? 'Serum surting — burun-peshonaga yengil, yanoqlarga ko\'proq'
                : 'Serum surting — namlaydi';

    final morning = <RoutineStep>[
      RoutineStep(id: 'am_cleanse', title: amCleanse),
      RoutineStep(id: 'am_toner',   title: amToner),
      RoutineStep(id: 'am_serum',   title: amSerum),
      const RoutineStep(id: 'am_spf', title: 'Quyosh kremini surting — tashqariga chiqishdan oldin'),
    ];

    // ── Evening (5 fixed slots) ──
    final pmCleanse = isOily
        ? 'Avval yog\'li tozalovchi, keyin penka bilan yuving'
        : isDry
            ? 'Yuzni iliq suv bilan yengil yuving'
            : isCombo
                ? 'Penka bilan yuving, burun-peshonaga ko\'proq e\'tibor bering'
                : 'Penka bilan yuzni yuving';
    final pmToner = isOily
        ? 'Toner surting — yog\'ni muvozanatlaydi'
        : isCombo
            ? 'Toner surting — har ikki zonaga alohida e\'tibor biling'
            : 'Toner surting — namlaydi';

    final String pmTreatment;
    if (sensitive) {
      pmTreatment = 'Tinchlantiruvchi serum surting — terini bezovta qilmaydi';
    } else if (isActiveNight && concerns.any(_retinol.contains)) {
      pmTreatment = 'Retinol serum surting — haftada 3 marta shu qadamni bajaring';
    } else if (isActiveNight && concerns.any(_exfoliate.contains)) {
      pmTreatment = 'Piling surting — qora nuqtalar va o\'lik hujayralarni tozalaydi';
    } else {
      pmTreatment = 'Namlantiruvchi serum surting';
    }

    final pmMoist = isDry
        ? 'Tungi kremni qalin qilib surting — teri kechasi namlaydi'
        : isOily
            ? 'Yengil namlantiruvchi surting — ozroq, yuzni yog\'latmang'
            : isCombo
                ? 'Kremni surting — yanoqlarga ko\'proq, burun-peshonaga kam'
                : 'Namlantiruvchi kremni surting';

    final String pmLast;
    if (hasEye) {
      pmLast = 'Ko\'z atrofiga maxsus krem surting — yengil teging';
    } else if (isMaskNight) {
      pmLast = isOily
          ? 'Loy niqob qo\'ying — teri teshikchalarini tozalaydi, 10-15 daqiqa turing'
          : isCombo
              ? 'Loy niqob faqat burun-peshonaga, yanoqlarga namlantiruvchi niqob qo\'ying'
              : 'Namlantiruvchi niqob qo\'ying — 15-20 daqiqa turing';
    } else {
      pmLast = 'Tungi namlantiruvchi niqob qo\'ying';
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
