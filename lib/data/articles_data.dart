import 'package:flutter/material.dart';
import '../models/article.dart';

// iconColor is each article's accent: it tints the icon and the "Maqola"
// label, and paints the bar down the left edge of the card. Pick something
// that belongs to the subject — sun amber for SPF, night indigo for sleep —
// so a list of eight white cards is scannable by colour before it is read.
// LessonStyles.readableAccent darkens the hue where it has to carry text, so
// a light pick here stays legible.
const List<Article> articles = [
  Article(
    icon: Icons.spa_outlined,
    iconColor: Color(0xFF7060AA),
    title: 'Koreya parvarish rutinasi: 10 qadam',
    duration: '5 daqiqa',
    summary:
        'Koreya usuli terini bosqichma-bosqich parvarishlab, har bir qatlam keyingisining samaradorligini oshiradi.',
    sections: [
      ArticleSection(
        heading: 'Nima uchun 10 qadam?',
        body:
            'Koreya parvarish falsafasi "kamroq qilmoq" emas, balki "to\'g\'ri qilmoq" prinsipiga asoslanadi. Har bir qadam oldingi qadamning effektini kuchaytiradi — bu kumulyativ ta\'sir yaratadi va vaqt o\'tishi bilan terini tubdan yaxshilaydi.',
      ),
      ArticleSection(
        heading: 'Tozalash qadamlari (1–4)',
        body:
            '1. Yog\' asosidagi klenzor — tashqi iflosliklarni eritadi. 2. Ko\'pik yoki gel klenzor — suvda eriydigan qoldiqlarni tozalaydi. 3. Eksfoluatsiya (haftada 2–3 marta) — o\'lik hujayralarni olib tashlaydi. 4. Tonik — teri pH ini tiklaydi va keyingi qadamlarni tayyorlaydi.',
      ),
      ArticleSection(
        heading: 'Serum va intensiv parvarishlar (5–7)',
        body:
            '5. Esentsiya — yengil, suvsimon tekstura, teriga namlik beradi. 6. Ampula yoki serum — maqsadli ta\'sir: pigmentatsiya, ajinlar, akne. 7. Varaq maska (haftada 1–2 marta) — intensiv parvarish seansi.',
      ),
      ArticleSection(
        heading: 'Yakunlovchi qadamlar (8–10)',
        body:
            '8. Ko\'z kremi — nozik ko\'z atrofi terisi uchun maxsus formula. 9. Namlagich — barcha faol ingrediyentlarni "qulflaydi". 10. SPF (ertalab) yoki uyqu maskasi (kechasi) — muhofaza yoki intensiv tiklash.',
      ),
      ArticleSection(
        heading: 'Barchasini bajarishim shartmi?',
        body:
            'Yo\'q. 10 qadam maqsad emas, manba. O\'zingizga eng mos 3–5 qadamni tanlashingiz mumkin. Muhim asoslar: tozalash, namlash va SPF. Qolganlarni ehtiyojingizga qarab qo\'shing.',
      ),
    ],
  ),
  Article(
    icon: Icons.eco_outlined,
    iconColor: Color(0xFF2E9E6B),
    title: 'Tabiiy ingrediyentlar qanday ishlaydi?',
    duration: '7 daqiqa',
    summary:
        'O\'simlik ekstraktlari va tabiiy birikmalar teri uchun qanday harakat qilishi — kimyo va biologiya orqali tushuntiriladi.',
    sections: [
      ArticleSection(
        heading: '"Tabiiy" so\'zi nima anglatadi?',
        body:
            'Mahsulot qutisidagi "tabiiy" yozuvi hech qanday yuridik ta\'rifga ega emas. Haqiqiy tabiiy ingrediyentlar o\'simlik, mineral yoki biotexnologiya yo\'li bilan olingan birikmalar bo\'lib, ularning samaradorligi klinik sinovlarda isbotlanishi kerak.',
      ),
      ArticleSection(
        heading: 'Eng kuchli tabiiy ingrediyentlar',
        body:
            'Niasin (B3 vitamini) — yallig\'lanishga qarshi ta\'sir. Tokoferol (E vitamini) — antioksidant va himoya. Retinol (A vitamini) — hujayralar yangilanishi. Askorbat kislota (C vitamini) — kollagen sintezi. Aloe vera — namlash va tinchlantirish.',
      ),
      ArticleSection(
        heading: 'Fitokimyoviy birikmalar',
        body:
            'Polifenollar (yashil choy, uzum urug\'i) — hujayra zararini kamaytiradi. Karotenoidlar (sabzi, suvo\'tlar) — UV zararidan himoya qiladi. Flavonoidlar (likoris, romashka) — giperpigmentatsiyani kamaytiradi.',
      ),
      ArticleSection(
        heading: '"Tabiiy" = xavfsiz degan yanglishish',
        body:
            'Ko\'pgina tabiiy ingrediyentlar kuchli allergen bo\'lishi mumkin: lavanda moyi, limon shirasi, efir moylari. Sezgir teri uchun "toza" yoki "organik" mahsulotlar ham muammo keltirib chiqarishi mumkin. Har doim patch-test o\'tkazing.',
      ),
      ArticleSection(
        heading: 'Eng yaxshi yondashuv',
        body:
            'Ilmiy asoslangan ingrediyentlarni tanlang: niatsinamid, gialuron kislota, arbutin, retinol — bular ham tabiiy, ham ilmiy isbotlangan. Reklamaga emas, tekshirilgan tarkibga e\'tibor bering.',
      ),
    ],
  ),
  Article(
    icon: Icons.wb_sunny_outlined,
    iconColor: Color(0xFFE08A1E),
    title: 'SPF haqida bilishingiz kerak bo\'lgan hamma narsa',
    duration: '4 daqiqa',
    summary:
        'SPF omili qanday ishlashi, qaysi raqamni tanlash va to\'g\'ri ishlatish — amaliy qo\'llanma.',
    sections: [
      ArticleSection(
        heading: 'SPF nima?',
        body:
            'Sun Protection Factor — quyosh nurlaridan himoya ko\'rsatkichidir. SPF 30 UVB nurlarining 97% ini, SPF 50 esa 98% ini to\'sadi. Raqam qanchalik yuqori bo\'lsa, farq shunchalik kichik — SPF 50 dan yuqorisida amaliy farq deyarli yo\'q.',
      ),
      ArticleSection(
        heading: 'Kimyoviy va mineral SPF',
        body:
            'Kimyoviy filtrlar (avobenzon, oxybenzon) UV nurlarini energiyaga aylantiradi. Mineral filtrlar (rux oksidi, titan dioksid) nurlarni qaytaradi. Mineral SPF sezgir teri uchun yaxshiroq, lekin oq iz qoldirishi mumkin. Hybrid variantlar ikkalasining afzalliklarini birlashtiradi.',
      ),
      ArticleSection(
        heading: 'Qancha surish kerak?',
        body:
            'Dermatologlar yuzga taxminan 2 barmoq uzunligidagi iz — ya\'ni chorak choy qoshiq — SPF surish kerakligini aytadi. Ko\'pchilik bu miqdorning 25–50% ini qo\'llaydi, bu esa himoya darajasini keskin kamaytiradi.',
      ),
      ArticleSection(
        heading: 'Qachon va qancha tez-tez yangilash kerak?',
        body:
            'Tashqarida har 2 soatda yangilash zarur. Suv yoki terlaganingizdan keyin darhol yangilang. Kun davomida uyda bo\'lsangiz ham — deraza orqali UVA nurlari o\'tadi. Ertalab bir marta surish yetarli emas.',
      ),
      ArticleSection(
        heading: 'Makiyaj ostida SPF',
        body:
            'SPFni namlagichdan so\'ng, toningdan oldin surting. Poudra yoki tonik ichidagi SPF asosiy himoya vazifasini bajarmaydi — u faqat qo\'shimcha. Kun ichida to\'ldirish uchun SPF spreyi qulay.',
      ),
    ],
  ),
  Article(
    icon: Icons.bedtime_outlined,
    iconColor: Color(0xFF4C4B9E),
    title: 'Uyqu va teri sog\'ligi orasidagi bog\'liqlik',
    duration: '6 daqiqa',
    summary:
        'Tungi uyquda teri qanday tiklanadi va uyqu tanqisligi teri holatiga qanday ta\'sir qiladi — ilmiy dalillar bilan.',
    sections: [
      ArticleSection(
        heading: 'Teri tungi tiklanish rejimida',
        body:
            'Uyqu davrida tananing tiklash gormoni (somatotropin) eng yuqori darajada ajralib chiqadi. Bu vaqtda teri hujayralari kuniga nisbatan 2–3 baravar tez yangilanadi. Kollagen sintezi ham asosan tunda amalga oshadi — shu sababli "beauty sleep" ilmiy asosga ega.',
      ),
      ArticleSection(
        heading: 'Uyqu tanqisligi teri holatini yomonlashtiradi',
        body:
            'Kuniga 6 soatdan kam uyqudan so\'ng kortizol (stress gormoni) darajasi oshadi — bu yallig\'lanishni kuchaytiradi va akne og\'irlashtiradi. Bir haftalik uyqu etishmasligi teri to\'sig\'i funktsiyasini susaytiradi va namlik yo\'qolishini 30% gacha oshiradi.',
      ),
      ArticleSection(
        heading: 'Ideal uyqu muhiti',
        body:
            'Xona harorati: 18–20°C — teri uchun optimal. Namlik: 40–60% — quruq havo teri namligini tortib oladi. Yostiq qopi: ipak yoki satin — bu material bilan teri izi kamroq qoladi. Uxlashdan oldin telefon ekranini o\'chiring: ko\'k nur melatonin ajralishini susaytiradi.',
      ),
      ArticleSection(
        heading: 'Kechki parvarishni optimallashtirish',
        body:
            'Tungi parvarish ertalabkidan farq qilishi kerak: retinol, kislotalar va kuchliroq serumlar kechasi ishlating — ular fotosensitivlik beradi va tungi tiklanish jarayoni bilan sinergiyada ishlaydi. Kechki namlagich teri bariyerini tiklashda yordam beradi.',
      ),
      ArticleSection(
        heading: 'Amaliy maslahatlar',
        body:
            'Uxlashdan 1 soat oldin parvarishni bajaring — ingrediyentlarga shimib olish uchun vaqt beradi. Har kuni bir xil vaqtda yoting — sikadiyat ritm tartibli bo\'lsa, teri tiklanishi yanada samaraliroq bo\'ladi. Maqsad: kuniga 7–9 soat sifatli uyqu.',
      ),
    ],
  ),
  Article(
    icon: Icons.restaurant_outlined,
    iconColor: Color(0xFFD2553F),
    title: 'Ovqatlanish va akne: ilmiy aloqa',
    duration: '8 daqiqa',
    summary:
        'Qaysi ovqatlar akneyi kuchaytirishi va qaysi birikmalar terini ichdan parvarishlashi — tadqiqotlarga asoslangan qo\'llanma.',
    sections: [
      ArticleSection(
        heading: 'Ovqat va akne aloqasi haqiqatmi?',
        body:
            'Uzoq vaqt dermatologlar ovqat va akne orasidagi aloqani rad etishgan. Ammo oxirgi 20 yil ichida o\'tkazilgan ko\'plab tadqiqotlar bu aloqa haqiqiy ekanligini ko\'rsatdi — ayniqsa glikemik indeksi yuqori ozuqalar va sut mahsulotlari bilan bog\'liqda.',
      ),
      ArticleSection(
        heading: 'Akneni kuchaytiruvchi ovqatlar',
        body:
            'Glikemik indeksi yuqori ozuqalar (oq non, gazlangan ichimliklar, shirinliklar) insulin darajasini tez ko\'taradi — bu esa sebum ishlab chiqarishni oshiradi. Sut mahsulotlari (ayniqsa yog\'siz sut): IGF-1 va gormonlar sut orqali o\'tib, sababiy bog\'liqlik yaratadi. Qayta ishlangan ovqatlar va trans-yog\'lar yallig\'lanishni kuchaytiradi.',
      ),
      ArticleSection(
        heading: 'Teri uchun foydali ozuqalar',
        body:
            'Omega-3 yog\' kislotalari (yog\'li baliq, zig\'ir urug\'i) — yallig\'lanishni kamaytiradi. Sink (qo\'y go\'shti, qovoq urug\'i, loviya) — aknega qarshi eng muhim mineral. A vitamini (sabzi, tarvuz, o\'rik) — teri yangilanishiga yordam beradi. Probiotiklar (qatiq, kefir, kimchi) — ichak-teri o\'qi orqali ta\'sir qiladi.',
      ),
      ArticleSection(
        heading: 'Suv ichish va teri',
        body:
            'Ko\'proq suv ichish akneyi bevosita bartaraf etmaydi, lekin teri namligini va toksinlar chiqarilishini qo\'llab-quvvatlaydi. Kuniga 2–2,5 litr suv (jismoniy faollik va ob-havoga qarab) terini umumiy salomatlikda ushlab turadi.',
      ),
      ArticleSection(
        heading: 'Amaliy yondashuv',
        body:
            'Ovqat jurnali yuritib, qaysi ovqatlardan keyin akne avj olishini kuzating. Shakar va sut mahsulotlarini 4 hafta kamaytiring va teri holatini kuzating. Ovqatlanish o\'zgarishi 8–12 haftada sezilarli natija beradi.',
      ),
    ],
  ),
  Article(
    icon: Icons.ac_unit_outlined,
    iconColor: Color(0xFF2196A5),
    title: 'Yuzga muz surish: foyda yoki zarar?',
    duration: '4 daqiqa',
    summary:
        'Ijtimoiy tarmoqlarda mashhur bo\'lgan muz kursi haqiqatda teriga nima qiladi — ilmiy javob.',
    sections: [
      ArticleSection(
        heading: 'Afsona: muz yuzni yaxshilaydi',
        body:
            'Ko\'pchilik muz surish teriga juda foyda qiladi deb o\'ylaydi — poralarni yopadi, yuzni yoshartiradi, ajinlarni yo\'qotadi deyishadi. Bu qisman to\'g\'ri, qisman esa butunlay noto\'g\'ri.',
      ),
      ArticleSection(
        heading: 'Haqiqat: nima foydali',
        body:
            'Sovuq ta\'sir qon tomir va shishlikni vaqtincha kamaytiradi — shu sababli ertalab ko\'z ostidagi shish tushadi. Yallig\'langan akne ustiga muz qo\'yish og\'riq va qizarishni bosadi. Sport yoki issiq havoda yuzni muzsiz suv yoki muz bilan sovutish yaxshi his beradi.',
      ),
      ArticleSection(
        heading: 'Haqiqat: nima zarar',
        body:
            'To\'g\'ridan-to\'g\'ri muz teri yuzasiga qo\'yilsa, sovuq kuyishi (frostbite) bo\'lishi mumkin — ayniqsa sezgir teriga. Poralar yopilmaydi — bu anatomik jihatdan imkonsiz, poralar mushak emas. Ajinlarni yo\'qotmaydi — bu faqat vaqtinchalik gullash effekti.',
      ),
      ArticleSection(
        heading: 'To\'g\'ri ishlatish yo\'li',
        body:
            'Muzni bevosita yuzga surmasdan, mato yoki soft bezga o\'rab ishlating. 1–2 daqiqadan ko\'p tutmang. Har kuni emas — haftada 2–3 marta yetarli. Sezgir va quruq teri uchun umuman tavsiya etilmaydi.',
      ),
    ],
  ),
  Article(
    icon: Icons.phone_android_outlined,
    iconColor: Color(0xFF3A6FE0),
    title: 'Telefon ko\'k nuri va teri: haqiqat nimada?',
    duration: '5 daqiqa',
    summary:
        'Telefon ekranidan chiqadigan ko\'k nur teringizni qarittira oladimi — tadqiqotlar nima deydi.',
    sections: [
      ArticleSection(
        heading: 'Ko\'k nur nima?',
        body:
            'Ko\'k nur (blue light / HEV nur) — quyosh nuri va barcha ekranlardan — telefon, kompyuter, televizordan chiqadi. Quyosh chiqaradigan ko\'k nur ekranga nisbatan yuzlab marta kuchliroq.',
      ),
      ArticleSection(
        heading: 'Afsona: telefon ko\'k nuri teringizni jiddiy qarittiradi',
        body:
            'Laboratoriya sharoitida juda yuqori ko\'k nur ta\'sirida pigmentatsiya kuzatilgan — lekin bu telefon ekranidan bo\'lgan 8 soatlik ta\'sirga teng emas. Haqiqiy hayotda telefon ekranidan teringizga zarar etishiga ilmiy dalil hozircha yo\'q.',
      ),
      ArticleSection(
        heading: 'Haqiqiy zarar: uyqu',
        body:
            'Telefon ko\'k nuri teringizni emas, uyqungizni buzadi. Ko\'k nur melatonin (uyqu gormoni) ajralishini to\'xtatadi. Bu uyquni qiyinlashtiradi — uyqu kam bo\'lsa teri to\'sig\'i zaiflanadi, kollagen kamayadi, akne kuchayadi. Ko\'k nurning asosiy zarar yo\'li shu.',
      ),
      ArticleSection(
        heading: 'Nima qilish kerak?',
        body:
            'Uxlashdan 1 soat oldin telefonni qo\'ying. Kechqurun ekranda "Night Mode" yoki sariq filtr yoqing. Ko\'k nurdan teri uchun maxsus krem sotib olish shart emas — bu reklamaviy gap. Asosiy himoya — uyquni tartibga solish.',
      ),
    ],
  ),
  Article(
    icon: Icons.self_improvement_outlined,
    iconColor: Color(0xFFA8478F),
    title: 'Teri qarishi haqida 6 afsona va haqiqat',
    duration: '6 daqiqa',
    summary:
        'Quyosh, stress, uyqu, his-tuyg\'ular va yosh ko\'rinish haqida keng tarqalgan noto\'g\'ri tushunchalar.',
    sections: [
      ArticleSection(
        heading: 'Afsona 1: Ko\'p kulish ajin tushiradi',
        body:
            'Haqiqat: kulish va mimika harakatlar vaqt o\'tishi bilan "mimika ajinlari" hosil qiladi — lekin bu normal va sog\'lom hayot belgisi. Kulmaslik ajin oldini olmaydi. Ajinlar asosan namlash, SPF va uyqu bilan kechiktiriladi.',
      ),
      ArticleSection(
        heading: 'Afsona 2: Quyoshda yurish terini "chiniqtiradi"',
        body:
            'Haqiqat: UV nur teri DNA sini shikastlaydi va bu jarayon to\'planadi. Kuniga 10 daqiqa quyosh ham zarar. Quyosh terini aslo chiniqtirmaydi — aksincha elastin va kollageni yo\'q qiladi, ajin va dog\'lar paydo bo\'ladi.',
      ),
      ArticleSection(
        heading: 'Afsona 3: Stressdan teri qarimaydi',
        body:
            'Haqiqat: surunkali stress kortizol darajasini oshiradi. Kortizol kollagen sintezini to\'xtatadi, yallig\'lanishni kuchaytiradi va teri to\'sig\'ini zaiflashtiradi. Stress teriga jiddiy ta\'sir qiladi — bu ilmiy isbotlangan.',
      ),
      ArticleSection(
        heading: 'Afsona 4: Ertaroq uxlash yosh ko\'rinish beradi',
        body:
            'Haqiqat: bu to\'g\'ri! Kech soat 22:00–02:00 oralig\'ida teri hujayralari eng tez yangilanadi. Kollagen ham asosan tunda ishlab chiqariladi. Shu sababli 7–9 soat, vaqtida uxlash terini rostdan yaxshilaydi.',
      ),
      ArticleSection(
        heading: 'Afsona 5: Ko\'p suv ichsang teri yangilanadi',
        body:
            'Haqiqat: suv teri uchun zarur, lekin mo\'l-ko\'l suv ichish ajin yo\'qotmaydi. Teri namligi asosan kremdan keladi, ichdan emas. Suv ichish umumiy salomatlik uchun yaxshi — lekin "8 stakan suv = yosh teri" afsonasi.',
      ),
      ArticleSection(
        heading: 'Afsona 6: Tabiiy teri qarishga yo\'l yo\'q',
        body:
            'Haqiqat: 80% teri qarishi tashqi sabablardan — quyosh, chekish, uyqusizlik, stress. Faqat 20% genetika. Demak, odatlarni to\'g\'rilash teri qarishi sur\'atini sezilarli kamaytiradi. Eng muhim 3 qadam: SPF, uyqu, namlash.',
      ),
    ],
  ),
];
