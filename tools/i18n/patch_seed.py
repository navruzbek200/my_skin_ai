"""Merges the translated columns into products_seed.json.

Separate from `build_products.py` on purpose: that script also re-encodes every
product photograph, which takes minutes and changes nothing here. This only
touches the text, so a translation fix does not mean re-running the whole
image pipeline.

Run from the repo root:  python3 tools/i18n/patch_seed.py
"""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CSV_PATH = ROOT / 'tools' / 'products.csv'
SEED_PATH = ROOT / 'tools' / 'products_seed.json'


def pipe(value: str) -> list[str]:
    return [b.strip() for b in (value or '').split('|') if b.strip()]


def main() -> int:
    rows = {r['id'].strip(): r for r in csv.DictReader(CSV_PATH.open(encoding='utf-8-sig'))}
    seed = json.loads(SEED_PATH.read_text(encoding='utf-8'))

    patched = skipped = 0
    for entry in seed:
        row = rows.get(entry['id'])
        if row is None:
            skipped += 1
            continue

        for lang in ('ru', 'en'):
            subtitle = (row.get(f'subtitle_{lang}') or '').strip()
            if subtitle:
                entry[f'subtitle_{lang}'] = subtitle

            translated = pipe(row.get(f'benefits_{lang}'))
            # Only when it lines up entry for entry with the Uzbek list: the
            # app zips them by index, so a row that gained or lost a bullet in
            # translation would pair the wrong sentences together.
            if translated and len(translated) == len(entry.get('benefits', [])):
                entry[f'benefits_{lang}'] = translated
        patched += 1

    SEED_PATH.write_text(
        json.dumps(seed, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{patched} products patched'
          + (f', {skipped} not found in the CSV' if skipped else ''))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
