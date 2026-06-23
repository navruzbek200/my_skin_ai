import 'package:flutter/material.dart';
import '../models/article.dart';

// iconColor is set to the brand primary (0xFF7060AA) for all articles.
// Per-item colors are kept in the field for model compat but not used in UI.
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
    iconColor: Color(0xFF7060AA),
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
    iconColor: Color(0xFF7060AA),
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
    iconColor: Color(0xFF7060AA),
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
    iconColor: Color(0xFF7060AA),
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
];
