// Writes tools/products_seed.json into the Firestore `products` collection.
//
// Security rules deny all client writes, so this runs through the Admin SDK
// with a service-account key — download one from
// Console → Project settings → Service accounts → Generate new private key
// and point GOOGLE_APPLICATION_CREDENTIALS at it. The key file is a full
// project credential: keep it out of git (tools/*.json is gitignored).
//
//   export GOOGLE_APPLICATION_CREDENTIALS=~/rb-service-account.json
//   node tools/seed_products.mjs            # dry run — prints the plan
//   node tools/seed_products.mjs --apply    # actually write

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const HERE = dirname(fileURLToPath(import.meta.url));
const SEED = join(HERE, 'products_seed.json');
const PROJECT_ID = 'real-beauty-2b6b0';

const apply = process.argv.includes('--apply');

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('GOOGLE_APPLICATION_CREDENTIALS o\'rnatilmagan.');
  console.error('export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json');
  process.exit(1);
}

const products = JSON.parse(readFileSync(SEED, 'utf8'));
if (!Array.isArray(products) || products.length === 0) {
  console.error('products_seed.json bo\'sh — avval build_products.py ni ishlat');
  process.exit(1);
}

initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
const db = getFirestore();
const col = db.collection('products');

const existing = await col.get();
const incomingIds = new Set(products.map((p) => p.id));
// Anything already in Firestore that the CSV no longer lists — the catalogue
// is the source of truth, so these are stale and get removed.
const stale = existing.docs.filter((d) => !incomingIds.has(d.id)).map((d) => d.id);

console.log(`Firestore'da hozir : ${existing.size} ta`);
console.log(`CSV'dan keladi     : ${products.length} ta`);
console.log(`O'chiriladi        : ${stale.length} ta${stale.length ? ' — ' + stale.join(', ') : ''}`);

if (!apply) {
  console.log('\nDRY RUN — hech narsa yozilmadi. Yozish uchun: node tools/seed_products.mjs --apply');
  process.exit(0);
}

// One batch: 60 products is far under the 500-write limit, and an all-or-
// nothing write means the app never sees a half-migrated catalogue.
const batch = db.batch();
for (const { id, ...data } of products) {
  batch.set(col.doc(id), data);
}
for (const id of stale) {
  batch.delete(col.doc(id));
}
await batch.commit();

console.log(`\nYozildi: ${products.length} ta mahsulot, o'chirildi: ${stale.length} ta`);
