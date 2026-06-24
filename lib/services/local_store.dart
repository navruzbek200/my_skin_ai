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

  // A day is "completed" if every task slot in [totalTasks] was marked done.
  Map<String, bool> getStreaks(int totalTasks) {
    final result = <String, bool>{};
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith(_routinePrefix));
      for (final key in keys) {
        final day = key.substring(_routinePrefix.length);
        final routine = getRoutine(day);
        final doneCount = routine.values.where((v) => v).length;
        result[day] = totalTasks > 0 && doneCount >= totalTasks;
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

  // ── Privacy consent ───────────────────────────────────────────

  bool get privacyAccepted => _prefs.getBool(_privacyKey) ?? false;

  Future<void> acceptPrivacy() async {
    try {
      await _prefs.setBool(_privacyKey, true);
    } catch (_) {}
  }

  // ── Auth state ────────────────────────────────────────────────

  static const _loginKey = 'is_logged_in_v1';

  bool get isLoggedIn => _prefs.getBool(_loginKey) ?? false;

  Future<void> setLoggedIn() async {
    try {
      await _prefs.setBool(_loginKey, true);
    } catch (_) {}
  }

  Future<void> setLoggedOut() async {
    try {
      await _prefs.setBool(_loginKey, false);
    } catch (_) {}
  }

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

  // ── Cloud analysis consent ────────────────────────────────────
  //
  // Separate from general privacy_accepted — this gates the camera→cloud path.

  static const _cloudConsentKey = 'cloud_analysis_consent_v1';

  bool get cloudAnalysisAccepted => _prefs.getBool(_cloudConsentKey) ?? false;

  Future<void> acceptCloudAnalysis() async {
    try {
      await _prefs.setBool(_cloudConsentKey, true);
    } catch (_) {}
  }
}
