import '../models/skin_analysis_result.dart';

export '../models/skin_result.dart';
export '../models/skin_analysis_result.dart';

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

  // primary-concern choice index -> code to bubble to front
  static const Map<int, String?> _primaryToCode = {
    0: 'Bh', 1: 'P', 2: null, 3: 'W', 4: 'Ew', 5: 'S',
  };

  static const _baseRecommendations = {
    'Quruq': '''Sizning teringiz QURUQ teri turiga mansub.

Quruq teri uchun asosiy parvarishda namlantirishga alohida e'tibor bering. Kuniga kamida 2 marta namlantiruvchi krem ishlating — ertalab va kechqurun. Gialuron kislota, serozidin, shea yog'i va ceramidlar asosidagi mahsulotlarni tanlang.

Yuvish uchun yumshoq, kremsimon tozalovchi vositalardan foydalaning. Spirt, salitsilik kislota yoki agressiv tarkibli mahsulotlardan saqlaning.

Tana uchun ham alohida namlantiruvchi krem ishlating, ayniqsa cho'milgandan so'ng. Ko'proq suv iching va havo namligini tartibga soluvchi humidifikator ishlating.''',

    'Aralash': '''Sizning teringiz ARALASH teri turiga mansub.

T-zona (peshona, burun, iyak) yog'li, qolgan qismlari esa quruq bo'ladi. Parvarishda ushbu ikki hududga turlicha yondashuv talab etiladi.

T-zona uchun engil, gel yoki suv asosidagi namlantiruvchilar tanlang. Yanoqlar va ko'z atrofi uchun esa kreminiy, boyroq mahsulotlar ishlating.

Yuzni ikki marta — ertalab va kechqurun yuving. Haftada 1–2 marta yengil eksfoliatsiya qiling. Niasinamid, gialuron kislota va hafif AHA/BHA asosidagi mahsulotlar mos keladi.''',

    'Normal': '''Sizning teringiz NORMAL teri turiga mansub.

Bu eng maqbul teri turi — u nisbatan barqaror va parvarish qilish nisbatan oson. Asosiy maqsad: teri barrierni saqlash va yosh ko'rinishni qo'llab-quvvatlash.

Yumshoq tozalash, engilgina namlantirishni kundalik tartibga kiriting. Antioxidantlar (C vitamini, niasinamid) va SPF ni unutmang.

Teringiz holati yaxshi saqlanishi uchun ovqatlanishga, uyquga va suvni yetarli miqdorda ichishga e'tibor bering.''',

    "Yog'li": '''Sizning teringiz YOG'LI teri turiga mansub.

Yog'li teri uchun asosiy maqsad — sebum ishlab chiqarishni muvozanatlash va poralarni toza saqlash. Lekin quritishdan saqlaning — bu aksincha ko'proq yog' ishlab chiqishga olib keladi.

Engil, oil-free yoki gel asosidagi namlantiruvchilar tanlang. Niasinamid, salitsilik kislota (BHA) va tuproq asosidagi maskalar foydali.

Yuzni kuchli yumasdan, 2 marta yuving. Namlantirishni o'tkazib yubormang va doimo SPF ishlating.''',
  };

  static const _additionalRecommendations = {
    'P0': {
      'title': 'Katta poralar',
      'text': '''Sizda kengaygan poralar muammosi bor.

Sog'ish poriklarni kichraytirish uchun niasinamid (5–10%) va retinol samarali ishlaydi. Haftada 1–2 marta BHA (salitsilik kislota) asosidagi eksfoliatsiyalovchi mahsulot ishlating.

Makiyaj ostiga primer ishlating va yuz yuvishdan keyin tonerni o'tkazib yurmang.''',
    },
    'S': {
      'title': 'Sezgir teri',
      'text': '''Sizda sezgir teri muammosi mavjud.

Sezgir teri uchun parfyumersiz (fragrance-free), gippoallergenik mahsulotlarni tanlang. Yangi mahsulotni avval yelka yoki quloq ostida sinab ko'ring.

Qo'shimcha tarkiblar: panthenol (B5 vitamini), allantoin, beta-glyukan teri to'siqini mustahkamlaydi. Agressiv kislotalar, spirt va eterli moylardan saqlaning.''',
    },
    'Bh': {
      'title': 'Qora nuqtalar (komed)',
      'text': '''Sizda qora nuqtalar muammosi bor.

Qora nuqtalarni kesish yoki siqishning o'rniga BHA (salitsilik kislota) asosidagi tozalovchi vositalar ishlating — ular poralarni ichkaridadn tozalaydi.

Yuzni kuchli ishqalamasdan, yumshoq aylana harakatlar bilan yuving. Haftada 1–2 marta kaolin yoki bentonit asosidagi maska qo'llang.''',
    },
    'Wh': {
      'title': 'Jiroviklar (oq nuqtalar)',
      'text': '''Sizda jirovik (milium) muammosi bor.

Jiroviklar — bu teri ostida to'plangan keratin. Ularni mexanik yo'l bilan siqmang. Retinol yoki AHA (glikolik kislota) asosidagi mahsulotlar uzoq muddatda samarali.

Komedogen (poralarni berkituvchi) mahsulotlardan saqlaning. Non-comedogenic deb belgilangan mahsulotlar tanlang.''',
    },
    'P': {
      'title': 'Pigmentatsiya',
      'text': '''Sizda pigmentatsiya va dog' muammolari bor.

Pigmentatsiyaga qarshi eng samarali tarkiblar: C vitamini (10–20%), niasinamid (5%), arbutin, kojik kislota va alfa-arbutin. Har kuni SPF 30+ quyosh kremini ishlating — bu eng muhim qadam.

Giperpigmentatsiyani davolash uzoq muddat (3–6 oy) talab etadi. Kechqurun retinol yoki AHA ishlating.''',
    },
    'Ew': {
      'title': "Ko'z atrofidagi ajinlar",
      'text': '''Sizda ko'z atrofi ajinlari muammosi bor.

Ko'z atrofi terisi juda nozik va alohida parvarishni talab etadi. Maxsus ko'z krem yoki serumlarini ishlating — ular ko'z atrofi uchun mo'ljallangan.

Samarali tarkiblar: retinol (past konsentratsiyada), peptidlar, kofein (shishlikka qarshi) va gialuron kislota. Ko'zingizni ishqalamasdan, teginmasdan namlantiringiz.''',
    },
    'Ed': {
      'title': "Ko'z tagidagi qorayishlar",
      'text': '''Sizda ko'z tagida qorayish muammosi bor.

Qorayishlarning sababi turlicha bo'lishi mumkin: qon aylanish, pigmentatsiya yoki teri yupqaligi. Kofein va vitamin K qon aylanishni yaxshilaydi.

Yetarli uxlash, ko'z krem ishlating va quyoshdan himoyaning. C vitamini va niasinamid pigmentatsion qorayishga yordam beradi.''',
    },
    'W': {
      'title': "Teri bo'shashishi",
      'text': '''Sizda teri bo'shashishi muammosi bor.

Teri elastikligini saqlash uchun kollagen sintezini rag'batlantiruvchi tarkiblar tanlang: retinol, C vitamini, peptidlar (Argireline, Matrixyl).

Yuzni massaj qilish qon aylanishini yaxshilaydi. Gua sha yoki yuz massaj yo'llaridan foydalaning. Antioksidant serumlar va SPF ni doimo ishlating.''',
    },
    'Ao': {
      'title': "Yog'li teri acne",
      'text': '''Sizda yog'li teri turida akne muammosi bor.

Yog'li teri uchun akne davolanishida BHA (salitsilik kislota 2%), benzoil peroksid va niasinamid samarali. Oil-free va non-comedogenic mahsulotlar tanlang.

Teri quritish o'rniga muvozanatlashtirishga intiling. Gidrojel yoki suv asosidagi namlantirishdan foydalaning.''',
    },
    'Ad': {
      'title': 'Acne va post-acne',
      'text': '''Sizda akne muammosi bor.

Akne davolashda sabr talab etadi. Faol ingredientlar: niasinamid (yallig'lanishga qarshi), salitsilik kislota (qora nuqtalar), benzoil peroksid (bakteriyalarga qarshi).

Post-acne izlarni yo'qotish uchun: C vitamini, AHA, retinol va quyosh kremini birga ishlating. Husnbuzarlarni siqmang — bu ko'proq chandiq qoldiradi.''',
    },
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
    // acne (index 3) — oily → Ao, other → Ad
    if (_safeInt(answers, 3) >= _threshold) {
      addCode(_oilySkinTypes.contains(skinType) ? 'Ao' : 'Ad');
    }
    // threshold-driven blocks (index-mapped)
    for (final e in _indexToRec.entries) {
      if (_safeInt(answers, e.key) >= _threshold) addCode(e.value);
    }

    // primary concern → move matching block to front (or add it if not yet triggered)
    final primary = _safeInt(answers, 11, defaultVal: -1);
    final pCode = _primaryToCode[primary];
    if (pCode != null) {
      addCode(pCode);
      final i = blocks.indexWhere((b) => b['code'] == pCode);
      if (i > 0) {
        final b = blocks.removeAt(i);
        blocks.insert(0, b);
      }
    }

    // age (index 10): value 3=35-44, 4=45+ → gentle anti-aging note if no aging block yet
    final age = _safeInt(answers, 10, defaultVal: 0);
    final hasAging = blocks.any((b) => b['code'] == 'W' || b['code'] == 'Ew');
    if (age >= 3 && !hasAging) {
      blocks.add({
        'code': 'AgeNote',
        'title': 'Yoshga mos profilaktika',
        'text': "Yoshingizni hisobga olib, kollagenni qo'llab-quvvatlovchi "
            'profilaktik parvarish foydali: kechqurun retinol (past konsentratsiya), '
            'ertalab C-vitamin va doimiy SPF. Ajin chuqurlashishidan oldin boshlash eng samarali.',
      });
    }

    return SkinAnalysisResult(
      skinType: skinType,
      skinTypeCode: skinCode,
      baseRecommendation: baseRec,
      additionalBlocks: blocks,
      source: AnalysisSource.quizEstimate,
    );
  }

  static int _safeInt(List<dynamic> answers, int index, {int defaultVal = 0}) {
    if (index < 0 || index >= answers.length) return defaultVal;
    final v = answers[index];
    return v is int ? v : defaultVal;
  }
}
