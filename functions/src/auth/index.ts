import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import { ESKIZ_EMAIL, ESKIZ_PASSWORD } from './eskizClient';
import { EMAIL_USER, EMAIL_PASS } from './emailClient';
import { authError } from './errors';
import { normalizePhone } from './phone';
import {
  issueAndSendEmailOtp,
  issueAndSendOtp,
  verifyAndConsumeEmailOtp,
  verifyAndConsumeRegisterOtp,
} from './otpService';
import {
  createUser,
  deleteUserAccount,
  getUserEmail,
  mintCustomToken,
  setUserEmail,
  updatePassword,
  userExists,
  verifyPassword,
} from './userService';

const REGION = 'europe-west1';
const smsOptions = { region: REGION, secrets: [ESKIZ_EMAIL, ESKIZ_PASSWORD], timeoutSeconds: 20 };
const emailOptions = { region: REGION, secrets: [EMAIL_USER, EMAIL_PASS], timeoutSeconds: 20 };
const plainOptions = { region: REGION, timeoutSeconds: 20 };

type Ok = { ok: true };
type Session = { token: string };

export const sendOtp = onCall(smsOptions, async (req: CallableRequest): Promise<Ok> => {
  const phone = normalizePhone(req.data?.phone);
  // Fail before spending an SMS on a signup that cannot succeed.
  if (await userExists(phone)) throw authError('user-exists');

  await issueAndSendOtp(phone);
  return { ok: true };
});

/**
 * Sends a password-reset code to the caller's recovery email. The first time
 * a phone+password account goes through this flow it has no email on file,
 * so the client must supply one (`email-required` if it doesn't); every call
 * after that reuses the email already stored on the profile.
 */
export const forgotPassword = onCall(emailOptions, async (req: CallableRequest): Promise<Ok> => {
  const phone = normalizePhone(req.data?.phone);
  if (!(await userExists(phone))) throw authError('user-not-found');

  let email = await getUserEmail(phone);
  if (!email) {
    const submitted = req.data?.email;
    if (typeof submitted !== 'string' || submitted.trim().length === 0) {
      throw authError('email-required');
    }
    email = await setUserEmail(phone, submitted.trim());
  }

  await issueAndSendEmailOtp(phone, email);
  return { ok: true };
});

export const register = onCall(plainOptions, async (req: CallableRequest): Promise<Session> => {
  const { name, code, password } = req.data ?? {};
  const phone = normalizePhone(req.data?.phone);

  // Checked before the code is consumed so a lost race returns `user-exists`
  // rather than burning the OTP and failing on the write.
  if (await userExists(phone)) throw authError('user-exists');

  await verifyAndConsumeRegisterOtp(phone, code);
  const uid = await createUser({ name, phone, password });

  return { token: await mintCustomToken(uid) };
});

export const login = onCall(plainOptions, async (req: CallableRequest): Promise<Session> => {
  const phone = normalizePhone(req.data?.phone);
  const uid = await verifyPassword(phone, req.data?.password);

  return { token: await mintCustomToken(uid) };
});

export const resetPassword = onCall(plainOptions, async (req: CallableRequest): Promise<Ok> => {
  const phone = normalizePhone(req.data?.phone);
  if (!(await userExists(phone))) throw authError('user-not-found');

  await verifyAndConsumeEmailOtp(phone, req.data?.code);
  await updatePassword(phone, req.data?.newPassword);

  return { ok: true };
});

/**
 * Deletes the caller's own account — Auth record and Firestore docs together.
 * Identity comes from the verified `request.auth.uid`, never from the payload,
 * so a caller can only ever delete themselves. Recent-login is enforced on the
 * client (it re-authenticates before calling); here we only require a valid,
 * signed-in token.
 */
export const deleteAccount = onCall(plainOptions, async (req: CallableRequest): Promise<Ok> => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  await deleteUserAccount(uid);
  return { ok: true };
});
