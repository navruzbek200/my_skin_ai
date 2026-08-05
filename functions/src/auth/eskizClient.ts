import axios from 'axios';
import FormData from 'form-data';
import { defineSecret, defineString } from 'firebase-functions/params';
import { db } from '../firebase';
import { authError } from './errors';
import { toEskizFormat } from './phone';

export const ESKIZ_EMAIL = defineSecret('ESKIZ_EMAIL');
export const ESKIZ_PASSWORD = defineSecret('ESKIZ_PASSWORD');

/** Sender id approved in the Eskiz cabinet; `4546` is their test sender. */
const ESKIZ_SENDER = defineString('ESKIZ_SENDER', { default: '4546' });

const BASE_URL = 'https://notify.eskiz.uz/api';
const TIMEOUT_MS = 10_000;

/**
 * Eskiz tokens live ~30 days, so logging in per invocation would be wasteful and
 * would rate-limit us. The token is cached in Firestore (shared by every
 * instance, survives cold starts) and mirrored in module scope (skips the read
 * on warm instances).
 */
const TOKEN_DOC = db.doc('system/eskizToken');

let cachedToken: string | null = null;

async function readStoredToken(): Promise<string | null> {
  const snap = await TOKEN_DOC.get();
  const token = snap.data()?.token;
  return typeof token === 'string' ? token : null;
}

async function login(): Promise<string> {
  const form = new FormData();
  form.append('email', ESKIZ_EMAIL.value());
  form.append('password', ESKIZ_PASSWORD.value());

  const response = await axios.post(`${BASE_URL}/auth/login`, form, {
    headers: form.getHeaders(),
    timeout: TIMEOUT_MS,
  });

  const token: unknown = response.data?.data?.token;
  if (typeof token !== 'string' || token.length === 0) {
    throw new Error('eskiz login returned no token');
  }

  cachedToken = token;
  await TOKEN_DOC.set({ token, updatedAt: Date.now() });
  return token;
}

async function getToken(): Promise<string> {
  if (cachedToken) return cachedToken;
  cachedToken = await readStoredToken();
  return cachedToken ?? login();
}

async function postSms(token: string, phone: string, message: string): Promise<void> {
  const form = new FormData();
  form.append('mobile_phone', toEskizFormat(phone));
  form.append('message', message);
  form.append('from', ESKIZ_SENDER.value());

  await axios.post(`${BASE_URL}/message/sms/send`, form, {
    headers: { ...form.getHeaders(), Authorization: `Bearer ${token}` },
    timeout: TIMEOUT_MS,
  });
}

function isUnauthorized(err: unknown): boolean {
  return (err as { response?: { status?: number } })?.response?.status === 401;
}

/**
 * Sends [message] to [phone], transparently re-logging in once if the cached
 * token has expired or been revoked.
 *
 * Never accepts the OTP itself — callers pass an already-rendered message so
 * this module has no reason to see or log a raw code.
 */
export async function sendSms(phone: string, message: string): Promise<void> {
  try {
    await postSms(await getToken(), phone, message);
  } catch (err: unknown) {
    if (!isUnauthorized(err)) {
      console.error('Eskiz send failed', {
        status: (err as { response?: { status?: number } })?.response?.status,
        message: (err as { message?: string })?.message,
      });
      throw authError('sms-failed');
    }

    cachedToken = null;
    try {
      await postSms(await login(), phone, message);
    } catch (retryErr: unknown) {
      console.error('Eskiz send failed after token refresh', {
        status: (retryErr as { response?: { status?: number } })?.response?.status,
      });
      throw authError('sms-failed');
    }
  }
}
