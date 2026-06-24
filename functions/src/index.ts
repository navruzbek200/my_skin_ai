import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import axios from 'axios';
import FormData from 'form-data';

const FACEPP_API_KEY = defineSecret('FACEPP_API_KEY');
const FACEPP_API_SECRET = defineSecret('FACEPP_API_SECRET');

const FACEPP_URL = 'https://api-us.faceplusplus.com/facepp/v1/skinanalyze';
const TIMEOUT_MS = 15_000;

const SKIN_TYPE_LABELS: Record<number, string> = {
  0: 'oily',
  1: 'dry',
  2: 'normal',
  3: 'combination',
};

// Stable contract between Cloud Function and Flutter client.
// Face++ schema changes must not leak past this boundary.
interface SkinContract {
  ok: boolean;
  skinType?: string;
  overallScore?: number;
  concerns?: {
    acne: number;
    darkSpots: number;
    pores: number;
    wrinkles: number;
    darkCircles: number;
    eyeBags: number;
    blackheads: number;
    oiliness: number;
    // TODO: redness — compute from face bbox using CIELAB a* channel (sharp/jimp).
    //       Face++ does not provide a redness score directly.
  };
  reason?: string;
}

function clamp(v: number): number {
  return Math.max(0, Math.min(100, Math.round(v)));
}

function safeAvg(...values: (number | undefined | null)[]): number {
  const valid = values.filter((v): v is number => typeof v === 'number' && isFinite(v));
  if (valid.length === 0) return 0;
  return valid.reduce((a, b) => a + b, 0) / valid.length;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function normalizeConcerns(result: any) {
  const oilyDetail = (result.skin_type?.details as { value: number; confidence: number }[] | undefined)
    ?.find((d) => d.value === 0);
  const oiliness = clamp((oilyDetail?.confidence ?? 0) * 100);

  const wrinkles = clamp(safeAvg(
    result.forehead_wrinkle?.value,
    result.nasolabial_fold?.value,
    result.crows_feet?.value,
  ));

  // eye_pouch is the combined score; fall back to left/right average if absent
  const eyeBags = clamp(
    result.eye_pouch?.value ??
    safeAvg(result.left_eye_pouch?.value, result.right_eye_pouch?.value),
  );

  return {
    acne: clamp(result.acne?.value ?? 0),
    darkSpots: clamp(result.skin_spot?.value ?? 0),
    pores: clamp(result.pore?.value ?? 0),
    wrinkles,
    darkCircles: clamp(result.dark_circle?.value ?? 0),
    eyeBags,
    blackheads: clamp(result.blackhead?.value ?? 0),
    oiliness,
  };
}

export const analyzeSkin = onCall(
  {
    region: 'europe-west1',
    secrets: [FACEPP_API_KEY, FACEPP_API_SECRET],
    timeoutSeconds: 20,
  },
  async (request): Promise<SkinContract> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Login required');
    }

    const imageBase64: unknown = request.data?.imageBase64;
    if (typeof imageBase64 !== 'string' || imageBase64.length === 0) {
      throw new HttpsError('invalid-argument', 'imageBase64 is required');
    }

    // Strip data URI prefix if client accidentally included it
    const base64Clean = imageBase64.replace(/^data:[^;]+;base64,/, '');

    const form = new FormData();
    form.append('api_key', FACEPP_API_KEY.value());
    form.append('api_secret', FACEPP_API_SECRET.value());
    form.append('image_base64', base64Clean);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let faceppData: any;
    try {
      const response = await axios.post(FACEPP_URL, form, {
        headers: form.getHeaders(),
        timeout: TIMEOUT_MS,
      });
      faceppData = response.data;
    } catch (err: unknown) {
      const axiosErr = err as { response?: { status?: number; data?: { error_message?: string } }; message?: string };
      const errMsg = axiosErr?.response?.data?.error_message ?? axiosErr?.message ?? 'network_error';
      console.error('Face++ request failed', { status: axiosErr?.response?.status, errMsg });
      return { ok: false, reason: `facepp_request_failed: ${errMsg}` };
    }

    if (faceppData?.error_message) {
      console.error('Face++ API error', faceppData.error_message);
      return { ok: false, reason: `facepp_api_error: ${faceppData.error_message}` };
    }

    const result = faceppData?.result;
    if (!result) {
      return { ok: false, reason: 'no_result_in_response' };
    }

    const skinTypeCode: number = result.skin_type?.skin_type ?? 2;
    const skinType = SKIN_TYPE_LABELS[skinTypeCode] ?? 'normal';

    const concerns = normalizeConcerns(result);
    // Overall skin health score: higher = fewer concerns
    const overallScore = clamp(100 - safeAvg(...Object.values(concerns)));

    return {
      ok: true,
      skinType,
      overallScore,
      concerns,
    };
  },
);
