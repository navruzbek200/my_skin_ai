import 'package:real_beauty_ai/core/l10n/localized_text.dart';

import '../models/source.dart';

/// Every reference the app cites, grouped by the claim it backs.
///
/// Added for App Store Guideline 1.4.1: any screen that says what an
/// ingredient does or how to treat a skin concern has to show where that
/// comes from. Every URL here was checked by hand on 2026-09-23. Never add
/// one that has not been opened and read — a citation that does not say what
/// the copy says is worse than none.
class Sources {
  const Sources._();

  /// When every URL below was last opened and checked by hand. Shown on the
  /// sources screen; move it forward whenever the list is re-checked.
  static final checkedOn = DateTime(2026, 9, 23);

  // ── Dry skin ──
  static const drySkin = [
    Source(
      "American Academy of Dermatology — Dermatologists' tips for relieving dry skin",
      'https://www.aad.org/public/everyday-care/skin-care-basics/dry/dermatologists-tips-relieve-dry-skin',
    ),
    Source(
      'American Academy of Dermatology — Dry skin: overview',
      'https://aad.org/public/diseases/a-z/dry-skin-overview',
    ),
  ];

  // ── Milia (questionnaire, whiteheads block) ──
  static const milia = [
    Source('DermNet — Milium', 'https://dermnetnz.org/topics/milium'),
    Source(
      'NCBI StatPearls — Milia',
      'https://www.ncbi.nlm.nih.gov/books/NBK560481/',
    ),
  ];

  // ── Redness ──
  static const redness = [
    Source(
      'American Academy of Dermatology — 7 rosacea skin care tips',
      'https://www.aad.org/news/7-rosacea-skin-care-tips',
    ),
    Source(
      'American Academy of Dermatology — How to prevent rosacea flare-ups',
      'https://www.aad.org/public/diseases/rosacea/triggers/prevent',
    ),
    Source(
      'DermNet — Azelaic acid',
      'https://dermnetnz.org/topics/azelaic-acid',
    ),
  ];

  // ── Ingredients ──
  static const naturalLabel = [
    Source(
      'U.S. FDA — "Organic" Cosmetics (labeling terms)',
      'https://www.fda.gov/cosmetics/labeling-claims/organic-cosmetics',
    ),
  ];
  static const niacinamide = [
    Source(
      'Marques et al., 2024 — Niacinamide: mechanisms and cosmeceutical applications',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC11047333',
    ),
  ];
  static const vitaminE = [
    Source(
      'Keen & Hassan, 2016 — Vitamin E in dermatology',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC4976416/',
    ),
  ];
  static const retinol = [
    Source(
      'Mukherjee et al., 2006 — Retinoids in the treatment of skin aging',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC2699641/',
    ),
  ];
  static const vitaminC = [
    Source(
      'Al-Niaimi & Chiang, 2017 — Topical vitamin C and the skin',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC5605218/',
    ),
  ];
  static const aloeVera = [
    Source(
      'Surjushe et al., 2008 — Aloe vera: a short review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC2763764',
    ),
  ];
  static const polyphenols = [
    Source(
      'OyetakinWhite et al., 2012 — Protective mechanisms of green tea polyphenols in skin',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC3390139',
    ),
  ];
  static const carotenoids = [
    Source(
      'Torres, Luk & Lim, 2020 — Botanicals for photoprotection',
      'https://dx.doi.org/10.20517/2347-9264.2020.87',
    ),
  ];
  static const licorice = [
    Source(
      'J Drugs Dermatol — Botanical extracts in East Asia for hyperpigmentation',
      'https://jddonline.com/articles/the-use-of-botanical-extracts-in-east-asia-for-treatment-of-hyperpigmentation-an-evidenced-based-rev-S1545961620P0758X/',
    ),
  ];
  static const essentialOils = [
    Source(
      'DermNet — Allergic contact dermatitis to essential oils',
      'https://dermnetnz.org/topics/allergic-contact-dermatitis-to-essential-oils',
    ),
  ];

  // ── "Natural ingredients" article: all of the above it touches ──
  static const naturalArticle = [
    ...naturalLabel,
    ...niacinamide,
    ...vitaminE,
    ...retinol,
    ...vitaminC,
    ...aloeVera,
    ...polyphenols,
    ...carotenoids,
    ...licorice,
    ...essentialOils,
  ];

  // ── Added after 1.2.0 (7): every URL below opened and its title checked by
  // hand on 2026-09-23, same as the list above. ──

  static const sunscreen = [
    Source(
      'American Academy of Dermatology — How to select a sunscreen',
      'https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/how-to-select-sunscreen',
    ),
    Source(
      'American Academy of Dermatology — How to apply sunscreen',
      'https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/how-to-apply-sunscreen',
    ),
    Source(
      'American Academy of Dermatology — Sunscreen FAQs',
      'https://www.aad.org/media/stats-sunscreen',
    ),
    Source(
      'U.S. FDA — Sunscreen: how to help protect your skin from the sun',
      'https://www.fda.gov/drugs/understanding-over-counter-medicines/sunscreen-how-help-protect-your-skin-sun',
    ),
  ];
  static const acne = [
    Source(
      'American Academy of Dermatology — Acne: diagnosis and treatment',
      'https://www.aad.org/public/diseases/acne/derm-treat/treat',
    ),
    Source(
      'American Academy of Dermatology — Adult acne treatment dermatologists recommend',
      'https://www.aad.org/public/diseases/acne/diy/adult-acne-treatment',
    ),
    Source(
      'American Academy of Dermatology — Skin care for acne-prone skin',
      'https://www.aad.org/public/diseases/acne/skin-care',
    ),
    Source('DermNet — Acne', 'https://dermnetnz.org/topics/acne'),
  ];
  static const acneDiet = [
    Source(
      'American Academy of Dermatology — Can the right diet get rid of acne?',
      'https://www.aad.org/public/diseases/acne/causes/diet',
    ),
  ];
  static const salicylicAcid = [
    Source(
      'DermNet — Salicylic acid',
      'https://dermnetnz.org/topics/salicylic-acid',
    ),
  ];
  static const benzoylPeroxide = [
    Source(
      'DermNet — Benzoyl peroxide',
      'https://dermnetnz.org/topics/benzoyl-peroxide',
    ),
  ];
  static const comedones = [
    Source('DermNet — Comedo', 'https://dermnetnz.org/topics/comedones'),
  ];
  static const exfoliation = [
    Source(
      'American Academy of Dermatology — How to safely exfoliate at home',
      'https://www.aad.org/public/everyday-care/skin-care-secrets/routine/safely-exfoliate-at-home',
    ),
    Source(
      'DermNet — Alpha hydroxy acid facial treatments',
      'https://dermnetnz.org/topics/alpha-hydroxy-acid-facial-treatments',
    ),
    Source(
      'Dual effects of alpha-hydroxy acids on the skin — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC6017965/',
    ),
  ];
  static const oilySkin = [
    Source(
      'American Academy of Dermatology — How to control oily skin',
      'https://www.aad.org/public/everyday-care/skin-care-basics/dry/oily-skin',
    ),
  ];
  static const pores = [
    Source(
      'American Academy of Dermatology — What can treat large facial pores?',
      'https://aad.org/public/skin-hair-nails/skin-care/pores',
    ),
  ];
  static const skinCareBasics = [
    Source(
      'American Academy of Dermatology — 10 skin care secrets for healthier-looking skin',
      'https://www.aad.org/public/everyday-care/skin-care-basics/care/skin-care-tips-dermatologists-use',
    ),
    Source(
      'DermNet — Emollients and moisturisers',
      'https://dermnetnz.org/topics/emollients-and-moisturisers',
    ),
  ];
  static const skinAging = [
    Source(
      'American Academy of Dermatology — 11 ways to reduce premature skin aging',
      'https://www.aad.org/public/everyday-care/skin-care-secrets/anti-aging/reduce-premature-aging-skin',
    ),
    Source(
      'A review of the effects of lifestyle factors on skin aging',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC13179309/',
    ),
  ];
  static const blueLight = [
    Source(
      'Blue light in dermatology — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC8307003/',
    ),
  ];
  static const hyaluronicAcid = [
    Source(
      'Hyaluronic acid: a key molecule in skin aging — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC3583886/',
    ),
    Source(
      'Benefits of topical hyaluronic acid for skin quality and signs of skin aging',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC10078143/',
    ),
  ];
  static const ceramides = [
    Source(
      'Ceramide-containing formulations: water retention and barrier function — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC9293121/',
    ),
  ];
  static const panthenol = [
    Source(
      'Use of dexpanthenol (provitamin B5) — benefits based on current evidence',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC9322723/',
    ),
  ];
  static const centella = [
    Source(
      'Centella asiatica in cosmetology — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC3834700/',
    ),
  ];
  static const peptides = [
    Source(
      'Cosmeceuticals in photoaging: a review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC11375026/',
    ),
  ];
  static const darkCircles = [
    Source(
      'Infraorbital dark circles: pathogenesis, evaluation and treatment — review',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC4924417/',
    ),
  ];
  static const freckles = [
    Source(
      'DermNet — Ephelis (freckle)',
      'https://dermnetnz.org/topics/ephelis',
    ),
  ];
  static const pigmentation = [
    Source(
      'American Academy of Dermatology — Melasma: diagnosis and treatment',
      'https://www.aad.org/public/diseases/a-z/melasma-treatment',
    ),
  ];
  static const coldInjury = [
    Source('DermNet — Frostbite', 'https://dermnetnz.org/topics/frostbite'),
  ];
  static const faceExercise = [
    Source(
      'Alam et al., 2018 — Association of facial exercise with the appearance of aging (JAMA Dermatology)',
      'https://pubmed.ncbi.nlm.nih.gov/29299598/',
    ),
  ];

  // ── Per-article and per-lesson bundles ──
  static const koreanRoutine = [
    ...skinCareBasics,
    ...exfoliation,
    ...sunscreen,
  ];
  static const naturalIngredientsArticle = [
    ...naturalArticle,
    ...hyaluronicAcid,
  ];
  static const sleepArticle = [...skinAging, ...blueLight];
  static const dietAcneArticle = [...acneDiet, ...acne];
  static const iceArticle = [...coldInjury, ...pores];
  static const blueLightArticle = [...blueLight, ...skinAging];
  static const ageingMythsArticle = [...skinAging, ...sunscreen];

  /// The "Sources & methodology" screen, one group per topic.
  static const all = <({LocalizedText topic, List<Source> sources})>[
    (
      topic: LocalizedText(
        'Quruq teri va namlantirish',
        'Сухая кожа и увлажнение',
        'Dry skin and moisturising',
      ),
      sources: [
        ...drySkin,
        ...skinCareBasics,
        ...hyaluronicAcid,
        ...ceramides,
        ...panthenol,
      ],
    ),
    (
      topic: LocalizedText(
        "Yog'li teri va poralar",
        'Жирная кожа и поры',
        'Oily skin and pores',
      ),
      sources: [...oilySkin, ...pores, ...coldInjury],
    ),
    (
      topic: LocalizedText(
        'Husnbuzarlar va komedonlar',
        'Высыпания и комедоны',
        'Acne and comedones',
      ),
      sources: [
        ...acne,
        ...acneDiet,
        ...comedones,
        ...salicylicAcid,
        ...benzoylPeroxide,
      ],
    ),
    (
      topic: LocalizedText(
        'Qizarish va sezgir teri',
        'Покраснение и чувствительность',
        'Redness and sensitivity',
      ),
      sources: [...redness, ...centella],
    ),
    (
      topic: LocalizedText(
        'Mayda oq nuqtalar (milium)',
        'Мелкие белые точки (милиумы)',
        'Milia',
      ),
      sources: milia,
    ),
    (
      topic: LocalizedText(
        "Dog'lar va sepkillar",
        'Пятна и веснушки',
        'Spots and freckles',
      ),
      sources: [...pigmentation, ...freckles, ...licorice],
    ),
    (
      topic: LocalizedText(
        'Quyoshdan himoya',
        'Защита от солнца',
        'Sun protection',
      ),
      sources: sunscreen,
    ),
    (
      topic: LocalizedText(
        'Qarish, ajinlar va turmush tarzi',
        'Старение, морщины и образ жизни',
        'Ageing, lines and lifestyle',
      ),
      sources: [
        ...skinAging,
        ...retinol,
        ...peptides,
        ...darkCircles,
        ...faceExercise,
        ...blueLight,
      ],
    ),
    (
      topic: LocalizedText(
        'Eksfoliatsiya va pilinglar',
        'Эксфолиация и пилинги',
        'Exfoliation and peels',
      ),
      sources: exfoliation,
    ),
    (
      topic: LocalizedText('Ingrediyentlar', 'Ингредиенты', 'Ingredients'),
      sources: [
        ...naturalLabel,
        ...niacinamide,
        ...vitaminE,
        ...vitaminC,
        ...aloeVera,
        ...polyphenols,
        ...carotenoids,
        ...essentialOils,
      ],
    ),
  ];
}
