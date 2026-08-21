"""Adds the translated columns to products.csv.

The catalogue is authored in Uzbek. The app reads `subtitle_ru`, `subtitle_en`,
`benefits_ru` and `benefits_en` when they exist and falls back to a local
vocabulary when they do not — so filling them here is what makes the product
pages read in the language the app is set to, rather than the language the
catalogue happened to be typed in.

Benefits stay pipe-separated and in the same order as the Uzbek column: the
repository zips the lists together by index and treats a length mismatch as
absent, so a row must never gain or lose an entry in translation.

Run from the repo root:  python3 tools/i18n/apply.py
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from subtitles import SUBTITLES          # noqa: E402
from benefits_a import BENEFITS_A        # noqa: E402
from benefits_b import BENEFITS_B        # noqa: E402

BENEFITS = {**BENEFITS_A, **BENEFITS_B}
CSV = Path(__file__).resolve().parents[2] / 'tools' / 'products.csv'

NEW_COLUMNS = ['subtitle_ru', 'subtitle_en', 'benefits_ru', 'benefits_en']


def main() -> int:
    rows = list(csv.DictReader(CSV.open(encoding='utf-8')))
    if not rows:
        print('products.csv is empty'); return 1

    missing = []
    for row in rows:
        subtitle = row['subtitle'].strip()
        if subtitle and subtitle not in SUBTITLES:
            missing.append(f'subtitle: {subtitle}')
        for b in (b.strip() for b in row['benefits'].split('|')):
            if b and b not in BENEFITS:
                missing.append(f'benefit: {b}')
    if missing:
        # Refuse rather than write half a translation: a partly-filled column
        # is worse than none, because the app would then trust it.
        print(f'{len(missing)} untranslated strings — nothing written:')
        for m in dict.fromkeys(missing):
            print('  ', m)
        return 1

    for row in rows:
        subtitle = row['subtitle'].strip()
        ru, en = SUBTITLES.get(subtitle, ('', ''))
        row['subtitle_ru'], row['subtitle_en'] = ru, en

        parts = [b.strip() for b in row['benefits'].split('|') if b.strip()]
        row['benefits_ru'] = '|'.join(BENEFITS[b][0] for b in parts)
        row['benefits_en'] = '|'.join(BENEFITS[b][1] for b in parts)

    fieldnames = list(rows[0].keys())
    for col in NEW_COLUMNS:
        if col not in fieldnames:
            fieldnames.append(col)

    with CSV.open('w', encoding='utf-8', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f'{len(rows)} products translated into ru and en')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
