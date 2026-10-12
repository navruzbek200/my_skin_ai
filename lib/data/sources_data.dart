/// Citation registry for every care note the app shows.
///
/// App Review rejected 1.0 (7) twice under guideline 1.4.1 because the care
/// notes read as health information with nothing behind them. Each note now
/// carries a [SkinSource] id, the results screen prints the publisher under
/// the note, and /sources lists the whole set with tappable links — reachable
/// from the analysis tab, the results screen and the account screen, so a
/// reviewer finds it without hunting.
///
/// Every url here was checked to resolve. Add nothing to this list that has
/// not been opened and read: a dead citation is worse than none.
class SkinSource {
  final String id;
  final String title;
  final String publisher;
  final String url;

  const SkinSource({
    required this.id,
    required this.title,
    required this.publisher,
    required this.url,
  });
}

const _aad = 'American Academy of Dermatology';
const _medlinePlus = 'MedlinePlus — U.S. National Library of Medicine';
const _fda = 'U.S. Food and Drug Administration';
const _who = 'World Health Organization';

const List<SkinSource> skinSources = [
  SkinSource(
    id: 'aad_basics',
    title: 'Skin care tips dermatologists use',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-basics/care/skin-care-tips-dermatologists-use',
  ),
  SkinSource(
    id: 'aad_wash',
    title: 'Face washing 101',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-basics/care/face-washing-101',
  ),
  SkinSource(
    id: 'aad_dry',
    title: 'Dermatologists\' tips for relieving dry skin',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-basics/dry/dermatologists-tips-relieve-dry-skin',
  ),
  SkinSource(
    id: 'aad_oily',
    title: 'How to control oily skin',
    publisher: _aad,
    url: 'https://www.aad.org/public/everyday-care/skin-care-basics/dry/oily-skin',
  ),
  SkinSource(
    id: 'aad_moisturizer',
    title: 'How to pick the right moisturizer for your skin',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-basics/dry/pick-moisturizer',
  ),
  SkinSource(
    id: 'aad_sunscreen',
    title: 'How to apply sunscreen',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/how-to-apply-sunscreen',
  ),
  SkinSource(
    id: 'aad_acne_care',
    title: 'Skin care for acne-prone skin',
    publisher: _aad,
    url: 'https://www.aad.org/public/diseases/acne/skin-care',
  ),
  SkinSource(
    id: 'aad_acne_tips',
    title: 'Acne: tips for managing',
    publisher: _aad,
    url: 'https://www.aad.org/public/diseases/acne/skin-care/tips',
  ),
  SkinSource(
    id: 'aad_aging',
    title: 'How to reduce premature ageing of the skin',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-secrets/anti-aging/reduce-premature-aging-skin',
  ),
  SkinSource(
    id: 'aad_routine',
    title: '10 skin care secrets for healthier-looking skin',
    publisher: _aad,
    url:
        'https://www.aad.org/public/everyday-care/skin-care-secrets/routine/healthier-looking-skin',
  ),
  SkinSource(
    id: 'fda_sunscreen',
    title: 'Sunscreen: how to help protect your skin from the sun',
    publisher: _fda,
    url:
        'https://www.fda.gov/drugs/understanding-over-counter-medicines/sunscreen-how-help-protect-your-skin-sun',
  ),
  SkinSource(
    id: 'medline_aging_skin',
    title: 'Aging changes in skin',
    publisher: _medlinePlus,
    url: 'https://medlineplus.gov/ency/article/004014.htm',
  ),
  SkinSource(
    id: 'medline_aging_face',
    title: 'Aging changes in the face',
    publisher: _medlinePlus,
    url: 'https://medlineplus.gov/ency/article/004004.htm',
  ),
  SkinSource(
    id: 'medline_skin',
    title: 'Skin conditions',
    publisher: _medlinePlus,
    url: 'https://medlineplus.gov/skinconditions.html',
  ),
  SkinSource(
    id: 'who_uv',
    title: 'Radiation: ultraviolet (UV)',
    publisher: _who,
    url:
        'https://www.who.int/news-room/questions-and-answers/item/radiation-ultraviolet-(uv)',
  ),
];

final Map<String, SkinSource> _byId = {for (final s in skinSources) s.id: s};

SkinSource? sourceById(String? id) => id == null ? null : _byId[id];

/// Comma-joined ids as stored on a recommendation block, resolved in order and
/// with unknown ids dropped — a persisted result from an older build may name
/// a source this build no longer ships.
List<SkinSource> sourcesByIds(String? ids) {
  if (ids == null || ids.isEmpty) return const [];
  return ids
      .split(',')
      .map((e) => e.trim())
      .map(sourceById)
      .nonNulls
      .toList(growable: false);
}
