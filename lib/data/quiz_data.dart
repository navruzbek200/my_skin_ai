import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/models/quiz_question.dart';

/// The questionnaire, in uz / ru / en.
///
/// Ordered by what the scoring engine needs first: the single skin-type
/// question opens, and the nine concern questions follow. The `id` on each is
/// what the engine and the stored profile key off — reorder the list freely,
/// but never renumber an id.
const quizGroups = [
  QuizGroup(
    title: LocalizedText('Teri tipi', 'Тип кожи', 'Skin type'),
    range: (0, 0),
  ),
  QuizGroup(
    title: LocalizedText('Muammolar', 'Проблемы', 'Concerns'),
    range: (1, 9),
  ),
];

final List<QuizQuestion> quizQuestions = [
  // 0 — skin type (q1)
  const QuizQuestion(
    index: 0,
    id: 'q1',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuzingizni yuvgandan keyin 1 soat davomida hech qanday krem surtilmasa, teringiz qanday holatda bo'ladi?",
      'Если через час после умывания не наносить никакой крем, в каком состоянии будет ваша кожа?',
      'An hour after washing your face, with no cream applied — how does your skin feel?',
    ),
    scaleLabels: [
      LocalizedText('Juda quruq, tortiladi', 'Очень сухая, стягивает',
          'Very dry, tight'),
      LocalizedText('Biroz quruq', 'Слегка сухая', 'Slightly dry'),
      LocalizedText("Yanoqlar quruq, T-zona yog'li",
          'Щёки сухие, Т-зона жирная', 'Dry cheeks, oily T-zone'),
      LocalizedText('Normal va qulay', 'Нормальная и комфортная',
          'Normal and comfortable'),
      LocalizedText("Yog'lanadi", 'Жирнеет', 'Gets oily'),
      LocalizedText("Juda tez yog'lanadi", 'Очень быстро жирнеет',
          'Gets oily very quickly'),
    ],
  ),
  // 1 — pores (q4)
  const QuizQuestion(
    index: 1,
    id: 'q4',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuzingizda poralar qanchalik katta ko'rinadi?",
      'Насколько заметны поры на вашем лице?',
      'How large do the pores on your face look?',
    ),
    scaleLabels: [
      LocalizedText('Umuman sezilmaydi', 'Совсем не заметны',
          'Not noticeable at all'),
      LocalizedText('Juda kichik', 'Очень мелкие', 'Very small'),
      LocalizedText('Biroz seziladi', 'Слегка заметны', 'Slightly noticeable'),
      LocalizedText('Ancha kattaroq', 'Заметно крупнее', 'Noticeably larger'),
      LocalizedText("Katta va aniq ko'rinadi", 'Крупные и заметные',
          'Large and clearly visible'),
      LocalizedText("Juda katta va aniq ko'rinadi", 'Очень крупные и заметные',
          'Very large and obvious'),
    ],
  ),
  // 2 — sensitivity (q13)
  const QuizQuestion(
    index: 2,
    id: 'q13',
    type: QuestionType.scale,
    text: LocalizedText(
      'Teringizda allergik reaksiyalar qanchalik tez-tez uchraydi?',
      'Как часто у вас бывают аллергические реакции на коже?',
      'How often does your skin react allergically?',
    ),
    scaleLabels: [
      LocalizedText("Umuman bo'lmagan", 'Никогда не было', 'Never'),
      LocalizedText('Juda kam (yiliga 1-2)', 'Очень редко (1–2 раза в год)',
          'Very rarely (1–2 a year)'),
      LocalizedText("Ba'zan uchraydi", 'Иногда бывает', 'Sometimes'),
      LocalizedText('Tez-tez uchraydi', 'Довольно часто', 'Fairly often'),
      LocalizedText("Ko'pincha uchraydi", 'Часто', 'Often'),
      LocalizedText('Juda tez uchraydi', 'Очень часто', 'Very often'),
    ],
  ),
  // 3 — acne (q15)
  const QuizQuestion(
    index: 3,
    id: 'q15',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuzingizda husnbuzarlar qanchalik tez-tez paydo bo'ladi?",
      'Как часто на лице появляются высыпания?',
      'How often do breakouts appear on your face?',
    ),
    scaleLabels: [
      LocalizedText('Umuman chiqmaydi', 'Совсем не появляются', 'Never'),
      LocalizedText('Juda kam (yiliga 1-2)', 'Очень редко (1–2 раза в год)',
          'Very rarely (1–2 a year)'),
      LocalizedText("Ba'zan (oyda 1-2)", 'Иногда (1–2 раза в месяц)',
          'Sometimes (1–2 a month)'),
      LocalizedText('Tez-tez (oyda 3-5)', 'Часто (3–5 раз в месяц)',
          'Often (3–5 a month)'),
      LocalizedText("Ko'p (haftada 1-2)", 'Много (1–2 раза в неделю)',
          'A lot (1–2 a week)'),
      LocalizedText('Har doim chiqadi', 'Постоянно', 'Constantly'),
    ],
  ),
  // 4 — blackheads (q18)
  const QuizQuestion(
    index: 4,
    id: 'q18',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuzingizda qora nuqtalar qanchalik ko'p?",
      'Много ли на лице чёрных точек?',
      'How many blackheads do you have?',
    ),
    scaleLabels: _amountScale,
  ),
  // 5 — whiteheads (q19)
  const QuizQuestion(
    index: 5,
    id: 'q19',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuzingizda oq nuqtalar (jiroviklar) qanchalik ko'p?",
      'Много ли на лице белых точек (милиумов)?',
      'How many whiteheads (milia) do you have?',
    ),
    scaleLabels: _amountScale,
  ),
  // 6 — pigmentation (q23)
  const QuizQuestion(
    index: 6,
    id: 'q23',
    type: QuestionType.scale,
    text: LocalizedText(
      "Teringiz dog'ga, pigmentatsiyaga moyilmi?",
      'Склонна ли ваша кожа к пятнам и пигментации?',
      'Is your skin prone to dark spots and pigmentation?',
    ),
    scaleLabels: [
      LocalizedText('Umuman moyil emas', 'Совсем не склонна', 'Not at all'),
      LocalizedText('Juda kam moyil', 'Очень мало склонна', 'Barely'),
      LocalizedText('Biroz moyil', 'Немного склонна', 'Slightly'),
      LocalizedText("O'rtacha moyil", 'Умеренно склонна', 'Moderately'),
      LocalizedText("Ko'p moyil", 'Сильно склонна', 'Strongly'),
      LocalizedText('Juda moyil', 'Очень сильно склонна', 'Very strongly'),
    ],
  ),
  // 7 — eye wrinkles (q27)
  const QuizQuestion(
    index: 7,
    id: 'q27',
    type: QuestionType.scale,
    text: LocalizedText(
      "Ko'z atrofida mayda ajinlar qanchalik ko'rinadi?",
      'Насколько заметны мелкие морщинки вокруг глаз?',
      'How visible are the fine lines around your eyes?',
    ),
    scaleLabels: [
      LocalizedText('Umuman sezilmaydi', 'Совсем не заметны', 'Not at all'),
      LocalizedText('Juda kam seziladi', 'Едва заметны', 'Barely visible'),
      LocalizedText('Biroz seziladi', 'Слегка заметны', 'Slightly visible'),
      LocalizedText('Ancha seziladi', 'Заметны', 'Noticeable'),
      LocalizedText("Ko'p seziladi", 'Хорошо заметны', 'Clearly visible'),
      LocalizedText('Juda sezilarli', 'Очень заметны', 'Very pronounced'),
    ],
  ),
  // 8 — eye dark circles (q28)
  const QuizQuestion(
    index: 8,
    id: 'q28',
    type: QuestionType.scale,
    text: LocalizedText(
      "Ko'z tagida qorayishlar bormi?",
      'Есть ли тёмные круги под глазами?',
      'Do you have dark circles under your eyes?',
    ),
    scaleLabels: [
      LocalizedText("Umuman yo'q", 'Совсем нет', 'None at all'),
      LocalizedText('Juda och', 'Очень светлые', 'Very faint'),
      LocalizedText("Biroz ko'rinadi", 'Слегка заметны', 'Slightly visible'),
      LocalizedText("Ancha ko'rinadi", 'Заметны', 'Noticeable'),
      LocalizedText("To'q ko'rinadi", 'Тёмные', 'Dark'),
      LocalizedText("Juda to'q", 'Очень тёмные', 'Very dark'),
    ],
  ),
  // 9 — sagging (q32)
  const QuizQuestion(
    index: 9,
    id: 'q32',
    type: QuestionType.scale,
    text: LocalizedText(
      "Yuz terisi qanchalik bo'shashgan yoki tarangligini yo'qotgan?",
      'Насколько кожа лица потеряла упругость?',
      'How much firmness has your facial skin lost?',
    ),
    scaleLabels: [
      LocalizedText("Umuman yo'qotmagan", 'Совсем не потеряла',
          'None at all'),
      LocalizedText("Juda oz yo'qotgan", 'Потеряла совсем немного',
          'Very little'),
      LocalizedText("Biroz yo'qotgan", 'Немного потеряла', 'A little'),
      LocalizedText("Ancha yo'qotgan", 'Заметно потеряла', 'Noticeably'),
      LocalizedText("Ko'p yo'qotgan", 'Сильно потеряла', 'A lot'),
      LocalizedText("Juda ko'p yo'qotgan", 'Очень сильно потеряла',
          'A great deal'),
    ],
  ),
];

/// Shared by the two "how many" questions, which are worded identically on
/// purpose — one scale, defined once, so the wording cannot drift between them.
const _amountScale = [
  LocalizedText("Umuman yo'q", 'Совсем нет', 'None at all'),
  LocalizedText('Juda kam', 'Очень мало', 'Very few'),
  LocalizedText('Biroz bor', 'Немного есть', 'A few'),
  LocalizedText("O'rtacha", 'Умеренно', 'A moderate amount'),
  LocalizedText("Ko'p", 'Много', 'A lot'),
  LocalizedText("Juda ko'p", 'Очень много', 'Very many'),
];
