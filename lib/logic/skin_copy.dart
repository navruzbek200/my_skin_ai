import 'package:flutter/widgets.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

/// Every sentence the analysis can produce, keyed by the code the engine
/// works in.
///
/// Split out of [SkinLogic] because the engine decides *what* is true about
/// somebody's skin and this decides how to say it — the two change for
/// completely different reasons, and only this half grows when a language is
/// added.
///
/// Keying on the code rather than on the finished text is also what makes the
/// language switch retroactive: a profile saved months ago stores 'O' and
/// 'Bh', so re-reading it in Russian produces Russian, not the Uzbek it was
/// written in.
class SkinCopy {
  const SkinCopy._();

  /// The four skin types, by their one-letter code.
  static const skinTypes = <String, LocalizedText>{
    'D': LocalizedText('Quruq', 'Сухая', 'Dry'),
    'C': LocalizedText('Aralash', 'Комбинированная', 'Combination'),
    'N': LocalizedText('Normal', 'Нормальная', 'Normal'),
    'O': LocalizedText("Yog'li", 'Жирная', 'Oily'),
  };

  /// The long recommendation that opens the results screen, by skin-type code.
  static const baseRecommendations = <String, LocalizedText>{
    'D': LocalizedText(
      '''Sizning yuz teringiz QURUQ.

Quruq teri uchun asosiy maqsad – terini chuqur namlash, himoya qatlamini tiklash va namlikni saqlab qolishdir. Yuzni kuniga 2 marta yumshoq va terini quritmaydigan tozalagich bilan tozalash tavsiya etiladi.

Tarkibida gialuron kislotasi, pantenol (provitamin B5), keramidlar yoki niatsinamid (vitamin B3) bo'lgan serum va namlovchi kremlar terining namlik balansini tiklashga yordam beradi. Juda kuchli skrablar yoki agressiv kislotalardan saqlanish muhim, chunki ular terini yanada quritishi mumkin.''',
      '''Ваша кожа СУХАЯ.

Главная задача для сухой кожи — глубоко увлажнить её, восстановить защитный барьер и удержать влагу. Умывайтесь дважды в день мягким средством, которое не пересушивает кожу.

Сыворотки и кремы с гиалуроновой кислотой, пантенолом (провитамин B5), керамидами или ниацинамидом (витамин B3) помогут восстановить баланс влаги. Избегайте жёстких скрабов и агрессивных кислот — они сушат кожу ещё сильнее.''',
      '''Your skin is DRY.

The goal for dry skin is to hydrate it deeply, rebuild the barrier and keep the moisture in. Wash twice a day with a gentle cleanser that does not strip the skin.

Serums and creams with hyaluronic acid, panthenol (provitamin B5), ceramides or niacinamide (vitamin B3) help restore the moisture balance. Avoid harsh scrubs and aggressive acids — they will only dry the skin further.''',
    ),
    'C': LocalizedText(
      '''Sizning yuz teringiz ARALASH.

Aralash terida odatda T-zona (peshona, burun va iyak) yog'li bo'ladi, yanoqlar esa quruq yoki normal bo'lishi mumkin. Bunday teri uchun asosiy maqsad – yog' ajralishini nazorat qilish bilan birga terining namlik balansini saqlashdir.

Yuzni kuniga 2 marta yumshoq gel tozalagich bilan tozalash tavsiya etiladi. Tarkibida niatsinamid (vitamin B3), gialuron kislotasi yoki yengil AHA/BHA kislotalari bo'lgan serum va kremlar terining balansini saqlashga yordam beradi. T-zonada ortiqcha yog'ni kamaytirish uchun haftasiga 1–2 marta maska qo'llash, piling ishlatish mumkin, yanoqlarni esa yaxshi namlab turish muhim.''',
      '''Ваша кожа КОМБИНИРОВАННАЯ.

У комбинированной кожи Т-зона (лоб, нос и подбородок) обычно жирная, а щёки — сухие или нормальные. Главная задача — контролировать выработку себума и одновременно удерживать влагу.

Умывайтесь дважды в день мягким гелем. Сыворотки и кремы с ниацинамидом (витамин B3), гиалуроновой кислотой или мягкими AHA/BHA-кислотами помогают сохранить баланс. Для Т-зоны 1–2 раза в неделю используйте маску или пилинг, а щёки при этом важно хорошо увлажнять.''',
      '''Your skin is COMBINATION.

On combination skin the T-zone (forehead, nose and chin) is usually oily while the cheeks are dry or normal. The goal is to control the oil and hold the moisture at the same time.

Wash twice a day with a gentle gel cleanser. Serums and creams with niacinamide (vitamin B3), hyaluronic acid or mild AHA/BHA acids help keep the balance. Use a mask or a peel on the T-zone once or twice a week, and keep the cheeks well hydrated.''',
    ),
    'N': LocalizedText(
      '''Sizning yuz teringiz NORMAL.

Normal teri odatda yog' va namlik jihatdan muvozanatlangan bo'lib, poralar kichik, teri silliq va sog'lom ko'rinishga ega bo'ladi. Bunday teri uchun asosiy maqsad – mavjud balansni saqlab qolish va terini tashqi omillardan himoya qilishdir.

Yumshoq tozalash, engilgina namlantirishni kundalik tartibga kiriting. Antioksidantlar (C vitamini, niasinamid) va SPF ni unutmang — bu holatni uzoq yillar saqlab qolishning eng oson yo'li.''',
      '''Ваша кожа НОРМАЛЬНАЯ.

Нормальная кожа сбалансирована по жирности и влаге: поры мелкие, поверхность гладкая, вид здоровый. Главная задача — сохранить этот баланс и защитить кожу от внешних факторов.

Введите в ежедневный уход мягкое очищение и лёгкое увлажнение. Не забывайте про антиоксиданты (витамин C, ниацинамид) и SPF — это самый простой способ сохранить нынешнее состояние на годы.''',
      '''Your skin is NORMAL.

Normal skin is balanced in oil and moisture: the pores are small, the surface is smooth and it looks healthy. The goal is to keep that balance and protect the skin from what is outside.

Build a daily routine around gentle cleansing and light hydration. Do not skip antioxidants (vitamin C, niacinamide) and SPF — that is the easiest way to keep this state for years.''',
    ),
    'O': LocalizedText(
      '''Sizning yuz teringiz YOG'LI.

Yog'li teri uchun asosiy maqsad – ortiqcha yog' ajralishini nazorat qilish, poralarni toza saqlash va teri balansini tiklashdir. Lekin quritishdan saqlaning — bu aksincha ko'proq yog' ishlab chiqishga olib keladi.

Yuzni kuniga 2 marta yengil gel yoki penka bilan yuving. Niasinamid, salitsilik kislota (BHA) va oil-free, gidrojel asosidagi namlantiruvchilar tanlang. Namlantirishni hech qachon o'tkazib yubormang va doimo SPF ishlating.''',
      '''Ваша кожа ЖИРНАЯ.

Главная задача для жирной кожи — контролировать избыток себума, держать поры чистыми и восстановить баланс. Но не пересушивайте её: в ответ кожа начнёт вырабатывать ещё больше жира.

Умывайтесь дважды в день лёгким гелем или пенкой. Выбирайте ниацинамид, салициловую кислоту (BHA) и увлажнители без масел, на гидрогелевой основе. Никогда не пропускайте увлажнение и всегда пользуйтесь SPF.''',
      '''Your skin is OILY.

The goal for oily skin is to control the excess oil, keep the pores clear and restore the balance. But do not strip it — the skin answers that by producing even more oil.

Wash twice a day with a light gel or foam. Choose niacinamide, salicylic acid (BHA) and oil-free, hydrogel-based moisturisers. Never skip the moisturiser, and always use SPF.''',
    ),
  };

  /// The concern blocks below the main recommendation, by concern code.
  static const blocks = <String, ({LocalizedText title, LocalizedText text})>{
    'P0': (
      title: LocalizedText('Poralar', 'Поры', 'Pores'),
      text: LocalizedText(
        '''Teringizda poralar ochiq.

Yuzingizni kuniga 2 marta yengil gel yoki salitsil kislotali penka bilan tozalang, niatsinamid tarkibli serum, yog'siz (oil-free) namlantiruvchi qo'llash va har kuni SPF krem surishni tavsiya qilamiz.

Haftasiga 1–2 marta yengil kimyoviy eksfoliatsiya (AHA/BHA) qilish ham poralarni tozalashga yordam beradi. Juda yog'li va og'ir krem ishlatmaslik kerak. To'g'ri parvarish bilan poralar kichikroq ko'rinadi va teri teksturasi yaxshilanadi.''',
        '''У вас расширенные поры.

Умывайтесь дважды в день лёгким гелем или пенкой с салициловой кислотой, используйте сыворотку с ниацинамидом, увлажнитель без масел (oil-free) и наносите SPF каждый день.

Лёгкая химическая эксфолиация (AHA/BHA) 1–2 раза в неделю тоже помогает очистить поры. Не используйте плотные жирные кремы. При правильном уходе поры выглядят меньше, а текстура кожи ровнее.''',
        '''Your pores are enlarged.

Wash twice a day with a light gel or a salicylic acid foam, use a niacinamide serum and an oil-free moisturiser, and apply SPF every day.

A mild chemical exfoliation (AHA/BHA) once or twice a week also helps keep the pores clear. Avoid heavy, greasy creams. With the right care the pores look smaller and the texture evens out.''',
      ),
    ),
    'S': (
      title: LocalizedText(
          "Ta'sirchanlik", 'Чувствительность', 'Sensitivity'),
      text: LocalizedText(
        '''Teringizda ta'sirchanlik bor.

Yuzni kuniga 2 marta yumshoq va terini bezovta qilmaydigan tozalagich bilan yuving. Teri himoya qatlamini tiklash va qizarishni kamaytirish uchun tarkibida pantenol (provitamin B5), sentella aziatika, aloe vera, keramidlar va niatsinamid (vitamin B3) bo'lgan serum yoki namlovchi kremlar ishlatish tavsiya etiladi.

Juda kuchli skrablar, yuqori konsentratsiyali kislotalar va spirtli kosmetika terini yanada sezgir qilishi mumkin, shuning uchun ulardan saqlanish kerak. Har kuni SPF 50 quyoshdan himoya kremi ishlating, chunki sezgir teri quyosh ta'siriga tez reaksiyaga kirishadi.''',
        '''Ваша кожа чувствительная.

Умывайтесь дважды в день мягким средством, которое не раздражает кожу. Чтобы восстановить защитный барьер и снять покраснение, используйте сыворотки и кремы с пантенолом (провитамин B5), центеллой азиатской, алоэ вера, керамидами и ниацинамидом (витамин B3).

Жёсткие скрабы, кислоты высокой концентрации и спиртосодержащая косметика делают кожу ещё чувствительнее — их стоит избегать. Пользуйтесь SPF 50 каждый день: чувствительная кожа быстро реагирует на солнце.''',
        '''Your skin is sensitive.

Wash twice a day with a gentle cleanser that does not irritate. To rebuild the barrier and calm redness, use serums and creams with panthenol (provitamin B5), centella asiatica, aloe vera, ceramides and niacinamide (vitamin B3).

Harsh scrubs, high-concentration acids and alcohol-based cosmetics make skin more sensitive still, so avoid them. Wear SPF 50 every day — sensitive skin reacts quickly to the sun.''',
      ),
    ),
    'Bh': (
      title: LocalizedText(
          'Qora nuqtalar', 'Чёрные точки', 'Blackheads'),
      text: LocalizedText(
        '''Yuzingizda qora nuqtalar bor.

Yuzni kuniga 2 marta salitsil kislotali yoki yengil gel teksturali penka bilan tozalash poralardagi ortiqcha yog' va kirni kamaytirishga yordam beradi. Tarkibida salitsil kislotasi, niatsinamid yoki retinol bo'lgan vositalar poralarning tiqilib qolishini kamaytiradi va qora nuqtalarni asta-sekin yo'qotishga yordam beradi.

Haftasiga 1–2 marta AHA/BHA eksfoliatsiya, yengil pilinglar maska poralarni chuqur tozalaydi. Qora nuqtalarni tirnoq bilan siqib chiqarmang — bu yallig'lanish va chandiqqa olib kelishi mumkin.''',
        '''У вас есть чёрные точки.

Умывание дважды в день пенкой с салициловой кислотой или лёгкой гелевой текстурой уменьшает избыток себума и загрязнений в порах. Средства с салициловой кислотой, ниацинамидом или ретинолом реже дают порам забиваться и постепенно убирают чёрные точки.

Эксфолиация AHA/BHA и лёгкие пилинг-маски 1–2 раза в неделю очищают поры глубже. Не выдавливайте чёрные точки ногтями — это ведёт к воспалению и рубцам.''',
        '''You have blackheads.

Washing twice a day with a salicylic acid foam or a light gel cuts down the oil and grime sitting in the pores. Products with salicylic acid, niacinamide or retinol keep the pores from clogging and clear blackheads gradually.

An AHA/BHA exfoliation or a mild peel mask once or twice a week cleans the pores more deeply. Do not squeeze blackheads with your nails — that leads to inflammation and scarring.''',
      ),
    ),
    'Wh': (
      title: LocalizedText('Oq nuqtalar (jiroviklar)',
          'Белые точки (милиумы)', 'Whiteheads (milia)'),
      text: LocalizedText(
        '''Yuzingizda oq nuqtalar (jiroviklar) bor.

Jiroviklar — teri ostida to'plangan keratin bo'lib, ularni mexanik yo'l bilan siqib chiqarish tavsiya etilmaydi. Tarkibida salitsil kislotasi, niatsinamid yoki retinol bo'lgan vositalar poralarning tiqilib qolishini kamaytiradi va jiroviklarni asta-sekin yo'qotishga yordam beradi.

Yuzni kuniga 2 marta yengil gel teksturali penka bilan tozalang. Haftasiga 1–2 marta AHA/BHA eksfoliatsiya poralarni chuqur tozalaydi. Komedogen (poralarni berkituvchi) og'ir kremlardan saqlaning.''',
        '''У вас есть белые точки (милиумы).

Милиумы — это кератин, скопившийся под кожей; выдавливать их механически не стоит. Средства с салициловой кислотой, ниацинамидом или ретинолом реже дают порам забиваться и убирают милиумы постепенно.

Умывайтесь дважды в день лёгкой гелевой пенкой. Эксфолиация AHA/BHA 1–2 раза в неделю очищает поры глубже. Избегайте комедогенных плотных кремов.''',
        '''You have whiteheads (milia).

Milia are keratin trapped under the skin, and squeezing them out mechanically is not advised. Products with salicylic acid, niacinamide or retinol keep the pores from clogging and clear milia gradually.

Wash twice a day with a light gel foam. An AHA/BHA exfoliation once or twice a week cleans the pores more deeply. Avoid heavy, comedogenic creams.''',
      ),
    ),
    'P': (
      title: LocalizedText(
          "Dog', sepkillar", 'Пятна и веснушки', 'Spots and freckles'),
      text: LocalizedText(
        '''Teringiz dog'ga, pigmentatsiyaga moyil.

Yuzni kuniga 2 marta yumshoq tozalagich bilan tozalang. Tarkibida vitamin C, niacinamide, arbutin yoki AHA kislotalari bo'lgan serum va kremlar dog'larni asta-sekin kamaytirishga yordam beradi. Har kuni SPF 50++ quyoshdan himoya kremi qo'llash juda muhim, chunki quyosh nuri pigmentatsiyani kuchaytiradi.

Haftasiga 1–2 marta yengil eksfoliatsiya (AHA/BHA) qilish ham teri rangini bir tekis qilishga yordam beradi. Doimiy va to'g'ri parvarish bilan dog'lar sekin-asta kamayib, teri yanada tiniq va yorqin ko'rinadi. Natija uchun 2–3 oy sabr talab etiladi.''',
        '''Ваша кожа склонна к пятнам и пигментации.

Умывайтесь дважды в день мягким средством. Сыворотки и кремы с витамином C, ниацинамидом, арбутином или AHA-кислотами постепенно осветляют пятна. Ежедневный SPF 50++ обязателен: солнце усиливает пигментацию.

Лёгкая эксфолиация (AHA/BHA) 1–2 раза в неделю тоже выравнивает тон. При постоянном и правильном уходе пятна светлеют, а кожа выглядит чище и ярче. На результат нужно 2–3 месяца терпения.''',
        '''Your skin is prone to spots and pigmentation.

Wash twice a day with a gentle cleanser. Serums and creams with vitamin C, niacinamide, arbutin or AHA acids fade spots gradually. A daily SPF 50++ matters most of all — sunlight deepens pigmentation.

A mild exfoliation (AHA/BHA) once or twice a week also evens out the tone. With consistent care the spots fade and the skin looks clearer and brighter. Give it two to three months.''',
      ),
    ),
    'Ew': (
      title: LocalizedText("Ko'z atrofidagi ajinlar",
          'Морщины вокруг глаз', 'Lines around the eyes'),
      text: LocalizedText(
        '''Ko'z atrofida mayda ajinlar aniqlandi.

Ko'z atrofidagi teri juda nozik bo'lgani uchun maxsus ko'z krem ishlatish muhim. Tarkibida gialuron kislotasi, peptidlar yoki kollagen bo'lgan kremlar terini namlaydi va ajinlarning ko'rinishini kamaytirishga yordam beradi.

Ko'z atrofini yumshoq massaj qilish, yetarli uyqu va ekrandan tez-tez dam olish ham muhim.''',
        '''Обнаружены мелкие морщинки вокруг глаз.

Кожа вокруг глаз очень тонкая, поэтому важен отдельный крем для век. Кремы с гиалуроновой кислотой, пептидами или коллагеном увлажняют кожу и делают морщинки менее заметными.

Мягкий массаж вокруг глаз, достаточный сон и регулярные перерывы от экрана тоже важны.''',
        '''Fine lines were found around your eyes.

The skin around the eyes is very thin, so a dedicated eye cream matters. Creams with hyaluronic acid, peptides or collagen hydrate the skin and soften the look of the lines.

Gentle massage around the eyes, enough sleep and regular breaks from the screen matter just as much.''',
      ),
    ),
    'Ed': (
      title: LocalizedText("Ko'z tagidagi qorayishlar",
          'Тёмные круги под глазами', 'Dark circles'),
      text: LocalizedText(
        '''Ko'z tagida qorayishlar bor.

Ko'z atrofidagi nozik teri uchun maxsus ko'z krem ishlatish muhim. Tarkibida vitamin C, kofein yoki niatsinamid bo'lgan kremlar teri rangini yorqinlashtirishga va qorayishni kamaytirishga yordam beradi.

Yetarli uyqu, ko'proq suv ichish va ko'z atrofini yumshoq parvarish qilish ham muhim — uyqu yetishmasligi qorayishning eng keng tarqalgan sababi.''',
        '''Под глазами есть тёмные круги.

Для тонкой кожи вокруг глаз важен отдельный крем. Кремы с витамином C, кофеином или ниацинамидом осветляют кожу и уменьшают темноту.

Достаточный сон, больше воды и бережный уход за зоной вокруг глаз тоже важны — недосып самая частая причина кругов.''',
        '''You have dark circles under your eyes.

The thin skin around the eyes needs its own cream. Creams with vitamin C, caffeine or niacinamide brighten the area and reduce the darkness.

Enough sleep, more water and gentle care around the eyes matter too — lack of sleep is the most common cause.''',
      ),
    ),
    'W': (
      title: LocalizedText('Ajinli, osilgan yuz',
          'Морщины и потеря упругости', 'Lines and lost firmness'),
      text: LocalizedText(
        '''Teringiz elastikligini yo'qotgan, ajinlar va terida osilish kuzatilmoqda.

Tarkibida retinol, peptidlar, kollagen va gialuron kislotasi bo'lgan serum yoki krem ishlatish teri elastikligini oshirishga yordam beradi. Har kuni SPF krem qo'llash juda muhim, chunki quyosh nuri ajinlarni tezlashtiradi.

Haftasiga 1–2 marta namlovchi va tiklovchi maskalar qilish, hamda yuz massaji yoki yuz-yoga mashqlari terining tarangligini yaxshilashga yordam beradi. Doimiy parvarish bilan teri yanada silliq, tarang va sog'lom ko'rinadi.''',
        '''Кожа потеряла упругость: заметны морщины и провисание.

Сыворотки и кремы с ретинолом, пептидами, коллагеном и гиалуроновой кислотой помогают вернуть упругость. Ежедневный SPF критичен — солнце ускоряет появление морщин.

Увлажняющие и восстанавливающие маски 1–2 раза в неделю, а также массаж лица или фейс-йога улучшают тонус. При постоянном уходе кожа выглядит глаже, подтянутее и здоровее.''',
        '''Your skin has lost firmness — lines and some sagging are showing.

Serums and creams with retinol, peptides, collagen and hyaluronic acid help bring elasticity back. A daily SPF is critical — sunlight speeds lines up.

Hydrating and repairing masks once or twice a week, plus facial massage or face yoga, improve the tone. With consistent care the skin looks smoother, firmer and healthier.''',
      ),
    ),
    'Ao': (
      title: LocalizedText("Husnbuzarlar (yog'li teri)",
          'Высыпания (жирная кожа)', 'Breakouts (oily skin)'),
      text: LocalizedText(
        '''Husnbuzarlar bilan ham ishlash kerak.

Yuzni kuniga 2 marta yumshoq antibakterial penka bilan tozalash, tarkibida salitsil kislotasi, niatsinamid, yashil choy ekstrakti bo'lgan vositalardan foydalanish husnbuzarlarni kamaytirishga yordam beradi. Teri toza bo'lishi uchun yengil eksfoliatsiya haftasiga 1–2 marta qilish mumkin.

Juda yog'li va poralarni yopib qo'yadigan kremlardan saqlaning, husnbuzarlarni siqmang. Aktiv bo'lgan holatda terini tinchlantiruvchi tarkibli mahsulotlardan ishlating, iloji boricha makiyaj qilmasdan, yuzingizga ko'p teginmang. Har kuni SPF krem ishlatish ham dog' paydo bo'lishining oldini oladi.

Muhim: husnbuzarlar asosan ichki sabablardan — gormonal o'zgarishlar, noto'g'ri ovqatlanish, uyqu betartibligi, oshqozon-ichak muammolaridan paydo bo'ladi. Aktiv holatda ham ichki, ham tashqi tomondan davolanish tavsiya etiladi: shifokor-dermatologga yoki endokrinologga ko'rinish foydali bo'lishi mumkin.''',
        '''С высыпаниями тоже нужно работать.

Умывание дважды в день мягкой антибактериальной пенкой и средства с салициловой кислотой, ниацинамидом и экстрактом зелёного чая помогают уменьшить высыпания. Лёгкую эксфолиацию можно делать 1–2 раза в неделю.

Избегайте плотных кремов, забивающих поры, и не выдавливайте высыпания. В активной фазе используйте успокаивающие средства, по возможности откажитесь от макияжа и не трогайте лицо руками. Ежедневный SPF предотвращает появление пятен после высыпаний.

Важно: высыпания чаще всего идут изнутри — гормональные изменения, питание, нарушенный сон, проблемы ЖКТ. В активной фазе лечиться стоит и снаружи, и изнутри: имеет смысл показаться дерматологу или эндокринологу.''',
        '''Breakouts need attention too.

Washing twice a day with a gentle antibacterial foam, plus products with salicylic acid, niacinamide and green tea extract, helps reduce breakouts. A mild exfoliation once or twice a week is fine.

Avoid heavy, pore-clogging creams and do not squeeze spots. While things are active, use calming products, skip makeup where you can and keep your hands off your face. A daily SPF also stops post-breakout marks forming.

Important: breakouts usually come from the inside — hormonal changes, diet, disrupted sleep, gut problems. While things are active it is worth treating both inside and out: a dermatologist or an endocrinologist is a sensible visit.''',
      ),
    ),
    'Ad': (
      title: LocalizedText('Husnbuzarlar (quruq teri)',
          'Высыпания (сухая кожа)', 'Breakouts (dry skin)'),
      text: LocalizedText(
        '''Quruq terida ham husnbuzar paydo bo'lishi mumkin, shuning uchun parvarish juda yumshoq va namlovchi bo'lishi kerak.

Yuzni kuniga 2 marta yumshoq, terini quritmaydigan penka bilan tozalash tavsiya etiladi. Tarkibida niatsinamid yoki past konsentratsiyadagi salitsil kislotasi bo'lgan vositalar husnbuzarlarni kamaytirishga yordam beradi. Gialuron kislotasi yoki namlovchi krem terining qurib ketishini oldini oladi.

Juda agressiv skrablar va qurituvchi mahsulotlardan saqlaning, har kuni SPF krem qo'llang.

Muhim: husnbuzarlar asosan ichki sabablardan — gormonal o'zgarishlar, noto'g'ri ovqatlanish, uyqu betartibligi, oshqozon-ichak muammolaridan paydo bo'ladi. Aktiv holatda ham ichki, ham tashqi tomondan davolanish tavsiya etiladi: shifokor-dermatologga yoki endokrinologga ko'rinish foydali bo'lishi mumkin.''',
        '''Высыпания бывают и на сухой коже, поэтому уход должен быть очень мягким и увлажняющим.

Умывайтесь дважды в день мягкой пенкой, которая не сушит кожу. Средства с ниацинамидом или салициловой кислотой в низкой концентрации помогают уменьшить высыпания. Гиалуроновая кислота или увлажняющий крем не дадут коже пересохнуть.

Избегайте агрессивных скрабов и подсушивающих средств, наносите SPF каждый день.

Важно: высыпания чаще всего идут изнутри — гормональные изменения, питание, нарушенный сон, проблемы ЖКТ. В активной фазе лечиться стоит и снаружи, и изнутри: имеет смысл показаться дерматологу или эндокринологу.''',
        '''Dry skin breaks out too, so the care has to stay very gentle and hydrating.

Wash twice a day with a mild foam that does not strip the skin. Products with niacinamide or a low concentration of salicylic acid help reduce breakouts. Hyaluronic acid or a moisturiser keeps the skin from drying out.

Avoid aggressive scrubs and drying products, and apply SPF every day.

Important: breakouts usually come from the inside — hormonal changes, diet, disrupted sleep, gut problems. While things are active it is worth treating both inside and out: a dermatologist or an endocrinologist is a sensible visit.''',
      ),
    ),
  };
}

/// Reads a stored analysis back in whichever language is on now.
///
/// A [SkinResult] on disk carries both the codes and the Uzbek sentences that
/// were current when it was saved. These resolve the codes and fall back to the
/// stored text — so a profile from an older build, which has no codes worth
/// speaking of, still reads rather than coming back blank.
extension SkinCopyLookup on BuildContext {
  /// The skin type in the interface language: "Жирная", "Oily", "Yog'li".
  /// [stored] is the name as saved, used when the code is one we no longer
  /// recognise.
  String skinTypeLabel(String code, {required String stored}) {
    final copy = SkinCopy.skinTypes[code];
    return copy == null ? stored : tr(copy);
  }

  String baseRecommendation(String code, {required String stored}) {
    final copy = SkinCopy.baseRecommendations[code];
    return copy == null ? stored : tr(copy);
  }

  /// One concern block. [stored] supplies both halves for a code that is not
  /// in the table.
  ({String title, String text}) concernBlock(
    String? code, {
    required String storedTitle,
    required String storedText,
  }) {
    final copy = code == null ? null : SkinCopy.blocks[code];
    if (copy == null) return (title: storedTitle, text: storedText);
    return (title: tr(copy.title), text: tr(copy.text));
  }
}
