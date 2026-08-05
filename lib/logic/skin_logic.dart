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

  static const _baseRecommendations = {
    'Quruq': '''Sizning yuz teringiz QURUQ.

Quruq teri uchun asosiy maqsad – terini chuqur namlash, himoya qatlamini tiklash va namlikni saqlab qolishdir. Yuzni kuniga 2 marta yumshoq va terini quritmaydigan tozalagich bilan tozalash tavsiya etiladi.

Tarkibida gialuron kislotasi, pantenol (provitamin B5), keramidlar yoki niatsinamid (vitamin B3) bo'lgan serum va namlovchi kremlar terining namlik balansini tiklashga yordam beradi. Juda kuchli skrablar yoki agressiv kislotalardan saqlanish muhim, chunki ular terini yanada quritishi mumkin.''',

    'Aralash': '''Sizning yuz teringiz ARALASH.

Aralash terida odatda T-zona (peshona, burun va iyak) yog'li bo'ladi, yanoqlar esa quruq yoki normal bo'lishi mumkin. Bunday teri uchun asosiy maqsad – yog' ajralishini nazorat qilish bilan birga terining namlik balansini saqlashdir.

Yuzni kuniga 2 marta yumshoq gel tozalagich bilan tozalash tavsiya etiladi. Tarkibida niatsinamid (vitamin B3), gialuron kislotasi yoki yengil AHA/BHA kislotalari bo'lgan serum va kremlar terining balansini saqlashga yordam beradi. T-zonada ortiqcha yog'ni kamaytirish uchun haftasiga 1–2 marta maska qo'llash, piling ishlatish mumkin, yanoqlarni esa yaxshi namlab turish muhim.''',

    'Normal': '''Sizning yuz teringiz NORMAL.

Normal teri odatda yog' va namlik jihatdan muvozanatlangan bo'lib, poralar kichik, teri silliq va sog'lom ko'rinishga ega bo'ladi. Bunday teri uchun asosiy maqsad – mavjud balansni saqlab qolish va terini tashqi omillardan himoya qilishdir.

Yumshoq tozalash, engilgina namlantirishni kundalik tartibga kiriting. Antioksidantlar (C vitamini, niasinamid) va SPF ni unutmang — bu holatni uzoq yillar saqlab qolishning eng oson yo'li.''',

    "Yog'li": '''Sizning yuz teringiz YOG'LI.

Yog'li teri uchun asosiy maqsad – ortiqcha yog' ajralishini nazorat qilish, poralarni toza saqlash va teri balansini tiklashdir. Lekin quritishdan saqlaning — bu aksincha ko'proq yog' ishlab chiqishga olib keladi.

Yuzni kuniga 2 marta yengil gel yoki penka bilan yuving. Niasinamid, salitsilik kislota (BHA) va oil-free, gidrojel asosidagi namlantiruvchilar tanlang. Namlantirishni hech qachon o'tkazib yubormang va doimo SPF ishlating.''',
  };

  static const _additionalRecommendations = {
    'P0': {
      'title': 'Poralar',
      'text': '''Teringizda poralar ochiq.

Yuzingizni kuniga 2 marta yengil gel yoki salitsil kislotali penka bilan tozalang, niatsinamid tarkibli serum, yog'siz (oil-free) namlantiruvchi qo'llash va har kuni SPF krem surishni tavsiya qilamiz.

Haftasiga 1–2 marta yengil kimyoviy eksfoliatsiya (AHA/BHA) qilish ham poralarni tozalashga yordam beradi. Juda yog'li va og'ir krem ishlatmaslik kerak. To'g'ri parvarish bilan poralar kichikroq ko'rinadi va teri teksturasi yaxshilanadi.''',
    },
    'S': {
      'title': 'Ta’sirchanlik',
      'text': '''Teringizda ta'sirchanlik bor.

Yuzni kuniga 2 marta yumshoq va terini bezovta qilmaydigan tozalagich bilan yuving. Teri himoya qatlamini tiklash va qizarishni kamaytirish uchun tarkibida pantenol (provitamin B5), sentella aziatika, aloe vera, keramidlar va niatsinamid (vitamin B3) bo'lgan serum yoki namlovchi kremlar ishlatish tavsiya etiladi.

Juda kuchli skrablar, yuqori konsentratsiyali kislotalar va spirtli kosmetika terini yanada sezgir qilishi mumkin, shuning uchun ulardan saqlanish kerak. Har kuni SPF 50 quyoshdan himoya kremi ishlating, chunki sezgir teri quyosh ta'siriga tez reaksiyaga kirishadi.''',
    },
    'Bh': {
      'title': 'Qora nuqtalar',
      'text': '''Yuzingizda qora nuqtalar bor.

Yuzni kuniga 2 marta salitsil kislotali yoki yengil gel teksturali penka bilan tozalash poralardagi ortiqcha yog' va kirni kamaytirishga yordam beradi. Tarkibida salitsil kislotasi, niatsinamid yoki retinol bo'lgan vositalar poralarning tiqilib qolishini kamaytiradi va qora nuqtalarni asta-sekin yo'qotishga yordam beradi.

Haftasiga 1–2 marta AHA/BHA eksfoliatsiya, yengil pilinglar maska poralarni chuqur tozalaydi. Qora nuqtalarni tirnoq bilan siqib chiqarmang — bu yallig'lanish va chandiqqa olib kelishi mumkin.''',
    },
    'Wh': {
      'title': 'Oq nuqtalar (jiroviklar)',
      'text': '''Yuzingizda oq nuqtalar (jiroviklar) bor.

Jiroviklar — teri ostida to'plangan keratin bo'lib, ularni mexanik yo'l bilan siqib chiqarish tavsiya etilmaydi. Tarkibida salitsil kislotasi, niatsinamid yoki retinol bo'lgan vositalar poralarning tiqilib qolishini kamaytiradi va jiroviklarni asta-sekin yo'qotishga yordam beradi.

Yuzni kuniga 2 marta yengil gel teksturali penka bilan tozalang. Haftasiga 1–2 marta AHA/BHA eksfoliatsiya poralarni chuqur tozalaydi. Komedogen (poralarni berkituvchi) og'ir kremlardan saqlaning.''',
    },
    'P': {
      'title': "Dog', sepkillar",
      'text': '''Teringiz dog'ga, pigmentatsiyaga moyil.

Yuzni kuniga 2 marta yumshoq tozalagich bilan tozalang. Tarkibida vitamin C, niacinamide, arbutin yoki AHA kislotalari bo'lgan serum va kremlar dog'larni asta-sekin kamaytirishga yordam beradi. Har kuni SPF 50++ quyoshdan himoya kremi qo'llash juda muhim, chunki quyosh nuri pigmentatsiyani kuchaytiradi.

Haftasiga 1–2 marta yengil eksfoliatsiya (AHA/BHA) qilish ham teri rangini bir tekis qilishga yordam beradi. Doimiy va to'g'ri parvarish bilan dog'lar sekin-asta kamayib, teri yanada tiniq va yorqin ko'rinadi. Natija uchun 2–3 oy sabr talab etiladi.''',
    },
    'Ew': {
      'title': "Ko'z atrofidagi ajinlar",
      'text': '''Ko'z atrofida mayda ajinlar aniqlandi.

Ko'z atrofidagi teri juda nozik bo'lgani uchun maxsus ko'z krem ishlatish muhim. Tarkibida gialuron kislotasi, peptidlar yoki kollagen bo'lgan kremlar terini namlaydi va ajinlarning ko'rinishini kamaytirishga yordam beradi.

Ko'z atrofini yumshoq massaj qilish, yetarli uyqu va ekrandan tez-tez dam olish ham muhim.''',
    },
    'Ed': {
      'title': "Ko'z tagidagi qorayishlar",
      'text': '''Ko'z tagida qorayishlar bor.

Ko'z atrofidagi nozik teri uchun maxsus ko'z krem ishlatish muhim. Tarkibida vitamin C, kofein yoki niatsinamid bo'lgan kremlar teri rangini yorqinlashtirishga va qorayishni kamaytirishga yordam beradi.

Yetarli uyqu, ko'proq suv ichish va ko'z atrofini yumshoq parvarish qilish ham muhim — uyqu yetishmasligi qorayishning eng keng tarqalgan sababi.''',
    },
    'W': {
      'title': 'Ajinli, osilgan yuz',
      'text': '''Teringiz elastikligini yo'qotgan, ajinlar va terida osilish kuzatilmoqda.

Tarkibida retinol, peptidlar, kollagen va gialuron kislotasi bo'lgan serum yoki krem ishlatish teri elastikligini oshirishga yordam beradi. Har kuni SPF krem qo'llash juda muhim, chunki quyosh nuri ajinlarni tezlashtiradi.

Haftasiga 1–2 marta namlovchi va tiklovchi maskalar qilish, hamda yuz massaji yoki yuz-yoga mashqlari terining tarangligini yaxshilashga yordam beradi. Doimiy parvarish bilan teri yanada silliq, tarang va sog'lom ko'rinadi.''',
    },
    'Ao': {
      'title': "Husnbuzarlar (yog'li teri)",
      'text': '''Husnbuzarlar bilan ham ishlash kerak.

Yuzni kuniga 2 marta yumshoq antibakterial penka bilan tozalash, tarkibida salitsil kislotasi, niatsinamid, yashil choy ekstrakti bo'lgan vositalardan foydalanish husnbuzarlarni kamaytirishga yordam beradi. Teri toza bo'lishi uchun yengil eksfoliatsiya haftasiga 1–2 marta qilish mumkin.

Juda yog'li va poralarni yopib qo'yadigan kremlardan saqlaning, husnbuzarlarni siqmang. Aktiv bo'lgan holatda terini tinchlantiruvchi tarkibli mahsulotlardan ishlating, iloji boricha makiyaj qilmasdan, yuzingizga ko'p teginmang. Har kuni SPF krem ishlatish ham dog' paydo bo'lishining oldini oladi.

Muhim: husnbuzarlar asosan ichki sabablardan — gormonal o'zgarishlar, noto'g'ri ovqatlanish, uyqu betartibligi, oshqozon-ichak muammolaridan paydo bo'ladi. Aktiv holatda ham ichki, ham tashqi tomondan davolanish tavsiya etiladi: shifokor-dermatologga yoki endokrinologga ko'rinish foydali bo'lishi mumkin.''',
    },
    'Ad': {
      'title': "Husnbuzarlar (quruq teri)",
      'text': '''Quruq terida ham husnbuzar paydo bo'lishi mumkin, shuning uchun parvarish juda yumshoq va namlovchi bo'lishi kerak.

Yuzni kuniga 2 marta yumshoq, terini quritmaydigan penka bilan tozalash tavsiya etiladi. Tarkibida niatsinamid yoki past konsentratsiyadagi salitsil kislotasi bo'lgan vositalar husnbuzarlarni kamaytirishga yordam beradi. Gialuron kislotasi yoki namlovchi krem terining qurib ketishini oldini oladi.

Juda agressiv skrablar va qurituvchi mahsulotlardan saqlaning, har kuni SPF krem qo'llang.

Muhim: husnbuzarlar asosan ichki sabablardan — gormonal o'zgarishlar, noto'g'ri ovqatlanish, uyqu betartibligi, oshqozon-ichak muammolaridan paydo bo'ladi. Aktiv holatda ham ichki, ham tashqi tomondan davolanish tavsiya etiladi: shifokor-dermatologga yoki endokrinologga ko'rinish foydali bo'lishi mumkin.''',
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

    return SkinAnalysisResult(
      skinType: skinType,
      skinTypeCode: skinCode,
      baseRecommendation: baseRec,
      additionalBlocks: blocks,
    );
  }

  static int _safeInt(List<dynamic> answers, int index, {int defaultVal = 0}) {
    if (index < 0 || index >= answers.length) return defaultVal;
    final v = answers[index];
    return v is int ? v : defaultVal;
  }
}
