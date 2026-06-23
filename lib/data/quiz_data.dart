import '../models/quiz_question.dart';

const quizGroups = [
  QuizGroup(title: 'Teri tipi', range: (0, 0)),
  QuizGroup(title: 'Muammolar', range: (1, 9)),
  QuizGroup(title: "Qo'shimcha", range: (10, 11)),
];

final List<QuizQuestion> quizQuestions = [
  // 0 — skin type (q1)
  QuizQuestion(
    index: 0, id: 'q1', type: QuestionType.scale,
    text: "Yuzingizni yuvgandan keyin 1 soat davomida hech qanday krem surtilmasa, teringiz qanday holatda bo'ladi?",
    scaleLabels: [
      'Juda quruq, tortiladi',
      'Biroz quruq',
      "Yanoqlar quruq, T-zona yog'li",
      'Normal va qulay',
      "Yog'lanadi",
      "Juda tez yog'lanadi",
    ],
  ),
  // 1 — pores (q4)
  QuizQuestion(
    index: 1, id: 'q4', type: QuestionType.scale,
    text: "Yuzingizda poralar qanchalik katta ko'rinadi?",
    scaleLabels: [
      'Umuman sezilmaydi',
      'Juda kichik',
      'Biroz seziladi',
      'Ancha kattaroq',
      "Katta va aniq ko'rinadi",
      "Juda katta va aniq ko'rinadi",
    ],
  ),
  // 2 — sensitivity (q13)
  QuizQuestion(
    index: 2, id: 'q13', type: QuestionType.scale,
    text: "Teringizda allergik reaksiyalar qanchalik tez-tez uchraydi?",
    scaleLabels: [
      "Umuman bo'lmagan",
      'Juda kam (yiliga 1-2)',
      "Ba'zan uchraydi",
      'Tez-tez uchraydi',
      "Ko'pincha uchraydi",
      'Juda tez uchraydi',
    ],
  ),
  // 3 — acne (q15)
  QuizQuestion(
    index: 3, id: 'q15', type: QuestionType.scale,
    text: "Yuzingizda husnbuzarlar qanchalik tez-tez paydo bo'ladi?",
    scaleLabels: [
      'Umuman chiqmaydi',
      'Juda kam (yiliga 1-2)',
      "Ba'zan (oyda 1-2)",
      'Tez-tez (oyda 3-5)',
      "Ko'p (haftada 1-2)",
      'Har doim chiqadi',
    ],
  ),
  // 4 — blackheads (q18)
  QuizQuestion(
    index: 4, id: 'q18', type: QuestionType.scale,
    text: "Yuzingizda qora nuqtalar qanchalik ko'p?",
    scaleLabels: [
      "Umuman yo'q",
      'Juda kam',
      'Biroz bor',
      "O'rtacha",
      "Ko'p",
      "Juda ko'p",
    ],
  ),
  // 5 — whiteheads (q19)
  QuizQuestion(
    index: 5, id: 'q19', type: QuestionType.scale,
    text: "Yuzingizda oq nuqtalar (jiroviklar) qanchalik ko'p?",
    scaleLabels: [
      "Umuman yo'q",
      'Juda kam',
      'Biroz bor',
      "O'rtacha",
      "Ko'p",
      "Juda ko'p",
    ],
  ),
  // 6 — pigmentation (q23)
  QuizQuestion(
    index: 6, id: 'q23', type: QuestionType.scale,
    text: "Teringiz dog'ga, pigmentatsiyaga moyilmi?",
    scaleLabels: [
      'Umuman moyil emas',
      'Juda kam moyil',
      'Biroz moyil',
      "O'rtacha moyil",
      "Ko'p moyil",
      'Juda moyil',
    ],
  ),
  // 7 — eye wrinkles (q27)
  QuizQuestion(
    index: 7, id: 'q27', type: QuestionType.scale,
    text: "Ko'z atrofida mayda ajinlar qanchalik ko'rinadi?",
    scaleLabels: [
      'Umuman sezilmaydi',
      'Juda kam seziladi',
      'Biroz seziladi',
      'Ancha seziladi',
      "Ko'p seziladi",
      'Juda sezilarli',
    ],
  ),
  // 8 — eye dark circles (q28)
  QuizQuestion(
    index: 8, id: 'q28', type: QuestionType.scale,
    text: "Ko'z tagida qorayishlar bormi?",
    scaleLabels: [
      "Umuman yo'q",
      "Juda och",
      "Biroz ko'rinadi",
      "Ancha ko'rinadi",
      "To'q ko'rinadi",
      "Juda to'q",
    ],
  ),
  // 9 — sagging (q32)
  QuizQuestion(
    index: 9, id: 'q32', type: QuestionType.scale,
    text: "Yuz terisi qanchalik bo'shashgan yoki tarangligini yo'qotgan?",
    scaleLabels: [
      "Umuman yo'qotmagan",
      "Juda oz yo'qotgan",
      "Biroz yo'qotgan",
      "Ancha yo'qotgan",
      "Ko'p yo'qotgan",
      "Juda ko'p yo'qotgan",
    ],
  ),
  // 10 — age (new)
  QuizQuestion(
    index: 10, id: 'age', type: QuestionType.scale,
    text: "Yoshingiz nechada?",
    scaleLabels: ['18 dan kichik', '18–24', '25–34', '35–44', '45+', '—'],
  ),
  // 11 — primary concern (new)
  QuizQuestion(
    index: 11, id: 'primary', type: QuestionType.choice,
    text: "Sizni eng ko'p bezovta qiladigan muammo qaysi?",
    options: [
      'Husnbuzar / qora nuqta',
      "Pigmentatsiya / dog'lar",
      'Quruqlik / namsizlik',
      "Ajin / bo'shashish",
      "Ko'z atrofi",
      'Sezgirlik / qizarish',
    ],
  ),
];
