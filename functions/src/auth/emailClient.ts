import nodemailer from 'nodemailer';
import { defineSecret, defineString } from 'firebase-functions/params';
import { authError } from './errors';

export const EMAIL_USER = defineSecret('EMAIL_USER');
export const EMAIL_PASS = defineSecret('EMAIL_PASS');

/** SMTP host/port and the "from" address — not secret, so plain params. */
const EMAIL_SMTP_HOST = defineString('EMAIL_SMTP_HOST', { default: 'smtp.gmail.com' });
const EMAIL_SMTP_PORT = defineString('EMAIL_SMTP_PORT', { default: '465' });
const EMAIL_FROM = defineString('EMAIL_FROM', { default: 'Real Beauty AI' });

let cachedTransporter: nodemailer.Transporter | null = null;

/**
 * One transporter per warm instance, built lazily so `.value()` is only read
 * once secrets are actually available (cold start).
 */
function getTransporter(): nodemailer.Transporter {
  if (cachedTransporter) return cachedTransporter;

  cachedTransporter = nodemailer.createTransport({
    host: EMAIL_SMTP_HOST.value(),
    port: Number(EMAIL_SMTP_PORT.value()),
    secure: true,
    auth: { user: EMAIL_USER.value(), pass: EMAIL_PASS.value() },
  });
  return cachedTransporter;
}

/**
 * Sends [text] to [to]. Never accepts the OTP itself — callers pass an
 * already-rendered message so this module has no reason to see or log a raw
 * code, mirroring `eskizClient.sendSms`.
 */
export async function sendEmail(to: string, subject: string, text: string): Promise<void> {
  try {
    await getTransporter().sendMail({
      from: `"${EMAIL_FROM.value()}" <${EMAIL_USER.value()}>`,
      to,
      subject,
      text,
    });
  } catch (err: unknown) {
    console.error('Email send failed', { message: (err as { message?: string })?.message });
    throw authError('email-failed');
  }
}
