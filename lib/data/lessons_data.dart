import 'package:flutter/material.dart';
import '../models/lesson.dart';

final List<Lesson> lessons = [
  Lesson(
    id: 'niacinamide',
    title: 'Niatsinamid',
    subtitle: 'Poralar va yog\'lilikni nazorat qilish',
    category: 'Ingrediyent',
    duration: '8 daqiqa',
    level: 'Boshlang\'ich',
    color: Color(0xFF9B59B6),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Niatsinamid nima?',
        body: 'Niatsinamid — B3 vitaminining shakli bo\'lib, teri g\'amxo\'rligida eng ko\'p ishlatiladigan ingrediyentlardan biridir. U poralar, yog\'lilik va pigmentatsiya kabi muammolarni hal qilishda yordam beradi.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'Ilmiy fakt',
        keyword: 'Teri to\'sig\'ini mustahkamlaydi',
        body: 'Tadqiqotlar niatsinamid ceramide ishlab chiqarishni 34% ga oshirishini ko\'rsatdi. Bu teri to\'sig\'ini kuchaytiradi va namlikni saqlashga yordam beradi.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'Asosiy foydalar',
        body: '',
        items: [
          'Poralarni kichraytiradi va yog\'lilikni kamaytiradi',
          'Pigmentatsiya va dog\'larni ochadi',
          'Teri to\'sig\'ini mustahkamlaydi',
          'Qizarishni kamaytiradi va anti-iltihobiy ta\'sir ko\'rsatadi',
          'Ajin va mayda chiziqlarni kamaytiradi',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Foydalanish maslahati',
        body: 'Niatsinamidni 5–10% konsentratsiyada ishlating. Retinol bilan birgalikda ishlatish mumkin, lekin C vitaminidan oldin qo\'llang. Har kuni ertalab va kechqurun tozalangan yuzga surting.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'Niatsinamid deyarli barcha teri turlari uchun mos bo\'lib, u sezgir terini ham bezovta qilmaydi. Muntazam foydalanish bilan 4–8 hafta ichida sezilarli natijalar ko\'rasiz.',
      ),
    ],
  ),
  Lesson(
    id: 'spf',
    title: 'SPF tanlash',
    subtitle: 'Quyoshdan to\'g\'ri himoya',
    category: 'Himoya',
    duration: '6 daqiqa',
    level: 'Asosiy',
    color: Color(0xFFFF9F43),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Nima uchun SPF muhim?',
        body: 'Quyosh nurlari (UVA va UVB) teriga eng katta zarar yetkazuvchi omildir. SPF (Sun Protection Factor) siz uchun eng muhim kundalik parvarish qadamidir — hatto bulutli havoda ham.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'UVA vs UVB',
        keyword: 'UVA — qarish, UVB — kuyish',
        body: 'UVA nurlari teri qatlamlariga chuqur kirib, erta qarish va pigmentatsiyaga olib keladi. UVB esa yuzaki kuyishga sabab bo\'ladi. Keng spektrli SPF ikkalasidan himoya qiladi.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'SPF tanlash mezonlari',
        body: '',
        items: [
          'Kundalik foydalanish uchun SPF 30–50 yetarli',
          'Dengiz, tog\' yoki uzoq tashqarida — SPF 50+',
          'Keng spektrli (broad spectrum) yozuvi bo\'lsin',
          'Teri tipingizga mos formula: yog\'li → gel, quruq → krem',
          'Har 2 soatda yangilash kerak',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Muhim eslatma',
        body: 'Ko\'pchilik SPF ni yetarli miqdorda ishlatmaydi. To\'g\'ri himoya uchun yuzga 2 barmoq (taxminan 1/4 choy qoshiq) SPF krem surting. Kamroq surtsangiz, himoya darajasi keskin tushadi.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'SPF kundalik parvarish majburiy qadami. Uni serum va namlagichdan keyin, makiyajdan oldin ishlating. Tegishli SPF muntazam ishlatilsa, 10 yildan keyin teringiz sog\'lom ko\'rinishida qoladi.',
      ),
    ],
  ),
  Lesson(
    id: 'arbutin',
    title: 'Arbutin',
    subtitle: 'Xavfsiz oqartiruvchi ingrediyent',
    category: 'Ingrediyent',
    duration: '7 daqiqa',
    level: 'O\'rta',
    color: Color(0xFF06D6A0),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Arbutin nima?',
        body: 'Arbutin — o\'simliklardan, xususan yurtning barglaridan olingan tabiiy ingrediyent. U melanin ishlab chiqarishni inhibe qilib, xavfsiz va samarali ravishda pigmentatsiyani kamaytiradi.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'Mexanizm',
        keyword: 'Tirozinaza fermentini bloklaydi',
        body: 'Arbutin melanin sintezi uchun zarur bo\'lgan tirozinaza fermentini to\'xtatadi. Bu gidroxinondan farqli ravishda — ancha xavfsiz va sezgir teri uchun ham mos usul.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'Qo\'llanilish sohalari',
        body: '',
        items: [
          'Quyosh dog\'lari va pigmentatsiya',
          'Post-acne qorayish (PIH)',
          'Notekis teri toni',
          'Ko\'z osti qorayishi',
          'Umumiy yuz tonini tekislash',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Maslahat',
        body: 'Alpha-arbutin beta-arbutinga nisbatan 10x kuchliroq. 1–2% konsentratsiyada samarali. Niatsinamid va C vitamini bilan birgalikda ishlatilsa, natija kuchayadi. SPF bilan birga ishlatish majburiy.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'Arbutin xavfsiz va samarali oqartiruvchi ingrediyent. Natija ko\'rish uchun 8–12 hafta muntazam ishlatish talab etiladi. Homiladorlik va emizish davrida ham xavfsiz hisoblanadi.',
      ),
    ],
  ),
  Lesson(
    id: 'retinol',
    title: 'Retinol',
    subtitle: 'Anti-agingning oltin standarti',
    category: 'Anti-aging',
    duration: '10 daqiqa',
    level: 'Ilg\'or',
    color: Color(0xFFFF6B6B),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Retinol nima?',
        body: 'Retinol — A vitaminining shakli va teri g\'amxo\'rligida eng ko\'p ilmiy isbot qilingan ingrediyent. U ajinlarni, pigmentatsiyani va akne muammolarini hal qilishda kuchli ta\'sir ko\'rsatadi.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'Ilmiy isbot',
        keyword: 'Kollagen ishlab chiqarishni oshiradi',
        body: 'Retinol hujayralar aylanishini tezlashtiradi va kollagen sintezini stimulyatsiya qiladi. Tadqiqotlar 12 hafta davomida ishlatilinganda ajinlar chuqurligi 27–37% kamayishini ko\'rsatdi.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'Bosqichli boshlash qoidasi',
        body: '',
        items: [
          '1-hafta: 0.025% — haftada 2 marta',
          '2-4 hafta: 0.025% — haftada 3-4 marta',
          '1-oy: 0.05% — har kuni kechasi',
          '3-oy: 0.1% — kuchli ta\'sir',
          'Har doim kechasi surting, SPF ertasi kuni majburiy',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Muhim ogohlantirishlar',
        body: 'Retinol boshida teriyi quritishi yoki qizartirishi mumkin — bu "purging" jarayoni. 2–4 hafta o\'tgach yaxshilanadi. Homiladorlik va emizishda ISHLATMANG. Vitamin C bilan bir kechada ishlatmang.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'Retinol — sabrli foydalanuvchilar uchun eng kuchli anti-aging qurol. Sekin boshlang, namlagich bilan yupqalang, SPF doim ishlating. 3–6 oy muntazam foydalanishdan keyin dramatik natija ko\'rasiz.',
      ),
    ],
  ),
  Lesson(
    id: 'hyaluronic',
    title: 'Gialuron kislota',
    subtitle: 'Terini ichidan namlash',
    category: 'Namlash',
    duration: '6 daqiqa',
    level: 'Boshlang\'ich',
    color: Color(0xFF3A86FF),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Gialuron kislota nima?',
        body: 'Gialuron kislota organizmda tabiiy mavjud bo\'lgan molekula bo\'lib, 1 gram suv 6 litr namlikni ushlab turishi mumkin. Teri g\'amxo\'rligidagi eng samarali namlash ingrediyenti hisoblanadi.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'Molekula hajmi muhim',
        keyword: 'Turli hajmdagi molekulalar',
        body: 'Kichik molekulalar (nano-HA) teri qatlamlariga chuqur kirib, ichki namlikni ta\'minlaydi. Katta molekulalar yuzada qolib, himoya plyonka hosil qiladi. Eng yaxshi mahsulotlar ikkalasini o\'z ichiga oladi.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'To\'g\'ri foydalanish',
        body: '',
        items: [
          'Nam teriga surting — quruq teri emas',
          'Tonikdan keyin, namlagichdan oldin',
          'Teri namligini "qulflab" qo\'yish uchun ustiga namlagich surting',
          'Quruq ob-havoda xona ichida ham ishlating',
          'Ko\'z atrofiga ham xavfsiz ishlatish mumkin',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Maslahat',
        body: 'Gialuron kislota atrofdagi namlikni tortadi. Quruq muhitda (konditsioner, samolyot) ustiga namlagich qo\'ymasangiz, u teringizdan namlikni tortib olishi mumkin. Doim ikki qadam: HA → namlagich.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'Gialuron kislota barcha teri turlari uchun mos, xavfsiz va samarali namlash ingrediyenti. Sezgir teri ham uni yaxshi qabul qiladi. Kundalik ertalab va kechqurun ishlatish tavsiya etiladi.',
      ),
    ],
  ),
  Lesson(
    id: 'peptides',
    title: 'Peptidlar',
    subtitle: 'Teri muloqotining tili',
    category: 'Anti-aging',
    duration: '9 daqiqa',
    level: 'O\'rta',
    color: Color(0xFF3AABFF),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: 'Peptidlar nima?',
        body: 'Peptidlar — qisqa aminokislotalar zanjirlari bo\'lib, hujayralararo aloqa vositasi sifatida ishlaydi. Ular kollagen ishlab chiqarishni stimulyatsiya qilib, terining elastikligini oshiradi.',
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: 'Mexanizm',
        keyword: 'Signal peptidlari kollagen yetkazib beradi',
        body: 'Signal peptidlari fibroblastlarni kollagen ishlab chiqarishga undaydi. Carrier peptidlar mis kabi mineral elementlarni teri hujayralariga yetkazadi. Bu jarayon yosh teriga o\'xshash yangilanishni ta\'minlaydi.',
      ),
      LessonStep(
        type: LessonStepType.list,
        title: 'Peptid turlari',
        body: '',
        items: [
          'Signal peptidlar: kollagen sintezini oshiradi',
          'Carrier peptidlar: minerallarni teri ichiga olib kiradi',
          'Neurotransmitter peptidlar: botoks ta\'siriga o\'xshash',
          'Enzyme inhibitor peptidlar: kollagen parchalanishini to\'xtatadi',
          'Antimikrob peptidlar: infeksiyalardan himoya qiladi',
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: 'Birgalikda ishlating',
        body: 'Peptidlar gialuron kislota va niatsinamid bilan ajoyib tandem hosil qiladi. Retinol bilan birgalikda ishlatilsa, anti-aging ta\'sir kuchayadi. AHA/BHA bilan bir vaqtda ISHLATMANG — kislotalar peptidlarni parchalaydi.',
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: 'Xulosa',
        body: 'Peptidlar 30+ yoshdan boshlab parvarishga kiritish kerak bo\'lgan muhim ingrediyent. Ular sekin, lekin izchil natija beradi. 2–3 oy muntazam ishlatish bilan teri elastikligi va tekisligi sezilarli yaxshilanadi.',
      ),
    ],
  ),
];
