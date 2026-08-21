import 'package:real_beauty_ai/core/l10n/localized_text.dart';

import 'routine_step.dart';

/// Generates a personalized daily routine from the user's skin profile.
/// FIXED shape: 4 morning + 5 evening steps so the Bugun UI and streak math
/// stay identical. Only the *labels* of each step adapt to skin type, concerns
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
        ? const LocalizedText(
            'Yuzni iliq suv bilan yuving',
            'Умойтесь тёплой водой',
            'Rinse your face with warm water',
          )
        : isOily
            ? const LocalizedText(
                'Penka bilan yuzni yaxshilab yuving',
                'Тщательно умойтесь пенкой',
                'Wash thoroughly with a foaming cleanser',
              )
            : isCombo
                ? const LocalizedText(
                    "Penka bilan yuving, burun va peshonaga ko'proq e'tibor bering",
                    'Умойтесь пенкой, уделив больше внимания носу и лбу',
                    'Wash with a foaming cleanser, focusing on nose and forehead',
                  )
                : const LocalizedText(
                    'Penka bilan yuzni yuving',
                    'Умойтесь пенкой',
                    'Wash with a foaming cleanser',
                  );
    final amToner = isOily
        ? const LocalizedText(
            "Toner surting — yog'ni kamaytiradi",
            'Нанесите тоник — уменьшает жирность',
            'Apply toner — cuts down the oil',
          )
        : isCombo
            ? const LocalizedText(
                'Toner surting — burun va peshonaga yaxshilab, yanoqlarga yengil',
                'Нанесите тоник — тщательно на нос и лоб, легко на щёки',
                'Apply toner — thoroughly on nose and forehead, lightly on cheeks',
              )
            : const LocalizedText(
                'Toner surting — namlaydi',
                'Нанесите тоник — увлажняет',
                'Apply toner — it hydrates',
              );
    final amSerum = wantsVitC
        ? const LocalizedText(
            'C-vitamin serum surting — yuz rangini yorqinlashtiradi',
            'Нанесите сыворотку с витамином C — выравнивает тон',
            'Apply a vitamin C serum — brightens your complexion',
          )
        : isOily
            ? const LocalizedText(
                'Serum surting — teri teshikchalarini kichraytiradi',
                'Нанесите сыворотку — сужает поры',
                'Apply serum — tightens the pores',
              )
            : isCombo
                ? const LocalizedText(
                    "Serum surting — burun-peshonaga yengil, yanoqlarga ko'proq",
                    'Нанесите сыворотку — легко на нос и лоб, больше на щёки',
                    'Apply serum — lightly on nose and forehead, more on cheeks',
                  )
                : const LocalizedText(
                    'Serum surting — namlaydi',
                    'Нанесите сыворотку — увлажняет',
                    'Apply serum — it hydrates',
                  );

    final morning = <RoutineStep>[
      RoutineStep(id: 'am_cleanse', title: amCleanse),
      RoutineStep(id: 'am_toner',   title: amToner),
      RoutineStep(id: 'am_serum',   title: amSerum),
      const RoutineStep(
        id: 'am_spf',
        title: LocalizedText(
          'Quyosh kremini surting — tashqariga chiqishdan oldin',
          'Нанесите солнцезащитный крем — перед выходом на улицу',
          'Apply sunscreen — before you go outside',
        ),
      ),
    ];

    // ── Evening (5 fixed slots) ──
    final pmCleanse = isOily
        ? const LocalizedText(
            "Avval yog'li tozalovchi, keyin penka bilan yuving",
            'Сначала гидрофильное масло, затем пенка',
            'Cleansing oil first, then a foaming cleanser',
          )
        : isDry
            ? const LocalizedText(
                'Yuzni iliq suv bilan yengil yuving',
                'Умойтесь тёплой водой, без нажима',
                'Rinse gently with warm water',
              )
            : isCombo
                ? const LocalizedText(
                    "Penka bilan yuving, burun-peshonaga ko'proq e'tibor bering",
                    'Умойтесь пенкой, уделив больше внимания носу и лбу',
                    'Wash with a foaming cleanser, focusing on nose and forehead',
                  )
                : const LocalizedText(
                    'Penka bilan yuzni yuving',
                    'Умойтесь пенкой',
                    'Wash with a foaming cleanser',
                  );
    final pmToner = isOily
        ? const LocalizedText(
            "Toner surting — yog'ni muvozanatlaydi",
            'Нанесите тоник — балансирует жирность',
            'Apply toner — balances the oil',
          )
        : isCombo
            ? const LocalizedText(
                "Toner surting — har ikki zonaga alohida e'tibor bering",
                'Нанесите тоник — отдельно на каждую зону',
                'Apply toner — treat each zone on its own',
              )
            : const LocalizedText(
                'Toner surting — namlaydi',
                'Нанесите тоник — увлажняет',
                'Apply toner — it hydrates',
              );

    final LocalizedText pmTreatment;
    if (sensitive) {
      pmTreatment = const LocalizedText(
        'Tinchlantiruvchi serum surting — terini bezovta qilmaydi',
        'Нанесите успокаивающую сыворотку — не раздражает кожу',
        'Apply a soothing serum — it will not irritate',
      );
    } else if (isActiveNight && concerns.any(_retinol.contains)) {
      pmTreatment = const LocalizedText(
        'Retinol serum surting — haftada 3 marta shu qadamni bajaring',
        'Нанесите сыворотку с ретинолом — этот шаг 3 раза в неделю',
        'Apply a retinol serum — this step three nights a week',
      );
    } else if (isActiveNight && concerns.any(_exfoliate.contains)) {
      pmTreatment = const LocalizedText(
        "Piling surting — qora nuqtalar va o'lik hujayralarni tozalaydi",
        'Сделайте пилинг — очищает чёрные точки и отмершие клетки',
        'Exfoliate — clears blackheads and dead skin',
      );
    } else {
      pmTreatment = const LocalizedText(
        'Namlantiruvchi serum surting',
        'Нанесите увлажняющую сыворотку',
        'Apply a hydrating serum',
      );
    }

    final pmMoist = isDry
        ? const LocalizedText(
            'Tungi kremni qalin qilib surting — teri kechasi namlaydi',
            'Нанесите ночной крем плотным слоем — кожа восстанавливается ночью',
            'Apply night cream generously — skin repairs overnight',
          )
        : isOily
            ? const LocalizedText(
                "Yengil namlantiruvchi surting — ozroq, yuzni yog'latmang",
                'Нанесите лёгкий увлажняющий крем — немного, без жирного блеска',
                'Apply a light moisturiser — a little, no greasy finish',
              )
            : isCombo
                ? const LocalizedText(
                    "Kremni surting — yanoqlarga ko'proq, burun-peshonaga kam",
                    'Нанесите крем — больше на щёки, меньше на нос и лоб',
                    'Apply cream — more on the cheeks, less on nose and forehead',
                  )
                : const LocalizedText(
                    'Namlantiruvchi kremni surting',
                    'Нанесите увлажняющий крем',
                    'Apply a moisturiser',
                  );

    final LocalizedText pmLast;
    if (hasEye) {
      pmLast = const LocalizedText(
        "Ko'z atrofiga maxsus krem surting — yengil teging",
        'Нанесите крем для век — лёгкими касаниями',
        'Apply eye cream — with a light touch',
      );
    } else if (isMaskNight) {
      pmLast = isOily
          ? const LocalizedText(
              "Loy niqob qo'ying — teri teshikchalarini tozalaydi, 10-15 daqiqa turing",
              'Нанесите глиняную маску — очищает поры, держите 10–15 минут',
              'Apply a clay mask — clears the pores, leave for 10–15 minutes',
            )
          : isCombo
              ? const LocalizedText(
                  "Loy niqob faqat burun-peshonaga, yanoqlarga namlantiruvchi niqob qo'ying",
                  'Глиняная маска только на нос и лоб, на щёки — увлажняющая',
                  'Clay mask on nose and forehead only, hydrating mask on the cheeks',
                )
              : const LocalizedText(
                  "Namlantiruvchi niqob qo'ying — 15-20 daqiqa turing",
                  'Нанесите увлажняющую маску — держите 15–20 минут',
                  'Apply a hydrating mask — leave for 15–20 minutes',
                );
    } else {
      pmLast = const LocalizedText(
        "Tungi namlantiruvchi niqob qo'ying",
        'Нанесите ночную увлажняющую маску',
        'Apply an overnight hydrating mask',
      );
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
