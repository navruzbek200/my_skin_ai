import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

import '../models/lesson.dart';

// Repeated labels, held once so the wording cannot drift between lessons.
const _ingredient =
    LocalizedText('Ingrediyent', 'Ингредиент', 'Ingredient');
const _beginner =
    LocalizedText("Boshlang'ich", 'Начальный', 'Beginner');
const _summary = LocalizedText('Xulosa', 'Итог', 'In short');
const _keyBenefits =
    LocalizedText('Asosiy foydalar', 'Основная польза', 'Key benefits');
const _tip = LocalizedText('Maslahat', 'Совет', 'Tip');

LocalizedText _minutes(int n) => LocalizedText(
      '$n daqiqa',
      '$n минут',
      '$n min',
    );

final List<Lesson> lessons = [
  Lesson(
    id: 'niacinamide',
    title: const LocalizedText('Niatsinamid', 'Ниацинамид', 'Niacinamide'),
    subtitle: const LocalizedText(
      "Poralar va yog'lilikni nazorat qilish",
      'Контроль пор и жирности',
      'Controlling pores and oil',
    ),
    category: _ingredient,
    duration: _minutes(8),
    level: _beginner,
    color: const Color(0xFF9B59B6),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText('Niatsinamid nima?', 'Что такое ниацинамид?',
            'What is niacinamide?'),
        body: const LocalizedText(
          "Niatsinamid — B3 vitaminining shakli bo'lib, teri g'amxo'rligida eng ko'p ishlatiladigan ingrediyentlardan biridir. U poralar, yog'lilik va pigmentatsiya kabi muammolarni hal qilishda yordam beradi.",
          'Ниацинамид — форма витамина B3 и один из самых применяемых ингредиентов в уходе за кожей. Он помогает с порами, жирностью и пигментацией.',
          'Niacinamide is a form of vitamin B3 and one of the most widely used ingredients in skincare. It helps with pores, oiliness and pigmentation.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText(
            'Ilmiy fakt', 'Научный факт', 'The science'),
        keyword: const LocalizedText(
          "Teri to'sig'ini mustahkamlaydi",
          'Укрепляет барьер кожи',
          'Strengthens the skin barrier',
        ),
        body: const LocalizedText(
          "Tadqiqotlar niatsinamid ceramide ishlab chiqarishni 34% ga oshirishini ko'rsatdi. Bu teri to'sig'ini kuchaytiradi va namlikni saqlashga yordam beradi.",
          'Исследования показали, что ниацинамид повышает выработку церамидов на 34%. Это укрепляет барьер кожи и помогает удерживать влагу.',
          'Studies found that niacinamide raises ceramide production by 34%. That strengthens the skin barrier and helps it hold on to moisture.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: _keyBenefits,
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            "Poralarni kichraytiradi va yog'lilikni kamaytiradi",
            'Сужает поры и снижает жирность',
            'Tightens pores and cuts down oil',
          ),
          LocalizedText(
            "Pigmentatsiya va dog'larni ochadi",
            'Осветляет пигментацию и пятна',
            'Fades pigmentation and spots',
          ),
          LocalizedText(
            "Teri to'sig'ini mustahkamlaydi",
            'Укрепляет барьер кожи',
            'Strengthens the skin barrier',
          ),
          LocalizedText(
            "Qizarishni kamaytiradi va anti-iltihobiy ta'sir ko'rsatadi",
            'Снимает покраснение и действует противовоспалительно',
            'Reduces redness and acts as an anti-inflammatory',
          ),
          LocalizedText(
            'Ajin va mayda chiziqlarni kamaytiradi',
            'Уменьшает морщины и мелкие линии',
            'Softens wrinkles and fine lines',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: const LocalizedText('Foydalanish maslahati',
            'Как применять', 'How to use it'),
        body: const LocalizedText(
          "Niatsinamidni 5–10% konsentratsiyada ishlating. Retinol bilan birgalikda ishlatish mumkin, lekin C vitaminidan oldin qo'llang. Har kuni ertalab va kechqurun tozalangan yuzga surting.",
          'Используйте ниацинамид в концентрации 5–10%. Его можно сочетать с ретинолом, но наносить следует до витамина C. Наносите утром и вечером на очищенную кожу.',
          'Use niacinamide at 5–10%. It pairs fine with retinol, but apply it before vitamin C. Put it on cleansed skin morning and night.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "Niatsinamid deyarli barcha teri turlari uchun mos bo'lib, u sezgir terini ham bezovta qilmaydi. Muntazam foydalanish bilan 4–8 hafta ichida sezilarli natijalar ko'rasiz.",
          'Ниацинамид подходит почти любому типу кожи и не раздражает даже чувствительную. При регулярном применении заметный результат появляется через 4–8 недель.',
          'Niacinamide suits almost every skin type and does not irritate even sensitive skin. With regular use you will see a clear difference in four to eight weeks.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'spf',
    title: const LocalizedText('SPF tanlash', 'Как выбрать SPF',
        'Choosing an SPF'),
    subtitle: const LocalizedText(
      "Quyoshdan to'g'ri himoya",
      'Правильная защита от солнца',
      'Getting sun protection right',
    ),
    category: const LocalizedText('Himoya', 'Защита', 'Protection'),
    duration: _minutes(6),
    level: const LocalizedText('Asosiy', 'Базовый', 'Essential'),
    color: const Color(0xFFFF9F43),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText('Nima uchun SPF muhim?',
            'Почему SPF так важен?', 'Why SPF matters'),
        body: const LocalizedText(
          "Quyosh nurlari (UVA va UVB) teriga eng katta zarar yetkazuvchi omildir. SPF (Sun Protection Factor) siz uchun eng muhim kundalik parvarish qadamidir — hatto bulutli havoda ham.",
          'Солнечные лучи (UVA и UVB) — главный фактор повреждения кожи. SPF (Sun Protection Factor) — самый важный ежедневный шаг ухода, даже в пасмурную погоду.',
          'Sunlight (UVA and UVB) is the single biggest source of skin damage. SPF is the most important daily step in any routine — cloudy days included.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText.same('UVA vs UVB'),
        keyword: const LocalizedText(
          'UVA — qarish, UVB — kuyish',
          'UVA — старение, UVB — ожог',
          'UVA ages, UVB burns',
        ),
        body: const LocalizedText(
          "UVA nurlari teri qatlamlariga chuqur kirib, erta qarish va pigmentatsiyaga olib keladi. UVB esa yuzaki kuyishga sabab bo'ladi. Keng spektrli SPF ikkalasidan himoya qiladi.",
          'UVA проникает в глубокие слои кожи и вызывает раннее старение и пигментацию. UVB работает на поверхности и вызывает ожог. SPF широкого спектра защищает от обоих.',
          'UVA reaches the deeper layers and drives early ageing and pigmentation. UVB works at the surface and causes burning. A broad-spectrum SPF covers both.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: const LocalizedText('SPF tanlash mezonlari',
            'На что смотреть при выборе', 'What to look for'),
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            'Kundalik foydalanish uchun SPF 30–50 yetarli',
            'Для повседневного использования достаточно SPF 30–50',
            'SPF 30–50 is enough for everyday wear',
          ),
          LocalizedText(
            "Dengiz, tog' yoki uzoq tashqarida — SPF 50+",
            'Море, горы или долгое время на улице — SPF 50+',
            'Beach, mountains or a long day outside — SPF 50+',
          ),
          LocalizedText(
            "Keng spektrli (broad spectrum) yozuvi bo'lsin",
            'Ищите пометку broad spectrum (широкий спектр)',
            'Look for "broad spectrum" on the label',
          ),
          LocalizedText(
            "Teri tipingizga mos formula: yog'li → gel, quruq → krem",
            'Формула под ваш тип: жирная кожа — гель, сухая — крем',
            'Match the formula to your type: oily → gel, dry → cream',
          ),
          LocalizedText(
            'Har 2 soatda yangilash kerak',
            'Обновляйте каждые 2 часа',
            'Reapply every two hours',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: const LocalizedText('Muhim eslatma', 'Важное замечание',
            'One thing people get wrong'),
        body: const LocalizedText(
          "Ko'pchilik SPF ni yetarli miqdorda ishlatmaydi. To'g'ri himoya uchun yuzga 2 barmoq (taxminan 1/4 choy qoshiq) SPF krem surting. Kamroq surtsangiz, himoya darajasi keskin tushadi.",
          'Большинство наносит слишком мало SPF. Для заявленной защиты нужно два пальца средства (примерно четверть чайной ложки) на лицо. Меньше — и уровень защиты резко падает.',
          'Most people use far too little. Proper protection takes two fingers\' worth (about a quarter teaspoon) for the face. Use less and the protection drops sharply.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "SPF kundalik parvarish majburiy qadami. Uni serum va namlagichdan keyin, makiyajdan oldin ishlating. Tegishli SPF muntazam ishlatilsa, 10 yildan keyin teringiz sog'lom ko'rinishida qoladi.",
          'SPF — обязательный шаг ежедневного ухода. Наносите его после сыворотки и увлажнителя, до макияжа. При регулярном применении через 10 лет кожа выглядит заметно здоровее.',
          'SPF is not optional. Apply it after your serum and moisturiser, before makeup. Used consistently, it is what keeps skin looking healthy ten years from now.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'vitamin_c',
    title: const LocalizedText('C vitamini', 'Витамин C', 'Vitamin C'),
    subtitle: const LocalizedText(
      'Yorqinlik va antioksidant himoya',
      'Сияние и антиоксидантная защита',
      'Brightness and antioxidant protection',
    ),
    category: _ingredient,
    duration: _minutes(8),
    level: _beginner,
    color: const Color(0xFFF5A623),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText('C vitamini nima?', 'Что такое витамин C?',
            'What is vitamin C?'),
        body: const LocalizedText(
          "C vitamini (askorbin kislota) — teri parvarishidagi eng ko'p o'rganilgan uchta ingrediyentdan biri. U ikki ish qiladi: kunduzi teriga tushayotgan zararni to'xtatadi va allaqachon paydo bo'lgan dog'larni ochadi. Shu sababli u ertalabki parvarishning asosiy qadami hisoblanadi.",
          'Витамин C (аскорбиновая кислота) — один из трёх самых изученных ингредиентов в уходе. Он делает две вещи: останавливает повреждение, которое кожа получает днём, и осветляет уже появившиеся пятна. Поэтому его место — в утреннем уходе.',
          'Vitamin C (ascorbic acid) is one of the three most studied ingredients in skincare. It does two things: it stops damage as it happens during the day, and it fades the marks already there. That is why it belongs in the morning routine.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText('Nima uchun ertalab?', 'Почему утром?',
            'Why in the morning?'),
        keyword: const LocalizedText(
          'SPF himoyasini kuchaytiradi',
          'Усиливает защиту SPF',
          'It makes your SPF work harder',
        ),
        body: const LocalizedText(
          "Quyosh nuri teriga erkin radikallar orqali zarar yetkazadi — SPF ularning hammasini to'sib qololmaydi. C vitamini aynan shu qolganini zararsizlantiradi. Tadqiqotlarga ko'ra C vitamini va SPF birga ishlatilganda himoya yolg'iz SPF dan sezilarli kuchliroq bo'ladi.",
          'Солнце повреждает кожу через свободные радикалы, и SPF задерживает не все. Витамин C нейтрализует то, что прошло. По исследованиям, вместе с SPF защита заметно выше, чем от одного SPF.',
          'Sunlight damages skin through free radicals, and SPF does not block all of them. Vitamin C neutralises what gets through. Studies show the two together protect noticeably better than SPF alone.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: _keyBenefits,
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            "Quyosh dog'lari va post-akne qorayishini ochadi",
            'Осветляет солнечные пятна и следы после высыпаний',
            'Fades sun spots and post-breakout marks',
          ),
          LocalizedText(
            'Yuz rangini tenglashtiradi va yorqinlik beradi',
            'Выравнивает тон и придаёт сияние',
            'Evens the tone and adds glow',
          ),
          LocalizedText(
            'Kollagen sintezi uchun zarur — ajinlarni sekinlashtiradi',
            'Необходим для синтеза коллагена — замедляет появление морщин',
            'Essential for collagen synthesis — slows lines down',
          ),
          LocalizedText(
            'Erkin radikallardan himoya qiladi',
            'Защищает от свободных радикалов',
            'Protects against free radicals',
          ),
          LocalizedText(
            'Qizarishni kamaytiradi',
            'Уменьшает покраснение',
            'Reduces redness',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: const LocalizedText("To'g'ri tanlash va saqlash",
            'Как выбрать и хранить', 'Choosing and storing it'),
        body: const LocalizedText(
          "Boshlash uchun 10–15% konsentratsiya yetarli; 20% sezgir terini bezovta qiladi. C vitamini havo va yorug'likdan buziladi — shishasi to'q rangli va og'zi tor bo'lsin. Suyuqlik sariqdan jigarrangga o'tgan bo'lsa, u ishlamaydi, tashlang. Ertalab tozalangandan keyin, SPF dan oldin surting.",
          'Для начала хватит 10–15%; 20% раздражает чувствительную кожу. Витамин C разрушается от воздуха и света — флакон должен быть тёмным и с узким горлышком. Если жидкость из жёлтой стала коричневой, средство не работает, выбросьте. Наносите утром на очищенную кожу, до SPF.',
          'Start at 10–15%; 20% irritates sensitive skin. Vitamin C degrades in air and light, so look for a dark bottle with a narrow neck. If the liquid has turned from yellow to brown it no longer works — throw it out. Apply in the morning on clean skin, before SPF.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "C vitamini — SPF va retinol bilan bir qatorda turadigan uchta asosiy ingrediyentdan biri. Ertalab C vitamini, kechqurun retinol, ikkalasining ustidan namlagich: bu eng oddiy va eng isbotlangan parvarish rejasi. Dog'lardagi natija 8–12 haftada ko'rinadi.",
          'Витамин C стоит в одном ряду с SPF и ретинолом. Утром витамин C, вечером ретинол, поверх обоих увлажнитель — самая простая и самая доказанная схема ухода. Результат по пятнам виден через 8–12 недель.',
          'Vitamin C sits alongside SPF and retinol as one of the three that matter. Vitamin C in the morning, retinol at night, a moisturiser over both: that is the simplest and best-evidenced routine there is. Expect spots to fade in eight to twelve weeks.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'retinol',
    title: const LocalizedText('Retinol', 'Ретинол', 'Retinol'),
    subtitle: const LocalizedText(
      'Anti-agingning oltin standarti',
      'Золотой стандарт антивозрастного ухода',
      'The gold standard of anti-ageing',
    ),
    category: const LocalizedText(
        'Anti-aging', 'Антивозрастной уход', 'Anti-ageing'),
    duration: _minutes(10),
    level: const LocalizedText("Ilg'or", 'Продвинутый', 'Advanced'),
    color: const Color(0xFFFF6B6B),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText(
            'Retinol nima?', 'Что такое ретинол?', 'What is retinol?'),
        body: const LocalizedText(
          "Retinol — A vitaminining shakli va teri g'amxo'rligida eng ko'p ilmiy isbot qilingan ingrediyent. U ajinlarni, pigmentatsiyani va akne muammolarini hal qilishda kuchli ta'sir ko'rsatadi.",
          'Ретинол — форма витамина A и самый доказанный ингредиент в уходе за кожей. Он сильно работает с морщинами, пигментацией и высыпаниями.',
          'Retinol is a form of vitamin A and the best-evidenced ingredient in skincare. It works powerfully on lines, pigmentation and breakouts.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText(
            'Ilmiy isbot', 'Доказательства', 'The evidence'),
        keyword: const LocalizedText(
          'Kollagen ishlab chiqarishni oshiradi',
          'Повышает выработку коллагена',
          'It raises collagen production',
        ),
        body: const LocalizedText(
          "Retinol hujayralar aylanishini tezlashtiradi va kollagen sintezini stimulyatsiya qiladi. Tadqiqotlar 12 hafta davomida ishlatilinganda ajinlar chuqurligi 27–37% kamayishini ko'rsatdi.",
          'Ретинол ускоряет обновление клеток и стимулирует синтез коллагена. Исследования показали, что за 12 недель применения глубина морщин снижается на 27–37%.',
          'Retinol speeds up cell turnover and stimulates collagen synthesis. Studies found wrinkle depth falls by 27–37% over twelve weeks of use.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: const LocalizedText('Bosqichli boshlash qoidasi',
            'Как вводить постепенно', 'How to ramp up'),
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            '1-hafta: 0.025% — haftada 2 marta',
            'Неделя 1: 0,025% — 2 раза в неделю',
            'Week 1: 0.025% — twice a week',
          ),
          LocalizedText(
            '2-4 hafta: 0.025% — haftada 3-4 marta',
            'Недели 2–4: 0,025% — 3–4 раза в неделю',
            'Weeks 2–4: 0.025% — three or four times a week',
          ),
          LocalizedText(
            '1-oy: 0.05% — har kuni kechasi',
            'Месяц 1: 0,05% — каждый вечер',
            'Month 1: 0.05% — every night',
          ),
          LocalizedText(
            "3-oy: 0.1% — kuchli ta'sir",
            'Месяц 3: 0,1% — сильное действие',
            'Month 3: 0.1% — full strength',
          ),
          LocalizedText(
            'Har doim kechasi surting, SPF ertasi kuni majburiy',
            'Наносите только вечером, SPF на следующий день обязателен',
            'Always at night, and SPF the next day is not optional',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: const LocalizedText('Muhim ogohlantirishlar', 'Важные предупреждения',
            'Important warnings'),
        body: const LocalizedText(
          "Retinol boshida teriyi quritishi yoki qizartirishi mumkin — bu \"purging\" jarayoni. 2–4 hafta o'tgach yaxshilanadi. Homiladorlik va emizishda ISHLATMANG. Vitamin C bilan bir kechada ishlatmang.",
          'Вначале ретинол может сушить кожу или вызывать покраснение — это период адаптации. Через 2–4 недели становится легче. НЕ применяйте при беременности и грудном вскармливании. Не сочетайте с витамином C в один вечер.',
          'Retinol can dry or redden the skin at first — that is the adjustment period. It settles after two to four weeks. Do NOT use it while pregnant or breastfeeding. Do not use it in the same session as vitamin C.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "Retinol — sabrli foydalanuvchilar uchun eng kuchli anti-aging qurol. Sekin boshlang, namlagich bilan yupqalang, SPF doim ishlating. 3–6 oy muntazam foydalanishdan keyin dramatik natija ko'rasiz.",
          'Ретинол — самое мощное антивозрастное средство для терпеливых. Начинайте медленно, смягчайте увлажнителем, всегда пользуйтесь SPF. Через 3–6 месяцев регулярного применения результат впечатляет.',
          'Retinol is the most powerful anti-ageing tool there is, for people who are patient with it. Start slow, buffer with a moisturiser, never skip SPF. After three to six months of consistent use the difference is dramatic.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'hyaluronic',
    title: const LocalizedText('Gialuron kislota', 'Гиалуроновая кислота',
        'Hyaluronic acid'),
    subtitle: const LocalizedText(
      'Terini ichidan namlash',
      'Увлажнение изнутри',
      'Hydration from within',
    ),
    category: const LocalizedText('Namlash', 'Увлажнение', 'Hydration'),
    duration: _minutes(6),
    level: _beginner,
    color: const Color(0xFF3A86FF),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText('Gialuron kislota nima?',
            'Что такое гиалуроновая кислота?', 'What is hyaluronic acid?'),
        body: const LocalizedText(
          "Gialuron kislota organizmda tabiiy mavjud bo'lgan molekula bo'lib, 1 gram suv 6 litr namlikni ushlab turishi mumkin. Teri g'amxo'rligidagi eng samarali namlash ingrediyenti hisoblanadi.",
          'Гиалуроновая кислота — молекула, которая есть в организме от природы: 1 грамм удерживает до 6 литров влаги. Это самый эффективный увлажняющий ингредиент в уходе.',
          'Hyaluronic acid is a molecule the body already makes: one gram can hold up to six litres of water. It is the most effective hydrating ingredient in skincare.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText('Molekula hajmi muhim',
            'Размер молекулы важен', 'Molecule size matters'),
        keyword: const LocalizedText(
          'Turli hajmdagi molekulalar',
          'Молекулы разного размера',
          'Molecules of different sizes',
        ),
        body: const LocalizedText(
          "Kichik molekulalar (nano-HA) teri qatlamlariga chuqur kirib, ichki namlikni ta'minlaydi. Katta molekulalar yuzada qolib, himoya plyonka hosil qiladi. Eng yaxshi mahsulotlar ikkalasini o'z ichiga oladi.",
          'Мелкие молекулы (нано-HA) проникают в глубокие слои и увлажняют изнутри. Крупные остаются на поверхности и образуют защитную плёнку. Лучшие средства содержат и те, и другие.',
          'Small molecules (nano-HA) reach the deeper layers and hydrate from inside. Large ones stay on the surface and form a protective film. The best products contain both.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: const LocalizedText("To'g'ri foydalanish",
            'Как применять правильно', 'Using it properly'),
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            'Nam teriga surting — quruq teri emas',
            'Наносите на влажную кожу, не на сухую',
            'Apply to damp skin, never dry',
          ),
          LocalizedText(
            'Tonikdan keyin, namlagichdan oldin',
            'После тоника, до увлажнителя',
            'After toner, before moisturiser',
          ),
          LocalizedText(
            "Teri namligini \"qulflab\" qo'yish uchun ustiga namlagich surting",
            'Сверху нанесите увлажнитель, чтобы «запечатать» влагу',
            'Seal it in with a moisturiser on top',
          ),
          LocalizedText(
            "Quruq ob-havoda xona ichida ham ishlating",
            'В сухую погоду пользуйтесь и в помещении',
            'In dry weather, use it indoors too',
          ),
          LocalizedText(
            "Ko'z atrofiga ham xavfsiz ishlatish mumkin",
            'Безопасно и для области вокруг глаз',
            'Safe around the eyes as well',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: _tip,
        body: const LocalizedText(
          "Gialuron kislota atrofdagi namlikni tortadi. Quruq muhitda (konditsioner, samolyot) ustiga namlagich qo'ymasangiz, u teringizdan namlikni tortib olishi mumkin. Doim ikki qadam: HA → namlagich.",
          'Гиалуроновая кислота притягивает влагу из окружающего воздуха. В сухой среде (кондиционер, самолёт) без увлажнителя сверху она начнёт вытягивать влагу из самой кожи. Всегда два шага: HA → увлажнитель.',
          'Hyaluronic acid pulls moisture out of the air around it. In a dry environment (air conditioning, a plane) with nothing sealing it in, it will pull water out of your skin instead. Always two steps: HA → moisturiser.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "Gialuron kislota barcha teri turlari uchun mos, xavfsiz va samarali namlash ingrediyenti. Sezgir teri ham uni yaxshi qabul qiladi. Kundalik ertalab va kechqurun ishlatish tavsiya etiladi.",
          'Гиалуроновая кислота подходит любому типу кожи, безопасна и эффективна. Чувствительная кожа переносит её хорошо. Используйте утром и вечером.',
          'Hyaluronic acid suits every skin type and is both safe and effective. Even sensitive skin takes it well. Use it morning and night.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'ceramides',
    title: const LocalizedText('Seramidlar', 'Церамиды', 'Ceramides'),
    subtitle: const LocalizedText(
      "Teri to'sig'ining g'ishtlari",
      'Кирпичики барьера кожи',
      'The bricks of the skin barrier',
    ),
    category: const LocalizedText('Namlash', 'Увлажнение', 'Hydration'),
    duration: _minutes(6),
    level: _beginner,
    color: const Color(0xFF06D6A0),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText('Seramidlar nima?', 'Что такое церамиды?',
            'What are ceramides?'),
        body: const LocalizedText(
          "Terining eng tashqi qatlamini devorga o'xshating: hujayralar — g'isht, seramidlar — ularni ushlab turgan qorishma. Seramidlar terining o'zida bor moddalar va to'siqning yarmidan ko'pini tashkil qiladi. Ular kamayganda devorda yoriq paydo bo'ladi: namlik chiqib ketadi, bezovta qiluvchi narsalar ichkariga kiradi.",
          'Представьте верхний слой кожи как стену: клетки — кирпичи, церамиды — раствор между ними. Церамиды есть в коже от природы и составляют больше половины барьера. Когда их не хватает, в стене появляются трещины: влага уходит, раздражители заходят.',
          'Picture the outermost layer of skin as a wall: the cells are bricks and ceramides are the mortar holding them together. Ceramides occur naturally in skin and make up more than half of the barrier. When they run low the wall cracks: moisture escapes and irritants get in.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText('Nega ular kamayadi?',
            'Почему их становится меньше?', 'Why they run low'),
        keyword: const LocalizedText(
          "Buzilgan to'siq — ko'p muammoning sababi",
          'Повреждённый барьер — причина многих проблем',
          'A broken barrier is behind a lot of problems',
        ),
        body: const LocalizedText(
          "Yosh, sovuq havo, qattiq sovun, issiq suv va kuchli vositalarni haddan ortiq ishlatish seramidlarni yuvib yuboradi. Quruqlik, tortishish, qizarish, sabab topilmaydigan sezgirlik va hatto ba'zi akne turlari — ko'pincha alohida muammo emas, o'sha bitta buzilgan to'siqning belgilari.",
          'Возраст, холод, жёсткое мыло, горячая вода и злоупотребление активными средствами вымывают церамиды. Сухость, стянутость, покраснение, чувствительность без явной причины и даже часть высыпаний — часто не отдельные проблемы, а признаки одного повреждённого барьера.',
          'Age, cold weather, harsh soap, hot water and overusing strong actives all strip ceramides away. Dryness, tightness, redness, sensitivity with no obvious cause and even some breakouts are often not separate problems but symptoms of that one damaged barrier.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: const LocalizedText("To'siqni tiklash qoidalari",
            'Как восстановить барьер', 'Rebuilding the barrier'),
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            'Yuvinishni kuniga 2 martaga cheklang, iliq suv bilan',
            'Умывайтесь не чаще двух раз в день, тёплой водой',
            'Wash no more than twice a day, with warm water',
          ),
          LocalizedText(
            "Piling va retinolni vaqtincha to'xtating — teri tinchlansin",
            'Временно уберите пилинги и ретинол — дайте коже успокоиться',
            'Pause peels and retinol for now — let the skin settle',
          ),
          LocalizedText(
            'Nam teriga seramidli krem surting',
            'Наносите крем с церамидами на влажную кожу',
            'Apply a ceramide cream to damp skin',
          ),
          LocalizedText(
            "Tarkibida seramid + xolesterin + yog' kislotasi birga bo'lsin",
            'В составе должны быть церамиды + холестерин + жирные кислоты',
            'Look for ceramides + cholesterol + fatty acids together',
          ),
          LocalizedText(
            "Yangi vositani bir vaqtda bittadan qo'shing",
            'Вводите новые средства по одному',
            'Add new products one at a time',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: _tip,
        body: const LocalizedText(
          "Seramid gialuron kislotaning davomi: HA namlikni tortadi, seramid uni ichkarida ushlab turadi. Shuning uchun tartib har doim HA → seramidli krem. Seramid hech qanday ingrediyent bilan urishmaydi — retinol, niatsinamid, kislotalarning yonida xavfsiz, aksincha ularning ta'sirini yumshatadi.",
          'Церамиды — продолжение гиалуроновой кислоты: HA притягивает влагу, церамиды удерживают её внутри. Поэтому порядок всегда HA → крем с церамидами. Церамиды не конфликтуют ни с чем — они безопасны рядом с ретинолом, ниацинамидом и кислотами и, наоборот, смягчают их действие.',
          'Ceramides are the second half of hyaluronic acid: HA draws water in, ceramides keep it there. So the order is always HA → ceramide cream. Ceramides clash with nothing — they are safe beside retinol, niacinamide and acids, and in fact soften how those feel.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "Teringiz qizarayotgan, achishayotgan yoki hech narsa yordam bermayotgan bo'lsa, yangi faol vosita qo'shmang — to'siqni tiklang. Sodda seramidli krem bilan 2–4 haftada teri tinchlanadi, shundan keyingina faol vositalarga qayting.",
          'Если кожа краснеет, щиплет или ничего не помогает — не добавляйте новое активное средство, восстановите барьер. С простым кремом с церамидами кожа успокаивается за 2–4 недели, и только после этого возвращайтесь к активам.',
          'If your skin is red, stinging or nothing seems to help, do not add another active — repair the barrier. A plain ceramide cream calms things down in two to four weeks, and only then is it worth going back to actives.',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'peeling',
    title: const LocalizedText(
        'Piling nima?', 'Что такое пилинг?', 'What is a peel?'),
    subtitle: const LocalizedText(
      "Qora nuqtalar va o'lik hujayralarni tozalash",
      'Очищение от чёрных точек и отмерших клеток',
      'Clearing blackheads and dead skin',
    ),
    category: const LocalizedText('Parvarish', 'Уход', 'Routine'),
    duration: _minutes(7),
    level: _beginner,
    color: const Color(0xFFE84393),
    steps: [
      LessonStep(
        type: LessonStepType.intro,
        title: const LocalizedText(
            'Piling nima?', 'Что такое пилинг?', 'What is a peel?'),
        body: const LocalizedText(
          "Piling — teri yuzasidagi o'lik hujayralarni va poralar ichidagi iflosliklarni eritib tozalaydigan vosita. U skrabdan farq qiladi: skrab mexanik (ishqalaydi), piling esa kimyoviy (eritadi) ishlaydi. Shu sababli piling nozikroq va ko'proq nazorat ostida.",
          'Пилинг растворяет отмершие клетки на поверхности кожи и загрязнения в порах. От скраба он отличается принципом: скраб работает механически (трёт), пилинг — химически (растворяет). Поэтому пилинг мягче и его действие лучше контролируется.',
          'A peel dissolves dead cells on the surface and the grime sitting in pores. It differs from a scrub in method: a scrub works mechanically by abrading, a peel works chemically by dissolving. That makes a peel gentler and far easier to control.',
        ),
      ),
      LessonStep(
        type: LessonStepType.fact,
        title: const LocalizedText(
            'Ikki asosiy turi', 'Два основных типа', 'The two main kinds'),
        keyword: const LocalizedText.same('AHA / BHA'),
        body: const LocalizedText(
          "AHA (alfa-gidroksi kislota) — tabiiy manbalardan olinadi: glikolik kislota shakar qamishidan, limon kislota limon va apelsindan, laktik kislota sutdan, mandel kislota bodom danagidan. Teri yuzasini yorqinlashtiradi, dog'larni yo'qotadi, tekislaydi. BHA (beta-gidroksi kislota) — salitsilik kislota, temir daraxt po'stlog'idan olinadi. Poraga chuqur kirib, yog' va qora nuqtalarni eritadi.",
          'AHA (альфа-гидроксикислоты) получают из природного сырья: гликолевую — из сахарного тростника, лимонную — из цитрусовых, молочную — из молока, миндальную — из миндаля. Они осветляют поверхность кожи, убирают пятна и выравнивают тон. BHA (бета-гидроксикислота) — это салициловая кислота из коры ивы. Она проникает глубоко в пору и растворяет себум и чёрные точки.',
          'AHAs (alpha hydroxy acids) come from natural sources: glycolic from sugar cane, citric from citrus, lactic from milk, mandelic from almonds. They brighten the surface, fade marks and even out the tone. BHA (beta hydroxy acid) is salicylic acid, from willow bark. It gets deep into the pore and dissolves oil and blackheads.',
        ),
      ),
      LessonStep(
        type: LessonStepType.list,
        title: const LocalizedText('Piling nimalarga foydali?',
            'Чем полезен пилинг', 'What a peel is good for'),
        body: const LocalizedText.same(''),
        items: const [
          LocalizedText(
            'Qora va oq nuqtalarni (komed) poradan chiqaradi',
            'Убирает чёрные и белые точки (комедоны) из пор',
            'Clears blackheads and whiteheads out of the pores',
          ),
          LocalizedText(
            "O'lik teri hujayralarini tozalab, yuz rangini yorqinlashtiradi",
            'Удаляет отмершие клетки и осветляет тон лица',
            'Removes dead cells and brightens the complexion',
          ),
          LocalizedText(
            "Akne iz va dog'larini asta-sekin yo'qotadi",
            'Постепенно убирает следы и пятна после высыпаний',
            'Gradually fades post-breakout marks and spots',
          ),
          LocalizedText(
            'Serum va kremlarning teri ichiga kirishini osonlashtiradi',
            'Помогает сывороткам и кремам лучше впитываться',
            'Lets serums and creams sink in better',
          ),
          LocalizedText(
            'Teri yuzasini tekislaydi va silliqlashtiradi',
            'Выравнивает и разглаживает поверхность кожи',
            'Evens and smooths the surface of the skin',
          ),
        ],
      ),
      LessonStep(
        type: LessonStepType.tip,
        title: const LocalizedText('Qachon va qanday ishlating?',
            'Когда и как применять', 'When and how to use it'),
        body: const LocalizedText(
          "Faqat kechqurun ishlating — piling teri fotosensitiv qiladi, quyoshda yuz qizaradi. Haftada 1–2 martadan ko'p ishlatmang — aks holda teri qizaradi va quruq bo'ladi. Retinol bilan bir kechada ishlatmang — juda kuchli bo'ladi. Ertasi kuni albatta SPF surting.",
          'Только вечером — пилинг делает кожу фоточувствительной, на солнце лицо краснеет. Не чаще 1–2 раз в неделю, иначе кожа покраснеет и пересохнет. Не сочетайте с ретинолом в один вечер — слишком сильно. На следующий день SPF обязателен.',
          'Evenings only — a peel makes skin photosensitive and the face reddens in sun. No more than once or twice a week, or the skin goes red and dry. Never in the same session as retinol, which is too much at once. SPF the next day is not optional.',
        ),
      ),
      LessonStep(
        type: LessonStepType.intro,
        title: _summary,
        body: const LocalizedText(
          "Yog'li va aralash teri uchun BHA piling eng samarali — qora nuqtalarni ichidan tozalaydi. Quruq va normal teri uchun AHA yaxshiroq — yuzni yorqinlashtiradi. Birinchi marta ishlatganda 5–10 daqiqadan boshlang, keyin vaqtni oshiring. Shoshilmang — piling sekin lekin ishonchli natija beradi.",
          'Для жирной и комбинированной кожи эффективнее BHA — он вычищает поры изнутри. Для сухой и нормальной лучше AHA — он осветляет лицо. В первый раз начните с 5–10 минут и увеличивайте время постепенно. Не торопитесь: пилинг даёт медленный, но надёжный результат.',
          'For oily and combination skin a BHA peel works best — it clears the pores from the inside. For dry and normal skin an AHA is better — it brightens the face. The first time, start at five to ten minutes and build up. Do not rush it: a peel gives slow but dependable results.',
        ),
      ),
    ],
  ),
];
