"""Generates lib/data/product_copy.g.dart from the translated CSV.

The catalogue lives in Firestore, and the app reads `subtitle_ru` /
`benefits_en` from there when they exist. But those columns only exist after
somebody runs `tools/seed_products.mjs --apply`, and until then a Russian
reader sees Uzbek benefit lines — free prose that no local vocabulary can
translate.

So the same translations are compiled into the app as well, keyed by the Uzbek
source string. The lookup order in `ProductRepository` is: the Firestore column
first (so a new product can be translated without a release), then this table,
then the marketing vocabulary, then the Uzbek text itself.

Regenerate after editing the CSV:  python3 tools/i18n/gen_dart.py
"""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CSV_PATH = ROOT / 'tools' / 'products.csv'
OUT = ROOT / 'lib' / 'data' / 'product_copy.g.dart'


def dart_string(value: str) -> str:
    escaped = value.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{escaped}'"


def main() -> int:
    rows = list(csv.DictReader(CSV_PATH.open(encoding='utf-8-sig')))
    entries: dict[str, tuple[str, str]] = {}

    for row in rows:
        uz = (row.get('subtitle') or '').strip()
        ru = (row.get('subtitle_ru') or '').strip()
        en = (row.get('subtitle_en') or '').strip()
        if uz and ru and en:
            entries[uz] = (ru, en)

        uz_list = [b.strip() for b in (row.get('benefits') or '').split('|') if b.strip()]
        ru_list = [b.strip() for b in (row.get('benefits_ru') or '').split('|') if b.strip()]
        en_list = [b.strip() for b in (row.get('benefits_en') or '').split('|') if b.strip()]
        if len(uz_list) == len(ru_list) == len(en_list):
            for u, r, e in zip(uz_list, ru_list, en_list):
                entries[u] = (r, e)

    lines = [
        '// GENERATED — do not edit by hand.',
        '// Source: tools/products.csv, via tools/i18n/gen_dart.py',
        '//',
        '// Catalogue copy in three languages, keyed by the Uzbek source string.',
        '//',
        "// The Firestore documents carry `subtitle_ru` / `benefits_en` columns too,",
        '// and those win when present — a product added after this release can be',
        '// translated without shipping a new build. This table is what makes the',
        '// catalogue read correctly *before* that upload happens, and offline.',
        '',
        "import 'package:real_beauty_ai/core/l10n/localized_text.dart';",
        '',
        'const Map<String, LocalizedText> productCopy = {',
    ]
    for uz, (ru, en) in entries.items():
        lines.append(f'  {dart_string(uz)}: LocalizedText(')
        lines.append(f'      {dart_string(uz)},')
        lines.append(f'      {dart_string(ru)},')
        lines.append(f'      {dart_string(en)}),')
    lines.append('};')
    lines.append('')

    OUT.write_text('\n'.join(lines), encoding='utf-8')
    print(f'{len(entries)} strings written to {OUT.relative_to(ROOT)}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
