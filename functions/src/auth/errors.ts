import { HttpsError, FunctionsErrorCode } from 'firebase-functions/v2/https';

/**
 * Stable error vocabulary shared with the Flutter client. The gRPC status code
 * carried by HttpsError is too coarse to map to a user-facing message, so the
 * precise code always travels in `details.code` — clients read that, not the
 * status.
 */
export type AuthErrorCode =
  | 'invalid-phone'
  | 'invalid-name'
  | 'invalid-code'
  | 'code-expired'
  | 'too-many-requests'
  | 'user-exists'
  | 'user-not-found'
  | 'wrong-password'
  | 'weak-password'
  | 'sms-failed'
  | 'invalid-email'
  | 'email-required'
  | 'email-failed';

const STATUS: Record<AuthErrorCode, FunctionsErrorCode> = {
  'invalid-phone': 'invalid-argument',
  'invalid-name': 'invalid-argument',
  'invalid-code': 'invalid-argument',
  'code-expired': 'deadline-exceeded',
  'too-many-requests': 'resource-exhausted',
  'user-exists': 'already-exists',
  'user-not-found': 'not-found',
  'wrong-password': 'permission-denied',
  'weak-password': 'invalid-argument',
  'sms-failed': 'unavailable',
  'invalid-email': 'invalid-argument',
  'email-required': 'failed-precondition',
  'email-failed': 'unavailable',
};

export function authError(code: AuthErrorCode): HttpsError {
  return new HttpsError(STATUS[code], code, { code });
}
