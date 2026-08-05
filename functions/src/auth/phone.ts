import { authError } from './errors';

/** Uzbek E.164: +998 followed by 9 digits. */
const UZ_PHONE = /^\+998\d{9}$/;

/**
 * Normalizes loose client input (spaces, dashes, parens, leading 998) to E.164
 * and rejects anything that is not an Uzbek mobile number. Returning a single
 * canonical form matters: the phone is the Firestore document id for OTPs and
 * the seed for the Firebase uid, so `+998 90 123 45 67` and `+998901234567`
 * must not become two different users.
 */
export function normalizePhone(input: unknown): string {
  if (typeof input !== 'string') throw authError('invalid-phone');

  let phone = input.replace(/[\s()-]/g, '');
  if (phone.startsWith('998')) phone = `+${phone}`;

  if (!UZ_PHONE.test(phone)) throw authError('invalid-phone');
  return phone;
}

/** Eskiz expects the number without the leading `+`. */
export function toEskizFormat(phone: string): string {
  return phone.slice(1);
}
