#!/usr/bin/env python3
"""Turn a folder of raw product photos plus tools/products.csv into the two
things the catalogue needs: optimised WebP files under public/products/ (served
by Firebase Hosting) and tools/products_seed.json (loaded into Firestore by
seed_products.mjs).

The app renders whatever URL Firestore hands it, so nothing here touches the UI
— only the bytes behind the same widgets change.

Usage:
    python3 tools/build_products.py                # build everything
    python3 tools/build_products.py --check        # validate the CSV only
"""

import argparse
import csv
import json
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow kerak:  python3 -m pip install --user Pillow")

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / "tools" / "products.csv"
RAW_DIR = ROOT / "tools" / "raw_images"
OUT_DIR = ROOT / "public" / "products"
SEED_PATH = ROOT / "tools" / "products_seed.json"

# Matches the filter chips in products_page.dart. A category outside this set
# would leave the product unreachable behind every chip, so it is an error
# rather than a warning.
CATEGORIES = {"SPF", "Tozalovchi", "Niqob", "Peeling", "Remover"}

# The detail view fills the screen minus 32dp of padding. On a 3.5x-density
# phone that is ~1330 physical pixels, and 4x phones exist — so anything under
# ~1400 gets upscaled and looks soft. Images are never enlarged past their own
# source: upscaling adds bytes and no detail.
MAX_WIDTH = 1400

# 92 is where WebP stops showing artefacts on the fine print that product
# packaging is covered in. 80 visibly softens it, and above 92 the file grows
# much faster than the picture improves.
QUALITY = 92

# Below this the source itself is the limit on sharpness, so warn rather than
# silently ship a soft picture.
MIN_GOOD_WIDTH = 1200

REQUIRED = ["id", "image", "brand", "name", "subtitle", "price", "category"]


def read_rows() -> list[dict]:
    if not CSV_PATH.exists():
        sys.exit(f"CSV topilmadi: {CSV_PATH}")
    with CSV_PATH.open(encoding="utf-8-sig", newline="") as fh:
        rows = [r for r in csv.DictReader(fh) if any((v or "").strip() for v in r.values())]
    if not rows:
        sys.exit("CSV bo'sh")
    return rows


def validate(rows: list[dict]) -> list[str]:
    problems: list[str] = []
    seen_ids: set[str] = set()

    for i, row in enumerate(rows, start=2):  # +1 header, +1 to 1-index
        for col in REQUIRED:
            if not (row.get(col) or "").strip():
                problems.append(f"{i}-qator: '{col}' bo'sh")

        pid = (row.get("id") or "").strip()
        if pid in seen_ids:
            problems.append(f"{i}-qator: id '{pid}' takrorlangan")
        seen_ids.add(pid)

        cat = (row.get("category") or "").strip()
        if cat and cat not in CATEGORIES:
            problems.append(
                f"{i}-qator: kategoriya '{cat}' noma'lum — "
                f"ruxsat etilgan: {', '.join(sorted(CATEGORIES))}"
            )

        img = (row.get("image") or "").strip()
        if img and not (RAW_DIR / img).exists():
            problems.append(f"{i}-qator: rasm topilmadi — tools/raw_images/{img}")

    return problems


def convert(src: Path, dest: Path) -> tuple[int, int, int, bool]:
    """Re-encode as WebP, capped at MAX_WIDTH and never enlarged.

    Returns (bytes before, bytes after, output width, source was too small).
    """
    before = src.stat().st_size
    with Image.open(src) as im:
        source_width = im.width
        # Flatten transparency onto white: cards sit on white, and keeping an
        # alpha channel roughly doubles the encoded size for no visible gain.
        if im.mode in ("RGBA", "LA", "P"):
            im = im.convert("RGBA")
            flat = Image.new("RGB", im.size, (255, 255, 255))
            flat.paste(im, mask=im.split()[-1])
            im = flat
        else:
            im = im.convert("RGB")

        if im.width > MAX_WIDTH:
            height = round(im.height * MAX_WIDTH / im.width)
            im = im.resize((MAX_WIDTH, height), Image.LANCZOS)

        dest.parent.mkdir(parents=True, exist_ok=True)
        im.save(dest, "WEBP", quality=QUALITY, method=6)
        out_width = im.width

    return before, dest.stat().st_size, out_width, source_width < MIN_GOOD_WIDTH


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="faqat CSV'ni tekshir")
    ap.add_argument(
        "--base-url",
        default="https://real-beauty-2b6b0.web.app",
        help="Hosting manzili (custom domen ulangach o'zgartir)",
    )
    args = ap.parse_args()

    rows = read_rows()
    problems = validate(rows)
    if problems:
        print(f"CSV'da {len(problems)} ta xato:\n", file=sys.stderr)
        for p in problems:
            print(f"  - {p}", file=sys.stderr)
        sys.exit(1)

    print(f"CSV toza — {len(rows)} ta mahsulot")
    if args.check:
        return

    seed = []
    total_before = total_after = 0
    soft: list[tuple[str, int]] = []

    for order, row in enumerate(rows):
        pid = row["id"].strip()
        src = RAW_DIR / row["image"].strip()
        dest = OUT_DIR / f"{pid}.webp"

        before, after, width, too_small = convert(src, dest)
        total_before += before
        total_after += after
        if too_small:
            soft.append((pid, width))

        benefits = [
            b.strip()
            for b in (row.get("benefits") or "").split("|")
            if b.strip()
        ]

        seed.append(
            {
                "id": pid,
                "imageUrl": f"{args.base_url}/products/{pid}.webp",
                # Kept so an old build that predates this catalogue still finds
                # a bundled picture instead of an empty card.
                "imagePath": (row.get("assetFallback") or "").strip(),
                "brand": row["brand"].strip(),
                "name": row["name"].strip(),
                "subtitle": row["subtitle"].strip(),
                "price": row["price"].strip(),
                "category": row["category"].strip(),
                "benefits": benefits,
                "order": order,
            }
        )

        flag = "  ← manba kichik" if too_small else ""
        print(
            f"  {pid:<14} {before // 1024:>5} KB → {after // 1024:>4} KB"
            f"  {width}px{flag}"
        )

    SEED_PATH.write_text(
        json.dumps(seed, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print()
    print(f"Rasmlar : {OUT_DIR.relative_to(ROOT)}  ({len(seed)} ta)")
    print(f"Hajm    : {total_before // 1024} KB → {total_after // 1024} KB")
    print(f"Seed    : {SEED_PATH.relative_to(ROOT)}")

    if soft:
        print()
        print(
            f"DIQQAT — {len(soft)} ta rasmning manbasi {MIN_GOOD_WIDTH}px dan tor. "
            "Skript ularni kattalashtirmaydi (kattalashtirish tiniqlik qo'shmaydi, "
            "faqat xiralashtiradi). Yuqori aniqlikdagi asl nusxa bo'lsa almashtir:"
        )
        for pid, width in soft:
            print(f"  - {pid}: {width}px")

    print()
    print("Keyingi qadam:")
    print("  firebase deploy --only hosting")
    print("  node tools/seed_products.mjs")


if __name__ == "__main__":
    main()
