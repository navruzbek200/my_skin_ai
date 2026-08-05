import { createHash, randomInt, timingSafeEqual } from 'crypto';
import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../firebase';
import { authError } from './errors';
import { sendSms } from './eskizClient';
import { sendEmail } from './emailClient';

const CODE_TTL_MS = 2 * 60 * 1000;
const RATE_WINDOW_MS = 10 * 60 * 1000;
const MAX_SENDS_PER_WINDOW = 3;
const MAX_VERIFY_ATTEMPTS = 5;

/**
 * Two independent code stores keyed by phone. `otps` is the SMS channel
 * (register); `emailOtps` is the email channel (password reset) — kept
 * separate so a reset code can never be replayed against register, and vice
 * versa, even for the same phone number.
 */
type OtpKind = 'otps' | 'emailOtps';

const otpDoc = (kind: OtpKind, phone: string) => db.doc(`${kind}/${phone}`);
const rateDoc = (kind: OtpKind, phone: string) => db.doc(`${kind}RateLimits/${phone}`);

/**
 * Salted with the phone so one rainbow table cannot cover every number, and
 * because the same six digits for two users must not collide.
 */
function hashCode(phone: string, code: string): string {
  return createHash('sha256').update(`${phone}:${code}`).digest('hex');
}

function hashesMatch(a: string, b: string): boolean {
  const left = Buffer.from(a, 'hex');
  const right = Buffer.from(b, 'hex');
  return left.length === right.length && timingSafeEqual(left, right);
}

/** Uniform over 000000-999999 — `Math.random()` is not acceptable for a credential. */
function generateCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

/**
 * Sliding window over the send timestamps of a single phone. Runs in a
 * transaction because a client hammering the endpoint would otherwise
 * read-modify-write past the limit concurrently.
 */
async function assertUnderSendLimit(kind: OtpKind, phone: string): Promise<void> {
  const ref = rateDoc(kind, phone);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const now = Date.now();
    const recent: number[] = ((snap.data()?.sentAt as number[] | undefined) ?? [])
      .filter((t) => now - t < RATE_WINDOW_MS);

    if (recent.length >= MAX_SENDS_PER_WINDOW) throw authError('too-many-requests');

    tx.set(ref, { sentAt: [...recent, now] });
  });
}

/**
 * Rate-limits, mints a code, stores only its hash, and hands the plaintext
 * code to [deliver]. The code exists solely as a local here and inside the
 * outgoing message — it is never returned, persisted, or logged.
 */
async function issueOtp(
  kind: OtpKind,
  phone: string,
  deliver: (code: string) => Promise<void>,
): Promise<void> {
  await assertUnderSendLimit(kind, phone);

  const code = generateCode();
  await otpDoc(kind, phone).set({
    hash: hashCode(phone, code),
    // Timestamp (not a number) so a Firestore TTL policy on this field can
    // garbage-collect used and abandoned codes.
    expiresAt: Timestamp.fromMillis(Date.now() + CODE_TTL_MS),
    attempts: 0,
  });

  await deliver(code);
}

export const issueAndSendOtp = (phone: string): Promise<void> =>
  issueOtp('otps', phone, (code) => sendSms(phone, `Real Beauty AI tasdiqlash kodi: ${code}`));

export const issueAndSendEmailOtp = (phone: string, email: string): Promise<void> =>
  issueOtp('emailOtps', phone, (code) =>
    sendEmail(
      email,
      'Real Beauty AI — parolni tiklash',
      `Parolni tiklash kodi: ${code}\n\nKod 2 daqiqa amal qiladi. Agar bu so'rovni siz yubormagan bo'lsangiz, xabarni e'tiborsiz qoldiring.`,
    ),
  );

/**
 * Verifies [code] and deletes the OTP on success, so a single code can never
 * be replayed.
 */
async function verifyAndConsumeOtp(kind: OtpKind, phone: string, code: unknown): Promise<void> {
  if (typeof code !== 'string' || !/^\d{6}$/.test(code)) throw authError('invalid-code');

  const ref = otpDoc(kind, phone);
  const snap = await ref.get();
  const data = snap.data();
  if (!data) throw authError('invalid-code');

  if ((data.expiresAt as Timestamp).toMillis() < Date.now()) {
    await ref.delete();
    throw authError('code-expired');
  }

  // Brute force over 10^6 codes is otherwise feasible inside the 2-minute window.
  if ((data.attempts as number) >= MAX_VERIFY_ATTEMPTS) {
    await ref.delete();
    throw authError('too-many-requests');
  }

  if (!hashesMatch(data.hash as string, hashCode(phone, code))) {
    await ref.update({ attempts: (data.attempts as number) + 1 });
    throw authError('invalid-code');
  }

  await ref.delete();
}

export const verifyAndConsumeRegisterOtp = (phone: string, code: unknown): Promise<void> =>
  verifyAndConsumeOtp('otps', phone, code);

export const verifyAndConsumeEmailOtp = (phone: string, code: unknown): Promise<void> =>
  verifyAndConsumeOtp('emailOtps', phone, code);
