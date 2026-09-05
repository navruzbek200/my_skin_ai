import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin_analysis_result.dart';
import '../models/skin_result.dart';

// Single source of truth for all local persistence.
// All reads are synchronous (SharedPreferences is loaded in init()).
// All writes are async fire-and-forget; callers should not await unless ordering matters.
// Never throws — every method catches and swallows storage errors so the app never crashes
// due to corrupt or missing data.
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Routing keys ──────────────────────────────────────────────

  static const _skinKey = 'skin_profile_v1';
  static const _privacyKey = 'privacy_accepted_v1';
  static const _routinePrefix = 'routine:';
  static const _localeKey = 'locale_v1';
  static const _hasAccountKey = 'has_account_v1';
  static const _gatedSignupsKey = 'gated_signups_v1';

  // ── Date helpers ──────────────────────────────────────────────

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Routine tasks ─────────────────────────────────────────────
  //
  // Tasks are stored per day: key = 'routine:yyyy-MM-dd', value = JSON map of
  // task-key → bool.  Writing happens on each toggle, not on rebuild.

  Map<String, bool> getRoutine(String day) {
    try {
      final raw = _prefs.getString('$_routinePrefix$day');
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }

  Future<void> setTaskDone(String day, String taskKey, bool done) async {
    try {
      final current = getRoutine(day);
      current[taskKey] = done;
      await _prefs.setString('$_routinePrefix$day', jsonEncode(current));
    } catch (_) {}
  }

  // ── History: derive streaks and progress from stored routine data ──────────

  // A day counts as a streak if ≥70% of tasks are done.
  static bool isStreakDay(int done, int total) =>
      total > 0 && done >= (total * 0.7).ceil();

  Map<String, bool> getStreaks(int totalTasks) {
    final result = <String, bool>{};
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith(_routinePrefix));
      for (final key in keys) {
        final day = key.substring(_routinePrefix.length);
        final routine = getRoutine(day);
        final doneCount = routine.values.where((v) => v).length;
        result[day] = LocalStore.isStreakDay(doneCount, totalTasks);
      }
    } catch (_) {}
    return result;
  }

  Map<String, double> getDailyProgress(int totalTasks) {
    final result = <String, double>{};
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith(_routinePrefix));
      for (final key in keys) {
        final day = key.substring(_routinePrefix.length);
        final routine = getRoutine(day);
        final doneCount = routine.values.where((v) => v).length;
        result[day] = totalTasks > 0 ? (doneCount / totalTasks).clamp(0.0, 1.0) : 0.0;
      }
    } catch (_) {}
    return result;
  }

  // ── Skin profile ──────────────────────────────────────────────
  //
  // Answers and derived profile are stored locally only, never transmitted.

  bool get hasSkinProfile => _prefs.containsKey(_skinKey);

  SkinResult? getSkinProfile() {
    try {
      return SkinResult.tryParse(_prefs.getString(_skinKey));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSkinProfile(SkinResult result) async {
    try {
      await _prefs.setString(_skinKey, result.toJsonString());
    } catch (_) {}
  }

  Future<void> clearSkinProfile() async {
    try {
      await _prefs.remove(_skinKey);
    } catch (_) {}
  }

  // ── Account deletion ──────────────────────────────────────────
  //
  // Wipes everything tied to the person, not just the skin profile: scan
  // history and per-day routine progress are personal data too, and the phone
  // may be handed to someone else who signs up next. Deliberately *not* called
  // on logout — that data lives only on the device, so clearing it there would
  // destroy the history of someone who is coming right back.
  //
  // Privacy consent is left alone: it is a device-level acknowledgement, not
  // account data.

  Future<void> clearAllUserData() async {
    try {
      final keys = _prefs
          .getKeys()
          .where((k) =>
              k == _skinKey ||
              k == _historyKey ||
              k.startsWith(_routinePrefix))
          .toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (_) {}
  }

  // ── Language ──────────────────────────────────────────────────
  //
  // Null until somebody picks a language, which is what lets the first run
  // follow the phone's own language instead of overriding it with a default.

  String? get localeCode {
    try {
      return _prefs.getString(_localeKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocaleCode(String code) async {
    try {
      await _prefs.setString(_localeKey, code);
    } catch (_) {}
  }

  // ── Returning user ────────────────────────────────────────────
  //
  // Whether anyone has ever signed in on this device. Only a flag: it changes
  // the sign-in copy from "welcome" to "welcome back" and nothing else. The
  // address itself is deliberately not kept — on a shared phone an email left
  // in a prefilled field is somebody's identity on display, and Firebase
  // restores the real session by itself anyway.

  bool get hasAccount {
    try {
      return _prefs.getBool(_hasAccountKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markHasAccount() async {
    try {
      await _prefs.setBool(_hasAccountKey, true);
    } catch (_) {}
  }

  Future<void> clearHasAccount() async {
    try {
      await _prefs.remove(_hasAccountKey);
    } catch (_) {}
  }

  // ── Apple user identifier ─────────────────────────────────────
  //
  // Apple's stable per-app user id, kept so the app can ask iOS whether the
  // person has since revoked us in Settings → Apple ID → Sign in with Apple.
  // That check needs the identifier, and Firebase does not expose it: the uid
  // it issues is its own, and `providerData` carries Apple's only as an opaque
  // `uid` we would be guessing at. Storing it is also the only way to notice a
  // revocation at all — Apple pushes nothing to the device.
  //
  // Not a secret: it is an opaque id that identifies nobody outside this app,
  // which is why plain preferences are enough.

  static const _appleUserIdKey = 'apple_user_id_v1';

  String? get appleUserId {
    try {
      return _prefs.getString(_appleUserIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setAppleUserId(String id) async {
    try {
      await _prefs.setString(_appleUserIdKey, id);
    } catch (_) {}
  }

  Future<void> clearAppleUserId() async {
    try {
      await _prefs.remove(_appleUserIdKey);
    } catch (_) {}
  }

  // ── Sign-ups that must confirm their address ──────────────────
  //
  // The verification gate grandfathers in accounts created before a cut-off
  // date, because those were made when no verification step existed and some
  // of them hold addresses their owner can no longer read. That date has to
  // sit a week ahead of the build so a staged rollout cannot catch an
  // old-build sign-up and gate it mid-flight — which leaves a window where a
  // brand-new sign-up on *this* build is not gated either.
  //
  // This closes that window exactly. When this build creates an account it
  // records the uid, and the gate treats those as required-to-confirm
  // regardless of the date. It is per-uid rather than a device-level flag on
  // purpose: signing out and into an older, grandfathered account on the same
  // phone must not drag that account into the gate.

  Set<String> get gatedSignups {
    try {
      return (_prefs.getStringList(_gatedSignupsKey) ?? const []).toSet();
    } catch (_) {
      return const {};
    }
  }

  bool isGatedSignup(String uid) => gatedSignups.contains(uid);

  Future<void> markGatedSignup(String uid) async {
    try {
      final all = gatedSignups.toList();
      if (all.contains(uid)) return;
      all.add(uid);
      // Capped: this only ever grows by one per sign-up on this device, but a
      // shared phone should not accumulate a list without end.
      if (all.length > 20) all.removeRange(0, all.length - 20);
      await _prefs.setStringList(_gatedSignupsKey, all);
    } catch (_) {}
  }

  /// Dropped once the address is confirmed — the account has passed the gate
  /// and never needs to be looked up again.
  Future<void> clearGatedSignup(String uid) async {
    try {
      final all = gatedSignups.toList()..remove(uid);
      await _prefs.setStringList(_gatedSignupsKey, all);
    } catch (_) {}
  }

  // ── Privacy consent ───────────────────────────────────────────

  bool get privacyAccepted => _prefs.getBool(_privacyKey) ?? false;

  Future<void> acceptPrivacy() async {
    try {
      await _prefs.setBool(_privacyKey, true);
    } catch (_) {}
  }

  // Nothing here mirrors the session any more. There used to be an
  // `is_logged_in_v1` flag written on every sign-in and sign-out, and a
  // `needs_name_prompt_v1` left over from phone sign-up; neither was ever
  // read back — the router, the splash and the guards all read AuthBloc,
  // which mirrors `authStateChanges()`. Two sources of truth for "is someone
  // signed in" is one too many, and the one that could go was the one that
  // nobody consulted. Old installs keep the orphaned keys; they are ignored.

  // ── Scan history ──────────────────────────────────────────────
  //
  // Stores only scores + metadata — no images ever touch this store.
  // Newest entry at index 0. Capped at _historyMax to avoid unbounded growth.

  static const _historyKey = 'scan_history_v1';
  static const _historyMax = 20;

  Future<void> saveAnalysisToHistory(SkinAnalysisResult result) async {
    try {
      final history = getAnalysisHistory();
      history.insert(0, result);
      if (history.length > _historyMax) history.length = _historyMax;
      await _prefs.setString(
        _historyKey,
        jsonEncode(history.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  List<SkinAnalysisResult> getAnalysisHistory() {
    try {
      final raw = _prefs.getString(_historyKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SkinAnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

}
