import '../models/skin_analysis_result.dart';

export '../models/skin_result.dart';
export '../models/skin_analysis_result.dart';

/// Turns the quiz answers into a cosmetic care note.
///
/// Two rules hold every string in this file, both of them owed to guideline
/// 1.4.1 rejections on 1.0 (7):
///
/// 1. Cosmetic language only. No condition is named or described, nothing is
///    called a cause, and nothing is treated, cured or diagnosed — the notes
///    say what to put on the skin and in what order, which is cosmetics.
///    Anyone worried about their skin is pointed at a clinician instead.
/// 2. Every note cites. Each entry carries a `sources` value of ids from
///    [skinSources]; the results screen prints the publisher under the note
///    and links out to the page. A note without a source does not ship.
class SkinLogic {
  static const _skinTypeByQ1 = {
    0: 'Quruq', 1: 'Quruq', 2: 'Aralash',
    3: 'Normal', 4: "Yog'li", 5: "Yog'li",
  };
  static const _skinTypeCode = {
    'Quruq': 'D', 'Aralash': 'C', 'Normal': 'N', "Yog'li": 'O',
  };
  static const int _threshold = 3;
  static const _oilySkinTypes = {"Yog'li"};

  // index -> recommendation code (scale >= threshold)
  static const _indexToRec = {
    1: 'P0', // pores
    4: 'Bh', // blackheads
    5: 'Wh', // whiteheads
    6: 'P',  // pigmentation
    7: 'Ew', // eye wrinkles
    8: 'Ed', // dark circles
    9: 'W',  // sagging
  };

  /// Pointed at by every note that touches skin someone is worried about.
  /// Short on purpose — it has to read as a hand-off, not as advice.
  static const _seeSpecialist =
      "Bu kosmetik parvarish maslahati. Teringizning holati sizni tashvishga "
      "solsa, malakali shifokorga murojaat qiling.";

  static const _baseRecommendations = {
    'Quruq': '''Sizning yuz teringiz QURUQ.

Quruq teri uchun kundalik parvarishning asosiy maqsadi — namlikni saqlab qolish. Yuzni kuniga ikki marta yumshoq, terini quritmaydigan tozalagich bilan yuving va iliq suv ishlating.

Yuvingandan keyin teri hali nam ekanida namlovchi krem surting — shunda namlik ichkarida qoladi. Tarkibida gialuron kislotasi, glitserin yoki keramidlar bo'lgan kremlar quruq teri uchun qulay. Qo'pol skrablar va spirtli vositalardan saqlaning, ular terini yanada quritadi.''',

    'Aralash': '''Sizning yuz teringiz ARALASH.

Aralash terida T-zona (peshona, burun va iyak) odatda yog'liroq, yanoqlar esa quruqroq bo'ladi. Shuning uchun parvarishni zonalarga ajratib qilish qulay.

Yuzni kuniga ikki marta yumshoq gel tozalagich bilan yuving. T-zonaga yengil, yog'siz (oil-free) namlovchi, yanoqlarga esa qalinroq krem surting. Har kuni ertalab keng spektrli SPF 30 yoki undan yuqori quyosh kremini ishlating.''',

    'Normal': '''Sizning yuz teringiz NORMAL.

Normal teri yog' va namlik jihatidan muvozanatda bo'ladi. Bu holatni saqlab qolishning eng oson yo'li — oddiy va doimiy parvarish.

Yuzni kuniga ikki marta yumshoq tozalagich bilan yuving, keyin namlovchi krem surting va har kuni ertalab keng spektrli SPF 30+ quyosh kremini qo'llang. Murakkab ko'p bosqichli tartib shart emas — muntazamlik muhimroq.''',

    "Yog'li": '''Sizning yuz teringiz YOG'LI.

Yog'li teri uchun yumshoq tozalash va yengil teksturalar qulay. Yuzni kuniga ikki martagacha va terlaganingizdan keyin yumshoq ko'pikli tozalagich bilan yuving — bundan ko'p yuvish terini bezovta qiladi.

Mahsulotlarni "oil-free" va "non-comedogenic" belgisi bo'yicha tanlang. Namlovchini o'tkazib yubormang: yengil, suv asosidagi namlovchi yog'lilikni oshirmaydi. Har kuni keng spektrli SPF 30+ quyosh kremini ishlating va yuzingizga kun davomida tez-tez tegmang.''',
  };

  /// `sources` holds ids from `skinSources` (lib/data/sources_data.dart).
  static const _additionalRecommendations = {
    'P0': {
      'title': 'Poralar',
      'text': '''Teri teshikchalari ko'zga tashlanadi.

Yuzni kuniga ikki marta yumshoq, yog'siz tozalagich bilan yuving va makiyajni uxlashdan oldin to'liq oling. Mahsulotlarda "non-comedogenic" belgisi bo'lsin — bunday vositalar teshikchalarni yopmaydi.

Yengil, suv asosidagi namlovchi va har kuni keng spektrli SPF 30+ quyosh kremi teri yuzasining tekis ko'rinishiga yordam beradi. Og'ir, yog'li kremlardan saqlaning.''',
      'sources': 'aad_oily,aad_wash,aad_sunscreen',
    },
    'S': {
      'title': 'Ta’sirchanlik',
      'text': '''Teringiz tashqi ta'sirlarga sezgir.

Yuzni kuniga ikki marta iliq suv va yumshoq, parfyumersiz tozalagich bilan yuving. Yangi mahsulotni birdaniga butun yuzga surtmang — avval kichik sohada sinab ko'ring va bir vaqtning o'zida faqat bitta yangi vosita qo'shing.

Qo'pol skrablar, spirtli toniklar va kuchli hidli vositalardan saqlaning. Oddiy, qisqa tarkibli namlovchi va har kuni keng spektrli SPF 30+ quyosh kremi eng qulay tanlov.

$_seeSpecialist''',
      'sources': 'aad_basics,aad_moisturizer,aad_sunscreen',
    },
    'Bh': {
      'title': 'Qora nuqtalar',
      'text': '''Yuzingizda qora nuqtalar ko'rinadi.

Yuzni kuniga ikki marta yumshoq ko'pikli tozalagich bilan yuving va makiyajni uxlashdan oldin to'liq oling. Mahsulotlarni "oil-free" va "non-comedogenic" belgisi bo'yicha tanlang.

Qora nuqtalarni tirnoq bilan siqmang va qo'pol skrab ishlatmang — bu teri yuzasiga zarar yetkazadi. Teringizni kun davomida qo'l bilan ushlamaslikka harakat qiling.

$_seeSpecialist''',
      'sources': 'aad_acne_care,aad_acne_tips,aad_wash',
    },
    'Wh': {
      'title': 'Oq nuqtalar',
      'text': '''Yuzingizda oq nuqtalar ko'rinadi.

Ularni mexanik yo'l bilan siqib chiqarishga urinmang. Yuzni kuniga ikki marta yumshoq, yog'siz tozalagich bilan yuving va "non-comedogenic" belgisi bo'lgan yengil namlovchidan foydalaning.

Og'ir, qalin kremlar va yog' asosidagi makiyaj vositalari holatni yomonlashtirishi mumkin.

$_seeSpecialist''',
      'sources': 'aad_acne_care,aad_acne_tips,aad_moisturizer',
    },
    'P': {
      'title': "Dog', sepkillar",
      'text': '''Teri rangi notekis ko'rinadi.

Bu yerda eng katta farqni quyoshdan himoya qiladi. Har kuni, bulutli kunda ham, keng spektrli SPF 30 yoki undan yuqori quyosh kremini surting va har ikki soatda yangilang. Yuzga taxminan bir choy qoshiq miqdorda krem kerak bo'ladi.

Soya, keng chekkali shlyapa va yopiq kiyim ham quyosh ta'sirini kamaytiradi. Yumshoq tozalash va namlash bilan birga olib borilsa, teri rangi vaqt o'tishi bilan tekisroq ko'rinadi — natija uchun bir necha oy kerak.''',
      'sources': 'aad_sunscreen,fda_sunscreen,who_uv',
    },
    'Ew': {
      'title': "Ko'z atrofidagi mayda chiziqlar",
      'text': '''Ko'z atrofida mayda chiziqlar ko'rinadi.

Ko'z atrofidagi teri nozik, shuning uchun unga yengil teging — ishqalamang va tortmang. Namlovchi krem bu sohaning quruqligini kamaytiradi va chiziqlarning ko'rinishini yumshatadi.

Quyosh nuri terining erta qarishiga ta'sir qiluvchi asosiy tashqi omil, shuning uchun har kuni keng spektrli SPF 30+ quyosh kremi va quyosh ko'zoynagi foydali.''',
      'sources': 'aad_aging,medline_aging_face,aad_moisturizer',
    },
    'Ed': {
      'title': "Ko'z tagidagi qorayishlar",
      'text': '''Ko'z tagi to'qroq ko'rinadi.

Ko'z atrofiga yengil, nozik teri uchun mo'ljallangan namlovchi surting va bu sohani ishqalamang. Yetarli uyqu va kun davomida yetarli suv ichish umumiy ko'rinishga yaxshi ta'sir qiladi.

Quyoshdan himoya bu yerda ham muhim: keng spektrli SPF 30+ krem va quyosh ko'zoynagi ko'z atrofi terisini himoya qiladi.

$_seeSpecialist''',
      'sources': 'medline_aging_face,aad_sunscreen,aad_routine',
    },
    'W': {
      'title': 'Teri tarangligi',
      'text': '''Teri avvalgidek tarang ko'rinmayapti.

Terining tabiiy o'zgarishiga eng ko'p ta'sir qiladigan tashqi omil — quyosh nuri. Har kuni keng spektrli SPF 30 yoki undan yuqori krem surting, soyada yuring va quyosh eng tik turgan soatlarda ochiq joydan saqlaning.

Chekmaslik, yumshoq tozalash va muntazam namlash ham terining ko'rinishiga ijobiy ta'sir qiladi. Yuzni ishqalamang va kuchli skrablardan foydalanmang.''',
      'sources': 'aad_aging,medline_aging_skin,who_uv',
    },
    'Ao': {
      'title': "Toshmalar (yog'li teri)",
      'text': '''Yuzingizda toshmalar tez-tez paydo bo'ladi.

Yuzni kuniga ikki martagacha va terlaganingizdan keyin yumshoq, parfyumersiz tozalagich bilan yuving — bundan ortiq yuvish terini bezovta qiladi. Yuzni ishqalamang.

Barcha vositalarni — tozalagich, namlovchi va makiyaj — "oil-free" va "non-comedogenic" belgisi bo'yicha tanlang. Toshmalarni siqmang va yuzingizga kun davomida tegmang. Yengil namlovchini va har kuni SPF 30+ quyosh kremini o'tkazib yubormang.

$_seeSpecialist''',
      'sources': 'aad_acne_care,aad_acne_tips,aad_oily',
    },
    'Ad': {
      'title': 'Toshmalar (quruq teri)',
      'text': '''Quruq terida ham toshmalar paydo bo'lishi mumkin, shuning uchun parvarish yumshoq bo'lishi kerak.

Yuzni kuniga ikki marta iliq suv va terini quritmaydigan, parfyumersiz tozalagich bilan yuving. Yuvingandan keyin darhol "non-comedogenic" belgisi bo'lgan namlovchi surting.

Qo'pol skrablar, spirtli toniklar va qurituvchi vositalardan saqlaning — ular terini yanada bezovta qiladi. Har kuni SPF 30+ quyosh kremini ishlating.

$_seeSpecialist''',
      'sources': 'aad_acne_care,aad_dry,aad_moisturizer',
    },
  };

  /// Sources behind the per-skin-type note at the top of the results screen.
  static const _baseSources = {
    'Quruq': 'aad_dry,aad_moisturizer,aad_wash',
    'Aralash': 'aad_basics,aad_wash,aad_sunscreen',
    'Normal': 'aad_basics,aad_routine,aad_sunscreen',
    "Yog'li": 'aad_oily,aad_wash,aad_sunscreen',
  };

  static SkinAnalysisResult analyze(List<dynamic> answers) {
    final q1 = _safeInt(answers, 0, defaultVal: 2);
    final skinType = _skinTypeByQ1[q1] ?? 'Normal';
    final skinCode = _skinTypeCode[skinType] ?? 'N';
    final baseRec = _baseRecommendations[skinType] ?? '';

    final blocks = <Map<String, String>>[];
    void addCode(String code) {
      if (blocks.any((b) => b['code'] == code)) return;
      final rec = _additionalRecommendations[code];
      if (rec != null) blocks.add({'code': code, ...rec});
    }

    // sensitive (index 2)
    if (_safeInt(answers, 2) >= _threshold) addCode('S');
    // blemish-prone (index 3) — oily → Ao, other → Ad
    if (_safeInt(answers, 3) >= _threshold) {
      addCode(_oilySkinTypes.contains(skinType) ? 'Ao' : 'Ad');
    }
    // threshold-driven blocks (index-mapped)
    for (final e in _indexToRec.entries) {
      if (_safeInt(answers, e.key) >= _threshold) addCode(e.value);
    }

    return SkinAnalysisResult(
      skinType: skinType,
      skinTypeCode: skinCode,
      baseRecommendation: baseRec,
      baseSources: _baseSources[skinType] ?? 'aad_basics',
      additionalBlocks: blocks,
    );
  }

  static int _safeInt(List<dynamic> answers, int index, {int defaultVal = 0}) {
    if (index < 0 || index >= answers.length) return defaultVal;
    final v = answers[index];
    return v is int ? v : defaultVal;
  }
}
