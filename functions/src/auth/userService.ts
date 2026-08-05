import bcrypt from 'bcryptjs';
import { FieldValue } from 'firebase-admin/firestore';
import { auth, db } from '../firebase';
import { authError } from './errors';

const BCRYPT_ROUNDS = 12;
const MIN_PASSWORD_LENGTH = 8;

/**
 * The phone is the identity, so the uid is derived from it rather than random:
 * the same number always resolves to the same account, with no lookup index to
 * keep in sync.
 */
const uidFor = (phone: string) => `phone:${phone}`;

/** Profile — readable by its owner and by admins. */
const profileDoc = (uid: string) => db.doc(`users/${uid}`);

/**
 * Password hash — kept out of `users/{uid}` so that the owner-read rule on the
 * profile can never hand a client its own bcrypt hash to attack offline. No
 * client rule matches this collection at all.
 */
const credentialDoc = (uid: string) => db.doc(`credentials/${uid}`);

function assertStrongPassword(password: unknown): asserts password is string {
  if (typeof password !== 'string' || password.length < MIN_PASSWORD_LENGTH) {
    throw authError('weak-password');
  }
}

function assertName(name: unknown): asserts name is string {
  if (typeof name !== 'string' || name.trim().length === 0) throw authError('invalid-name');
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function assertValidEmail(email: unknown): asserts email is string {
  if (typeof email !== 'string' || !EMAIL_RE.test(email)) throw authError('invalid-email');
}

export async function userExists(phone: string): Promise<boolean> {
  return (await profileDoc(uidFor(phone)).get()).exists;
}

export async function createUser(params: {
  name: unknown;
  phone: string;
  password: unknown;
}): Promise<string> {
  const { phone, password } = params;
  assertName(params.name);
  assertStrongPassword(password);

  const name = params.name.trim();
  const uid = uidFor(phone);
  if (await userExists(phone)) throw authError('user-exists');

  const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);

  // The Auth record may already exist from an interrupted signup — reuse it so
  // a retry cannot dead-end on `uid-already-exists`.
  await auth
    .createUser({ uid, phoneNumber: phone, displayName: name })
    .catch(async (err: { code?: string }) => {
      if (err.code !== 'auth/uid-already-exists') throw err;
      return auth.updateUser(uid, { phoneNumber: phone, displayName: name });
    });

  await Promise.all([
    profileDoc(uid).set({
      name,
      phone,
      provider: 'phone',
      createdAt: FieldValue.serverTimestamp(),
    }),
    credentialDoc(uid).set({ passwordHash, updatedAt: FieldValue.serverTimestamp() }),
  ]);

  return uid;
}

/** Returns the uid on success; throws `user-not-found` / `wrong-password` otherwise. */
export async function verifyPassword(phone: string, password: unknown): Promise<string> {
  const uid = uidFor(phone);
  const hash = (await credentialDoc(uid).get()).data()?.passwordHash;
  if (typeof hash !== 'string') throw authError('user-not-found');

  if (typeof password !== 'string' || !(await bcrypt.compare(password, hash))) {
    throw authError('wrong-password');
  }
  return uid;
}

export async function updatePassword(phone: string, newPassword: unknown): Promise<void> {
  assertStrongPassword(newPassword);

  const uid = uidFor(phone);
  if (!(await userExists(phone))) throw authError('user-not-found');

  await credentialDoc(uid).set({
    passwordHash: await bcrypt.hash(newPassword, BCRYPT_ROUNDS),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

export function mintCustomToken(uid: string): Promise<string> {
  return auth.createCustomToken(uid);
}

/**
 * Fully removes an account: the Auth record and both Firestore docs
 * (`users/{uid}` and, for phone accounts, `credentials/{uid}`).
 *
 * A client-only `currentUser.delete()` left the two Firestore docs behind, so
 * the profile still satisfied `userExists` — the number could then never be
 * re-registered (`user-exists`) and a stale credential lingered. This makes
 * deletion complete and idempotent: missing pieces are ignored so a partial
 * previous delete can always be finished.
 */
export async function deleteUserAccount(uid: string): Promise<void> {
  await Promise.all([
    profileDoc(uid).delete(),
    credentialDoc(uid).delete(),
    auth.deleteUser(uid).catch((err: { code?: string }) => {
      if (err.code !== 'auth/user-not-found') throw err;
    }),
  ]);
}

/** Recovery email on file for [phone], or `null` if none has been set yet. */
export async function getUserEmail(phone: string): Promise<string | null> {
  const email = (await profileDoc(uidFor(phone)).get()).data()?.email;
  return typeof email === 'string' ? email : null;
}

/**
 * Records [email] as the recovery address for [phone]'s account. Called the
 * first time a phone+password user goes through forgot-password without one
 * on file yet — from then on `forgotPassword` reuses it without asking again.
 */
export async function setUserEmail(phone: string, email: unknown): Promise<string> {
  assertValidEmail(email);
  await profileDoc(uidFor(phone)).set({ email }, { merge: true });
  return email;
}
