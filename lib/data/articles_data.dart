import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/data/sources_data.dart';

import '../models/article.dart';

// iconColor is each article's accent: it tints the icon and the "Maqola"
// label, and paints the bar down the left edge of the card. Pick something
// that belongs to the subject — sun amber for SPF, night indigo for sleep —
// so a list of eight white cards is scannable by colour before it is read.
// LessonStyles.readableAccent darkens the hue where it has to carry text, so
// a light pick here stays legible.

/// Reading times, held once so the same number is worded the same way in every
/// article.
const _read4 = LocalizedText('4 daqiqa', '4 минуты', '4 min');
const _read5 = LocalizedText('5 daqiqa', '5 минут', '5 min');
const _read6 = LocalizedText('6 daqiqa', '6 минут', '6 min');
const _read7 = LocalizedText('7 daqiqa', '7 минут', '7 min');
const _read8 = LocalizedText('8 daqiqa', '8 минут', '8 min');

const List<Article> articles = [
  Article(
    id: 'korean_routine',
    sources: Sources.koreanRoutine,
    icon: Icons.spa_outlined,
    iconColor: Color(0xFF7060AA),
    title: LocalizedText(
      'Koreya parvarish rutinasi: 10 qadam',
      'Корейский уход: 10 шагов',
      'The Korean routine: 10 steps',
    ),
    duration: _read5,
    summary: LocalizedText(
      'Koreya usuli terini bosqichma-bosqich parvarishlab, har bir qatlam keyingisining samaradorligini oshiradi.',
      'Корейский подход ухаживает за кожей поэтапно: каждый слой усиливает действие следующего.',
      'The Korean approach treats skin in stages, where each layer makes the next one work harder.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Nima uchun 10 qadam?',
          'Почему именно 10 шагов?',
          'Why ten steps?',
        ),
        body: LocalizedText(
          'Koreya parvarish falsafasi "kamroq qilmoq" emas, balki "to\'g\'ri qilmoq" prinsipiga asoslanadi. Har bir qadam oldingi qadamning effektini kuchaytiradi — bu kumulyativ ta\'sir yaratadi va vaqt o\'tishi bilan terini tubdan yaxshilaydi.',
          'Корейская философия ухода строится не на принципе «делать меньше», а на принципе «делать правильно». Каждый шаг усиливает эффект предыдущего — так возникает накопительный эффект, который со временем меняет кожу по-настоящему.',
          'The Korean philosophy is not "do less" but "do it right". Each step amplifies the one before it — that is what builds a cumulative effect and genuinely changes the skin over time.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Tozalash qadamlari (1–4)',
          'Шаги очищения (1–4)',
          'The cleansing steps (1–4)',
        ),
        body: LocalizedText(
          '1. Yog\' asosidagi klenzor — tashqi iflosliklarni eritadi. 2. Ko\'pik yoki gel klenzor — suvda eriydigan qoldiqlarni tozalaydi. 3. Eksfoluatsiya (haftada 2–3 marta) — o\'lik hujayralarni olib tashlaydi. 4. Tonik — teri pH ini tiklaydi va keyingi qadamlarni tayyorlaydi.',
          '1. Гидрофильное масло — растворяет то, что осело на коже за день. 2. Пенка или гель — смывает водорастворимые остатки. 3. Эксфолиация (2–3 раза в неделю) — убирает отмершие клетки. 4. Тоник — восстанавливает pH и готовит кожу к следующим шагам.',
          '1. An oil cleanser — dissolves what has settled on the skin during the day. 2. A foam or gel cleanser — washes off what is water-soluble. 3. Exfoliation (two or three times a week) — lifts away dead cells. 4. Toner — resets the pH and prepares the skin for what follows.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Serum va intensiv parvarishlar (5–7)',
          'Сыворотки и интенсивный уход (5–7)',
          'Serums and intensive care (5–7)',
        ),
        body: LocalizedText(
          '5. Esentsiya — yengil, suvsimon tekstura, teriga namlik beradi. 6. Ampula yoki serum — maqsadli ta\'sir: pigmentatsiya, ajinlar, akne. 7. Varaq maska (haftada 1–2 marta) — intensiv parvarish seansi.',
          '5. Эссенция — лёгкая водянистая текстура, даёт коже влагу. 6. Ампула или сыворотка — точечная работа: пигментация, морщины, высыпания. 7. Тканевая маска (1–2 раза в неделю) — сеанс интенсивного ухода.',
          '5. Essence — a light, watery texture that puts moisture into the skin. 6. An ampoule or serum — the targeted work: pigmentation, lines, breakouts. 7. A sheet mask (once or twice a week) — an intensive session.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Yakunlovchi qadamlar (8–10)',
          'Завершающие шаги (8–10)',
          'The finishing steps (8–10)',
        ),
        body: LocalizedText(
          '8. Ko\'z kremi — nozik ko\'z atrofi terisi uchun maxsus formula. 9. Namlagich — barcha faol ingrediyentlarni "qulflaydi". 10. SPF (ertalab) yoki uyqu maskasi (kechasi) — muhofaza yoki intensiv tiklash.',
          '8. Крем для век — отдельная формула для тонкой кожи вокруг глаз. 9. Увлажнитель — «запечатывает» все активные ингредиенты. 10. SPF (утром) или ночная маска (вечером) — защита или интенсивное восстановление.',
          '8. Eye cream — a separate formula for the thin skin around the eyes. 9. Moisturiser — seals every active in. 10. SPF (morning) or a sleeping mask (night) — protection or intensive repair.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Barchasini bajarishim shartmi?',
          'Обязательно ли делать все шаги?',
          'Do I have to do all of them?',
        ),
        body: LocalizedText(
          'Yo\'q. 10 qadam maqsad emas, manba. O\'zingizga eng mos 3–5 qadamni tanlashingiz mumkin. Muhim asoslar: tozalash, namlash va SPF. Qolganlarni ehtiyojingizga qarab qo\'shing.',
          'Нет. Десять шагов — это не цель, а меню. Можно выбрать 3–5, которые подходят именно вам. Обязательная база: очищение, увлажнение и SPF. Остальное добавляйте по потребности.',
          'No. The ten steps are a menu, not a target. Pick the three to five that suit you. The non-negotiable base is cleanse, moisturise and SPF. Add the rest as you need them.',
        ),
      ),
    ],
  ),
  Article(
    id: 'natural_ingredients',
    icon: Icons.eco_outlined,
    iconColor: Color(0xFF2E9E6B),
    title: LocalizedText(
      'Tabiiy ingrediyentlar qanday ishlaydi?',
      'Как работают натуральные ингредиенты?',
      'How natural ingredients actually work',
    ),
    duration: _read7,
    sources: Sources.naturalIngredientsArticle,
    summary: LocalizedText(
      'O\'simlik ekstraktlari va tabiiy birikmalar teri uchun qanday harakat qilishi — kimyo va biologiya orqali tushuntiriladi.',
      'Что растительные экстракты и натуральные соединения делают с кожей — объяснение через химию и биологию.',
      'What plant extracts and natural compounds do to skin — explained through chemistry and biology.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          '"Tabiiy" so\'zi nima anglatadi?',
          'Что значит слово «натуральный»?',
          'What "natural" actually means',
        ),
        body: LocalizedText(
          'Mahsulot qutisidagi "tabiiy" yozuvi hech qanday yuridik ta\'rifga ega emas. Haqiqiy tabiiy ingrediyentlar o\'simlik, mineral yoki biotexnologiya yo\'li bilan olingan birikmalar bo\'lib, ularning samaradorligi klinik sinovlarda isbotlanishi kerak.',
          'Надпись «натуральный» на упаковке не имеет юридического определения. Настоящие натуральные ингредиенты — это соединения растительного, минерального или биотехнологического происхождения, эффективность которых должна быть подтверждена клинически.',
          'The word "natural" on a box has no legal definition. Genuinely natural ingredients are compounds derived from plants, minerals or biotechnology, and their effectiveness still has to be shown in clinical testing.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Eng kuchli tabiiy ingrediyentlar',
          'Самые сильные натуральные ингредиенты',
          'The strongest natural ingredients',
        ),
        body: LocalizedText(
          'Niatsinamid (B3 vitamini) — yallig\'lanishga qarshi ta\'sir. Tokoferol (E vitamini) — antioksidant va himoya. Retinol (A vitamini) — hujayralar yangilanishi. Askorbat kislota (C vitamini) — kollagen sintezi. Aloe vera — namlash va tinchlantirish.',
          'Ниацинамид (витамин B3) — противовоспалительное действие. Токоферол (витамин E) — антиоксидант и защита. Ретинол (витамин A) — обновление клеток. Аскорбиновая кислота (витамин C) — синтез коллагена. Алоэ вера — увлажнение и успокоение.',
          'Niacinamide (vitamin B3) — anti-inflammatory. Tocopherol (vitamin E) — antioxidant and protective. Retinol (vitamin A) — cell renewal. Ascorbic acid (vitamin C) — collagen synthesis. Aloe vera — hydration and calm.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Fitokimyoviy birikmalar',
          'Фитохимические соединения',
          'Phytochemical compounds',
        ),
        body: LocalizedText(
          'Polifenollar (yashil choy, uzum urug\'i) — hujayra zararini kamaytiradi. Karotenoidlar (sabzi, suvo\'tlar) — fotohimoya uchun o\'rganilayotgan antioksidantlar. Flavonoidlar (likoris) — giperpigmentatsiyani kamaytiradi.',
          'Полифенолы (зелёный чай, виноградная косточка) — снижают повреждение клеток. Каротиноиды (морковь, водоросли) — антиоксиданты, которые изучаются как средство фотозащиты. Флавоноиды (солодка) — уменьшают гиперпигментацию.',
          'Polyphenols (green tea, grape seed) — reduce cell damage. Carotenoids (carrot, algae) — antioxidants studied for photoprotection. Flavonoids (licorice) — reduce hyperpigmentation.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          '"Tabiiy" = xavfsiz degan yanglishish',
          'Заблуждение: «натуральный» значит «безопасный»',
          'The "natural means safe" mistake',
        ),
        body: LocalizedText(
          'Ko\'pgina tabiiy ingrediyentlar kuchli allergen bo\'lishi mumkin: lavanda moyi va boshqa efir moylari. Sezgir teri uchun "toza" yoki "organik" mahsulotlar ham muammo keltirib chiqarishi mumkin. Har doim patch-test o\'tkazing.',
          'Многие натуральные ингредиенты — сильные аллергены: масло лаванды и другие эфирные масла. Для чувствительной кожи «чистые» и «органические» средства тоже могут стать проблемой. Всегда делайте пэтч-тест.',
          'Plenty of natural ingredients are strong allergens: lavender oil and other essential oils. For sensitive skin, "clean" and "organic" products cause just as much trouble. Always patch test.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Eng yaxshi yondashuv',
          'Лучший подход',
          'The best approach',
        ),
        body: LocalizedText(
          'Ilmiy asoslangan ingrediyentlarni tanlang: niatsinamid, gialuron kislota, arbutin, retinol — ularning ta\'siri klinik tadqiqotlarda o\'rganilgan. Reklamaga emas, tekshirilgan tarkibga e\'tibor bering.',
          'Выбирайте ингредиенты с доказательной базой: ниацинамид, гиалуроновая кислота, арбутин, ретинол — их действие изучено в клинических исследованиях. Смотрите на состав, а не на рекламу.',
          'Choose ingredients with evidence behind them: niacinamide, hyaluronic acid, arbutin, retinol — all studied in clinical trials. Read the ingredient list, not the advertising.',
        ),
      ),
    ],
  ),
  Article(
    id: 'spf_guide',
    sources: Sources.sunscreen,
    icon: Icons.wb_sunny_outlined,
    iconColor: Color(0xFFE08A1E),
    title: LocalizedText(
      'SPF haqida bilishingiz kerak bo\'lgan hamma narsa',
      'Всё, что нужно знать про SPF',
      'Everything you need to know about SPF',
    ),
    duration: _read4,
    summary: LocalizedText(
      'SPF omili qanday ishlashi, qaysi raqamni tanlash va to\'g\'ri ishlatish — amaliy qo\'llanma.',
      'Как работает фактор SPF, какое число выбрать и как правильно наносить — практическое руководство.',
      'How the SPF number works, which one to pick and how to apply it — a practical guide.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText('SPF nima?', 'Что такое SPF?', 'What is SPF?'),
        body: LocalizedText(
          'Sun Protection Factor — quyosh nurlaridan himoya ko\'rsatkichidir. SPF 30 UVB nurlarining 97% ini, SPF 50 esa 98% ini to\'sadi. Raqam qanchalik yuqori bo\'lsa, farq shunchalik kichik — SPF 50 dan yuqorisida amaliy farq deyarli yo\'q.',
          'Sun Protection Factor — показатель защиты от солнечных лучей. SPF 30 задерживает 97% лучей UVB, SPF 50 — 98%. Чем выше число, тем меньше разница: выше SPF 50 практической разницы почти нет.',
          'Sun Protection Factor is a measure of how much sunlight is blocked. SPF 30 stops 97% of UVB, SPF 50 stops 98%. The higher the number the smaller the gain — above SPF 50 there is barely a practical difference.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Kimyoviy va mineral SPF',
          'Химические и минеральные фильтры',
          'Chemical and mineral filters',
        ),
        body: LocalizedText(
          'Kimyoviy filtrlar (avobenzon, oxybenzon) UV nurlarini energiyaga aylantiradi. Mineral filtrlar (rux oksidi, titan dioksid) nurlarni qaytaradi. Mineral SPF sezgir teri uchun yaxshiroq, lekin oq iz qoldirishi mumkin. Hybrid variantlar ikkalasining afzalliklarini birlashtiradi.',
          'Химические фильтры (авобензон, оксибензон) преобразуют UV в энергию. Минеральные (оксид цинка, диоксид титана) отражают лучи. Минеральный SPF лучше для чувствительной кожи, но может оставлять белый след. Гибридные формулы объединяют плюсы обоих.',
          'Chemical filters (avobenzone, oxybenzone) convert UV into energy. Mineral filters (zinc oxide, titanium dioxide) reflect it. Mineral SPF suits sensitive skin better but can leave a white cast. Hybrid formulas combine the strengths of both.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Qancha surish kerak?',
          'Сколько наносить?',
          'How much to apply',
        ),
        body: LocalizedText(
          'Dermatologlar yuzga taxminan 2 barmoq uzunligidagi iz — ya\'ni chorak choy qoshiq — SPF surish kerakligini aytadi. Ko\'pchilik bu miqdorning 25–50% ini qo\'llaydi, bu esa himoya darajasini keskin kamaytiradi.',
          'Дерматологи рекомендуют на лицо полоску длиной в два пальца — примерно четверть чайной ложки. Большинство наносит 25–50% от этого количества, и уровень защиты резко падает.',
          'Dermatologists recommend a strip the length of two fingers for the face — about a quarter of a teaspoon. Most people use a quarter to half of that, and the protection drops sharply as a result.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Qachon va qancha tez-tez yangilash kerak?',
          'Когда и как часто обновлять?',
          'When and how often to reapply',
        ),
        body: LocalizedText(
          'Tashqarida har 2 soatda yangilash zarur. Suv yoki terlaganingizdan keyin darhol yangilang. Kun davomida uyda bo\'lsangiz ham — deraza orqali UVA nurlari o\'tadi. Ertalab bir marta surish yetarli emas.',
          'На улице — каждые 2 часа. Сразу после воды или если вспотели. Даже если вы весь день дома: UVA проходит сквозь окно. Одного нанесения утром недостаточно.',
          'Outdoors, every two hours. Immediately after water or sweating. Even indoors all day — UVA passes through glass. One application in the morning is not enough.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Makiyaj ostida SPF',
          'SPF под макияжем',
          'SPF under makeup',
        ),
        body: LocalizedText(
          'SPFni namlagichdan so\'ng, toningdan oldin surting. Poudra yoki tonik ichidagi SPF asosiy himoya vazifasini bajarmaydi — u faqat qo\'shimcha. Kun ichida to\'ldirish uchun SPF spreyi qulay.',
          'Наносите SPF после увлажнителя и до тонального. SPF в пудре или тональном — не основная защита, а только дополнение. Для обновления в течение дня удобен спрей с SPF.',
          'Apply SPF after your moisturiser and before foundation. The SPF in a powder or a foundation is a supplement, not your main protection. An SPF spray is the easiest way to top up during the day.',
        ),
      ),
    ],
  ),
  Article(
    id: 'sleep',
    sources: Sources.sleepArticle,
    icon: Icons.bedtime_outlined,
    iconColor: Color(0xFF4C4B9E),
    title: LocalizedText(
      'Uyqu va teri sog\'ligi orasidagi bog\'liqlik',
      'Связь между сном и здоровьем кожи',
      'The link between sleep and skin health',
    ),
    duration: _read6,
    summary: LocalizedText(
      'Tungi uyquda teri qanday tiklanadi va uyqu tanqisligi teri holatiga qanday ta\'sir qiladi — ilmiy dalillar bilan.',
      'Как кожа восстанавливается во сне и что с ней происходит при недосыпе — с опорой на исследования.',
      'How skin repairs itself overnight and what happens to it when you do not sleep — with the evidence.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Teri tungi tiklanish rejimida',
          'Кожа в ночном режиме восстановления',
          'Skin in overnight repair mode',
        ),
        body: LocalizedText(
          "Uyqu paytida organizm tiklanish jarayonlarini faollashtiradi. Tadqiqotlar yomon uyquni terining to'siq funksiyasi sekinroq tiklanishi va qarish belgilari bilan bog'laydi — shu sababli \"go'zallik uyqusi\" asossiz emas.",
          "Во сне организм активнее запускает восстановительные процессы. Исследования связывают плохой сон с более медленным восстановлением барьера кожи и более заметными признаками старения — так что у «сна красоты» есть основания.",
          "Sleep is when the body runs more of its repair processes. Studies link poor sleep with slower recovery of the skin barrier and more visible signs of ageing — so \"beauty sleep\" is not just a saying.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Uyqu tanqisligi teri holatini yomonlashtiradi',
          'Недосып ухудшает состояние кожи',
          'Sleep debt makes skin worse',
        ),
        body: LocalizedText(
          "Uyqu yetishmasligi stress gormoni kortizolni oshiradi, bu esa yallig'lanishni kuchaytirib, husnbuzarlarni og'irlashtirishi mumkin. Yomon uxlaydiganlarda teri namlikni tezroq yo'qotadi va to'siq sekinroq tiklanadi.",
          "Недосып повышает уровень кортизола (гормона стресса), что может усиливать воспаление и высыпания. У тех, кто плохо спит, кожа быстрее теряет влагу, а барьер восстанавливается медленнее.",
          "Sleep debt raises cortisol, the stress hormone, which can fuel inflammation and breakouts. In poor sleepers, skin loses water faster and the barrier recovers more slowly.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Ideal uyqu muhiti',
          'Идеальные условия для сна',
          'The ideal sleeping environment',
        ),
        body: LocalizedText(
          "Salqin, qorong'i va jim xona yaxshi uyquga yordam beradi. Juda quruq havo teri namligini tortib olishi mumkin — isitish mavsumida havo namlagichi foydali. Uxlashdan oldin telefonni chetga qo'ying: kechki ekran nuri uyquga ketishni qiyinlashtiradi.",
          "Прохладная, тёмная и тихая комната помогает крепкому сну. Очень сухой воздух может вытягивать влагу из кожи — в отопительный сезон пригодится увлажнитель воздуха. Перед сном уберите телефон: вечерний свет экрана мешает заснуть.",
          "A cool, dark, quiet room helps you sleep well. Very dry air can draw moisture out of the skin — a humidifier helps in heating season. Put the phone away before bed: evening screen light makes it harder to fall asleep.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Kechki parvarishni optimallashtirish',
          'Как выстроить вечерний уход',
          'Getting the evening routine right',
        ),
        body: LocalizedText(
          'Tungi parvarish ertalabkidan farq qilishi kerak: retinol, kislotalar va kuchliroq serumlar kechasi ishlating — ular fotosensitivlik beradi va tungi tiklanish jarayoni bilan sinergiyada ishlaydi. Kechki namlagich teri bariyerini tiklashda yordam beradi.',
          'Вечерний уход должен отличаться от утреннего: ретинол, кислоты и более сильные сыворотки — на ночь. Они дают фоточувствительность и работают в синергии с ночным восстановлением. Ночной увлажнитель помогает восстановить барьер.',
          'The evening routine should differ from the morning one: retinol, acids and stronger serums belong at night. They cause photosensitivity and work in synergy with overnight repair. A night moisturiser helps rebuild the barrier.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Amaliy maslahatlar',
          'Практические советы',
          'Practical advice',
        ),
        body: LocalizedText(
          'Uxlashdan 1 soat oldin parvarishni bajaring — ingrediyentlarga shimib olish uchun vaqt beradi. Har kuni bir xil vaqtda yoting — sikadiyat ritm tartibli bo\'lsa, teri tiklanishi yanada samaraliroq bo\'ladi. Maqsad: kuniga 7–9 soat sifatli uyqu.',
          'Делайте уход за час до сна — так у ингредиентов есть время впитаться. Ложитесь в одно и то же время: при налаженном циркадном ритме восстановление кожи идёт эффективнее. Цель — 7–9 часов качественного сна.',
          'Do your routine an hour before bed so the ingredients have time to absorb. Go to sleep at the same time each night — a settled circadian rhythm makes skin repair more effective. Aim for seven to nine hours of good sleep.',
        ),
      ),
    ],
  ),
  Article(
    id: 'diet_acne',
    sources: Sources.dietAcneArticle,
    icon: Icons.restaurant_outlined,
    iconColor: Color(0xFFD2553F),
    title: LocalizedText(
      'Ovqatlanish va akne: ilmiy aloqa',
      'Питание и высыпания: что говорит наука',
      'Diet and acne: what the science says',
    ),
    duration: _read8,
    summary: LocalizedText(
      'Qaysi ovqatlar akneyi kuchaytirishi va qaysi birikmalar terini ichdan parvarishlashi — tadqiqotlarga asoslangan qo\'llanma.',
      'Какие продукты усиливают высыпания и какие вещества питают кожу изнутри — руководство на основе исследований.',
      'Which foods make breakouts worse and which nutrients feed the skin from the inside — a guide grounded in research.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Ovqat va akne aloqasi haqiqatmi?',
          'Действительно ли еда влияет на высыпания?',
          'Is the food–acne link real?',
        ),
        body: LocalizedText(
          'Uzoq vaqt dermatologlar ovqat va akne orasidagi aloqani rad etishgan. Ammo oxirgi 20 yil ichida o\'tkazilgan ko\'plab tadqiqotlar bu aloqa haqiqiy ekanligini ko\'rsatdi — ayniqsa glikemik indeksi yuqori ozuqalar va sut mahsulotlari bilan bog\'liqda.',
          'Долгое время дерматологи отрицали связь между едой и высыпаниями. Но за последние 20 лет множество исследований показало, что связь реальна — особенно с продуктами с высоким гликемическим индексом и молочными продуктами.',
          'For a long time dermatologists denied any link between food and acne. But over the past twenty years a large body of research has shown the link is real — particularly with high-glycaemic foods and dairy.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Akneni kuchaytiruvchi ovqatlar',
          'Продукты, усиливающие высыпания',
          'Foods that make breakouts worse',
        ),
        body: LocalizedText(
          "Tadqiqotlar yuqori glikemik indeksli ozuqalar (oq non, gazlangan ichimliklar, shirinliklar) bilan husnbuzarlar o'rtasida bog'liqlik topgan. Ba'zi odamlarda sut, ayniqsa yog'siz sut ham toshmalarni kuchaytirishi mumkin. Bu bog'liqlik hamma uchun bir xil emas.",
          "Исследования находят связь между продуктами с высоким гликемическим индексом (белый хлеб, газировка, сладости) и высыпаниями. У части людей высыпания может усиливать и молоко, особенно обезжиренное. У всех эта связь проявляется по-разному.",
          "Research has found a link between high-glycaemic foods (white bread, fizzy drinks, sweets) and breakouts. In some people, milk — skimmed milk especially — can make breakouts worse too. The link is not the same for everyone.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Teri uchun foydali ozuqalar',
          'Что полезно для кожи',
          'What is good for skin',
        ),
        body: LocalizedText(
          "Muvozanatli ovqatlanish — ko'p sabzavot, meva, baliq va dukkaklilar — umumiy teri salomatligini qo'llab-quvvatlaydi. Hech bir mahsulot yoki qo'shimcha husnbuzarni o'zi davolamaydi; faol husnbuzarlarda dermatolog bilan maslahatlashing.",
          "Сбалансированное питание — много овощей, фруктов, рыбы и бобовых — поддерживает общее здоровье кожи. Ни один продукт или добавка сами по себе не лечат высыпания; при активных высыпаниях посоветуйтесь с дерматологом.",
          "A balanced diet — plenty of vegetables, fruit, fish and pulses — supports overall skin health. No single food or supplement treats acne on its own; for active breakouts, talk to a dermatologist.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Suv ichish va teri',
          'Вода и кожа',
          'Water and skin',
        ),
        body: LocalizedText(
          'Ko\'proq suv ichish akneyi bevosita bartaraf etmaydi, lekin teri namligini va toksinlar chiqarilishini qo\'llab-quvvatlaydi. Kuniga 2–2,5 litr suv (jismoniy faollik va ob-havoga qarab) terini umumiy salomatlikda ushlab turadi.',
          'Больше воды не убирает высыпания напрямую, но поддерживает увлажнённость кожи и выведение продуктов обмена. 2–2,5 литра в день (с поправкой на активность и погоду) держат кожу в общем здоровом состоянии.',
          'Drinking more water does not clear acne by itself, but it supports skin hydration and the body\'s clearance of waste. Two to two and a half litres a day — adjusted for activity and weather — keeps skin in generally good shape.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Amaliy yondashuv',
          'Практический подход',
          'A practical approach',
        ),
        body: LocalizedText(
          'Ovqat jurnali yuritib, qaysi ovqatlardan keyin akne avj olishini kuzating. Shakar va sut mahsulotlarini 4 hafta kamaytiring va teri holatini kuzating. Ovqatlanish o\'zgarishi 8–12 haftada sezilarli natija beradi.',
          'Ведите пищевой дневник и отслеживайте, после чего высыпания усиливаются. Сократите сахар и молочные продукты на 4 недели и посмотрите на кожу. Изменения в питании дают заметный результат за 8–12 недель.',
          'Keep a food diary and note what your skin does afterwards. Cut back sugar and dairy for four weeks and watch what happens. Dietary changes show a clear result in eight to twelve weeks.',
        ),
      ),
    ],
  ),
  Article(
    id: 'ice',
    sources: Sources.iceArticle,
    icon: Icons.ac_unit_outlined,
    iconColor: Color(0xFF2196A5),
    title: LocalizedText(
      'Yuzga muz surish: foyda yoki zarar?',
      'Лёд для лица: польза или вред?',
      'Icing your face: helpful or harmful?',
    ),
    duration: _read4,
    summary: LocalizedText(
      'Ijtimoiy tarmoqlarda mashhur bo\'lgan muz kursi haqiqatda teriga nima qiladi — ilmiy javob.',
      'Что на самом деле делает с кожей популярный в соцсетях лёд — научный ответ.',
      'What the social-media ice trend actually does to skin — the scientific answer.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Afsona: muz yuzni yaxshilaydi',
          'Миф: лёд улучшает кожу лица',
          'The myth: ice improves your face',
        ),
        body: LocalizedText(
          'Ko\'pchilik muz surish teriga juda foyda qiladi deb o\'ylaydi — poralarni yopadi, yuzni yoshartiradi, ajinlarni yo\'qotadi deyishadi. Bu qisman to\'g\'ri, qisman esa butunlay noto\'g\'ri.',
          'Многие считают, что лёд очень полезен для кожи: якобы закрывает поры, омолаживает лицо, убирает морщины. Отчасти это правда, отчасти — полная неправда.',
          'A lot of people believe ice is great for skin: that it closes pores, rejuvenates the face, removes wrinkles. Part of that is true and part of it is simply wrong.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Haqiqat: nima foydali',
          'Правда: что помогает',
          'The truth: what helps',
        ),
        body: LocalizedText(
          'Sovuq ta\'sir qon tomir va shishlikni vaqtincha kamaytiradi — shu sababli ertalab ko\'z ostidagi shish tushadi. Yallig\'langan akne ustiga muz qo\'yish og\'riq va qizarishni bosadi. Sport yoki issiq havoda yuzni muzsiz suv yoki muz bilan sovutish yaxshi his beradi.',
          'Холод временно сужает сосуды и уменьшает отёк — поэтому утром спадает припухлость под глазами. Лёд на воспалённый прыщ снимает боль и красноту. После спорта или в жару охладить лицо холодной водой или льдом просто приятно.',
          'Cold temporarily constricts blood vessels and reduces swelling — which is why morning under-eye puffiness goes down. Ice on an inflamed spot dulls the pain and the redness. After sport or in the heat, cooling the face down simply feels good.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Haqiqat: nima zarar',
          'Правда: что вредит',
          'The truth: what harms',
        ),
        body: LocalizedText(
          'To\'g\'ridan-to\'g\'ri muz teri yuzasiga qo\'yilsa, sovuq kuyishi (frostbite) bo\'lishi mumkin — ayniqsa sezgir teriga. Poralar yopilmaydi — bu anatomik jihatdan imkonsiz, poralar mushak emas. Ajinlarni yo\'qotmaydi — bu faqat vaqtinchalik gullash effekti.',
          'Лёд, приложенный прямо к коже, может вызвать холодовой ожог — особенно на чувствительной коже. Поры не закрываются: анатомически это невозможно, у пор нет мышц. Морщины не исчезают — это лишь временный эффект.',
          'Ice held straight against skin can cause a cold burn, especially on sensitive skin. Pores do not close — anatomically they cannot, since they have no muscle. Wrinkles do not go away — that is only a temporary effect.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'To\'g\'ri ishlatish yo\'li',
          'Как делать правильно',
          'How to do it properly',
        ),
        body: LocalizedText(
          'Muzni bevosita yuzga surmasdan, mato yoki soft bezga o\'rab ishlating. 1–2 daqiqadan ko\'p tutmang. Har kuni emas — haftada 2–3 marta yetarli. Sezgir va quruq teri uchun umuman tavsiya etilmaydi.',
          'Не прикладывайте лёд прямо к лицу — заверните в ткань или мягкую салфетку. Держите не дольше 1–2 минут. Не каждый день: 2–3 раза в неделю достаточно. Для чувствительной и сухой кожи не рекомендуется вовсе.',
          'Never put ice straight on the face — wrap it in cloth or a soft pad. Hold it for no more than a minute or two. Not daily: two or three times a week is plenty. For sensitive and dry skin, not recommended at all.',
        ),
      ),
    ],
  ),
  Article(
    id: 'blue_light',
    sources: Sources.blueLightArticle,
    icon: Icons.phone_android_outlined,
    iconColor: Color(0xFF3A6FE0),
    title: LocalizedText(
      'Telefon ko\'k nuri va teri: haqiqat nimada?',
      'Синий свет телефона и кожа: где правда?',
      'Phone blue light and skin: what is true?',
    ),
    duration: _read5,
    summary: LocalizedText(
      'Telefon ekranidan chiqadigan ko\'k nur teringizni qarittira oladimi — tadqiqotlar nima deydi.',
      'Может ли синий свет экрана состарить кожу — что говорят исследования.',
      'Can the blue light from your screen age your skin — what the research says.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Ko\'k nur nima?',
          'Что такое синий свет?',
          'What is blue light?',
        ),
        body: LocalizedText(
          'Ko\'k nur (blue light / HEV nur) — quyosh nuri va barcha ekranlardan — telefon, kompyuter, televizordan chiqadi. Quyosh chiqaradigan ko\'k nur ekranga nisbatan yuzlab marta kuchliroq.',
          'Синий свет (blue light / HEV) исходит и от солнца, и от всех экранов — телефона, компьютера, телевизора. От солнца его в сотни раз больше, чем от экрана.',
          'Blue light (HEV light) comes from the sun and from every screen — phone, computer, television. The sun puts out hundreds of times more of it than a screen does.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona: telefon ko\'k nuri teringizni jiddiy qarittiradi',
          'Миф: синий свет телефона серьёзно старит кожу',
          'The myth: phone blue light seriously ages your skin',
        ),
        body: LocalizedText(
          'Laboratoriya sharoitida juda yuqori ko\'k nur ta\'sirida pigmentatsiya kuzatilgan — lekin bu telefon ekranidan bo\'lgan 8 soatlik ta\'sirga teng emas. Haqiqiy hayotda telefon ekranidan teringizga zarar etishiga ilmiy dalil hozircha yo\'q.',
          'В лаборатории при очень высокой дозе синего света наблюдали пигментацию — но это не то же самое, что 8 часов у экрана телефона. Научных доказательств вреда кожи от экрана в реальной жизни пока нет.',
          'In the lab, very high doses of blue light did produce pigmentation — but that is not the same as eight hours in front of a phone. There is no evidence yet that a screen damages skin in real life.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Haqiqiy zarar: uyqu',
          'Реальный вред — это сон',
          'The real harm: your sleep',
        ),
        body: LocalizedText(
          'Telefon ko\'k nuri teringizni emas, uyqungizni buzadi. Ko\'k nur melatonin (uyqu gormoni) ajralishini to\'xtatadi. Bu uyquni qiyinlashtiradi — uyqu kam bo\'lsa teri to\'sig\'i zaiflanadi, kollagen kamayadi, akne kuchayadi. Ko\'k nurning asosiy zarar yo\'li shu.',
          'Синий свет телефона портит не кожу, а сон. Он подавляет выработку мелатонина (гормона сна). Засыпать сложнее — а при недосыпе слабеет барьер кожи, падает коллаген, усиливаются высыпания. Вот главный путь вреда.',
          'Phone blue light does not damage your skin, it damages your sleep. It suppresses melatonin, the sleep hormone. Falling asleep gets harder — and with less sleep the barrier weakens, collagen drops and breakouts get worse. That is the real route of harm.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Nima qilish kerak?',
          'Что делать?',
          'What to do',
        ),
        body: LocalizedText(
          'Uxlashdan 1 soat oldin telefonni qo\'ying. Kechqurun ekranda "Night Mode" yoki sariq filtr yoqing. Ko\'k nurdan teri uchun maxsus krem sotib olish shart emas — bu reklamaviy gap. Asosiy himoya — uyquni tartibga solish.',
          'Убирайте телефон за час до сна. Вечером включайте «ночной режим» или жёлтый фильтр. Покупать специальный крем «от синего света» не нужно — это маркетинг. Главная защита — наладить сон.',
          'Put the phone away an hour before bed. Switch on Night Mode or a warm filter in the evening. You do not need a special "blue light" cream — that is marketing. The real protection is fixing your sleep.',
        ),
      ),
    ],
  ),
  Article(
    id: 'ageing_myths',
    sources: Sources.ageingMythsArticle,
    icon: Icons.self_improvement_outlined,
    iconColor: Color(0xFFA8478F),
    title: LocalizedText(
      'Teri qarishi haqida 6 afsona va haqiqat',
      '6 мифов о старении кожи и правда',
      'Six myths about skin ageing, and the truth',
    ),
    duration: _read6,
    summary: LocalizedText(
      'Quyosh, stress, uyqu, his-tuyg\'ular va yosh ko\'rinish haqida keng tarqalgan noto\'g\'ri tushunchalar.',
      'Распространённые заблуждения про солнце, стресс, сон, эмоции и молодой вид.',
      'The common misconceptions about sun, stress, sleep, emotion and looking young.',
    ),
    sections: [
      ArticleSection(
        heading: LocalizedText(
          'Afsona 1: Ko\'p kulish ajin tushiradi',
          'Миф 1: от смеха появляются морщины',
          'Myth 1: smiling gives you wrinkles',
        ),
        body: LocalizedText(
          'Haqiqat: kulish va mimika harakatlar vaqt o\'tishi bilan "mimika ajinlari" hosil qiladi — lekin bu normal va sog\'lom hayot belgisi. Kulmaslik ajin oldini olmaydi. Ajinlar asosan namlash, SPF va uyqu bilan kechiktiriladi.',
          'Правда: смех и мимика со временем формируют мимические морщины — но это нормальный признак живой, здоровой жизни. Не улыбаться — не профилактика. Морщины откладывают увлажнение, SPF и сон.',
          'The truth: smiling and expression do create expression lines over time — but that is a normal sign of a lived-in, healthy life. Not smiling is not prevention. What delays lines is hydration, SPF and sleep.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona 2: Quyoshda yurish terini "chiniqtiradi"',
          'Миф 2: солнце «закаляет» кожу',
          'Myth 2: sun exposure "toughens" the skin',
        ),
        body: LocalizedText(
          'Haqiqat: UV nur teri DNA sini shikastlaydi va bu jarayon to\'planadi. Kuniga 10 daqiqa quyosh ham zarar. Quyosh terini aslo chiniqtirmaydi — aksincha elastin va kollageni yo\'q qiladi, ajin va dog\'lar paydo bo\'ladi.',
          'Правда: UV повреждает ДНК кожи, и это накапливается. Даже 10 минут на солнце в день не проходят бесследно. Солнце кожу не закаляет — наоборот, разрушает эластин и коллаген, а следом появляются морщины и пятна.',
          'The truth: UV damages skin DNA and the damage accumulates. Even ten minutes a day counts. Sun does not toughen skin — it destroys elastin and collagen, and lines and spots follow.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona 3: Stressdan teri qarimaydi',
          'Миф 3: стресс не старит кожу',
          'Myth 3: stress does not age skin',
        ),
        body: LocalizedText(
          'Haqiqat: surunkali stress kortizol darajasini oshiradi. Kortizol kollagen sintezini to\'xtatadi, yallig\'lanishni kuchaytiradi va teri to\'sig\'ini zaiflashtiradi. Stress teriga jiddiy ta\'sir qiladi — bu ilmiy isbotlangan.',
          'Правда: хронический стресс поднимает кортизол. Кортизол останавливает синтез коллагена, усиливает воспаление и ослабляет барьер кожи. Стресс серьёзно влияет на кожу — это доказано.',
          'The truth: chronic stress raises cortisol. Cortisol halts collagen synthesis, drives inflammation and weakens the barrier. Stress affects skin seriously, and that is well established.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona 4: Ertaroq uxlash yosh ko\'rinish beradi',
          'Миф 4: ранний отбой делает кожу моложе',
          'Myth 4: going to bed early makes you look younger',
        ),
        body: LocalizedText(
          "Haqiqat: qisman to'g'ri. Yetarli va muntazam uyqu (kattalarga 7–9 soat) terining tiklanishiga yordam beradi, surunkali uyqusizlik esa qarish belgilari bilan bog'liq. Eng muhimi — uyqu davomiyligi va muntazamligi.",
          "Правда: отчасти верно. Достаточный и регулярный сон (взрослым 7–9 часов) помогает восстановлению кожи, а хронический недосып связан с признаками старения. Важнее всего продолжительность и регулярность сна.",
          "The truth: partly right. Enough regular sleep (seven to nine hours for adults) helps the skin recover, and chronic sleep loss is linked with signs of ageing. What matters most is how long and how regularly you sleep.",
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona 5: Ko\'p suv ichsang teri yangilanadi',
          'Миф 5: много воды обновляет кожу',
          'Myth 5: drinking lots of water renews skin',
        ),
        body: LocalizedText(
          'Haqiqat: suv teri uchun zarur, lekin mo\'l-ko\'l suv ichish ajin yo\'qotmaydi. Teri namligi asosan kremdan keladi, ichdan emas. Suv ichish umumiy salomatlik uchun yaxshi — lekin "8 stakan suv = yosh teri" afsonasi.',
          'Правда: вода коже нужна, но обилие воды не убирает морщины. Увлажнённость кожи в основном идёт от крема, а не изнутри. Пить воду полезно для здоровья в целом — но «8 стаканов = молодая кожа» это миф.',
          'The truth: water matters, but drinking more of it does not remove wrinkles. Skin hydration comes mostly from what you put on it, not from the inside. Drinking water is good for general health — but "eight glasses equals young skin" is a myth.',
        ),
      ),
      ArticleSection(
        heading: LocalizedText(
          'Afsona 6: Tabiiy teri qarishga yo\'l yo\'q',
          'Миф 6: со старением кожи ничего не поделать',
          'Myth 6: there is nothing you can do about ageing',
        ),
        body: LocalizedText(
          "Haqiqat: teri qarishining katta qismi tashqi omillarga bog'liq — birinchi navbatda quyosh, shuningdek chekish, uyqusizlik va stress. Demak, odatlarni o'zgartirish qarishni sezilarli sekinlashtiradi. Eng muhim 3 qadam: SPF, uyqu, namlash.",
          "Правда: во многом старение кожи зависит от внешних факторов — прежде всего от солнца, а также от курения, недосыпа и стресса. Значит, изменение привычек заметно замедляет процесс. Три главных шага: SPF, сон, увлажнение.",
          "The truth: much of skin ageing comes from outside factors — above all the sun, plus smoking, poor sleep and stress. Which means changing your habits slows it down noticeably. The three that matter most: SPF, sleep, moisturiser.",
        ),
      ),
    ],
  ),
];
