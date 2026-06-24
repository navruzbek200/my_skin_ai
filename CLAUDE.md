# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Subagents (cavecrew)

Use cavecrew subagents to save main context and reduce token usage:

- `caveman:cavecrew-investigator` — locate code, find where X is defined, list usages. Use when search spans 3+ files.
- `caveman:cavecrew-builder` — 1-2 file edits only (typo fix, single function rewrite). Refuse if scope is larger.
- `caveman:cavecrew-reviewer` — review diffs, PRs, or specific files for bugs. One finding per line.

**When to use:**
- Code search across `lib/` → investigator
- Small focused fix (1-2 files) → builder
- Before committing changes → reviewer
- Large refactor or new feature → do inline (not builder)

## Language

- Conversation with user: Uzbek or English (user's choice).
- **All code, strings, comments, variable names, commit messages: English only.** No Uzbek text in source files — UI strings are the only exception (they are end-user-facing Uzbek content, not code).

## Communication style

If caveman mode is active (hook or user instruction sets it), ALL responses must use caveman mode — terse, no filler, no articles, fragments OK. This applies to every message in the session until "stop caveman" or "normal mode" is said. Caveman mode persists across turns; do not revert.

## Commands

```bash
flutter analyze                          # lint (zero issues expected)
flutter test                             # run all tests
flutter test test/widget_test.dart       # single test file
flutter run -d <device-id>              # run on device
flutter devices                          # list connected devices
adb devices                              # list ADB devices (wireless ADB used)
```

## Architecture

**Package name:** `real_beauty_ai` — Uzbek-language Korean-style skincare app targeting Android/iOS.

### State management
- **flutter_bloc (Cubit)** throughout.
- `AuthCubit` — app-level singleton registered in `lib/core/di/injection.dart` via `get_it`, provided at root in `app.dart`.
- Feature cubits (`CosmetologistsCubit`, `ProductsCubit`, `QuizCubit`) — page-level, created inline in `BlocProvider`. Do NOT register these in GetIt.

### Routing (`lib/core/router/app_router.dart`)
- `go_router` with a single `GoRouter` instance (`appRouter`).
- Auth guard in `redirect`: unauthenticated → `/auth`, authenticated-on-auth-path → `/home`.
- Routes that pass typed objects via `state.extra` (`/scan-instructions`, `/face-scan`, `/analysis`, `/results`, `/lesson-detail`, `/article-detail`, `/cosmetolog-detail`) are guarded in `redirect` — wrong/null `extra` redirects to `/home` instead of crashing.
- Never cast `state.extra` without a prior `is` check.

### Onboarding / quiz flow
`/quiz` → `/scan-instructions` → `/face-scan` → `/analysis` → `/results` → `/home`

Each route receives `List<dynamic> quizAnswers` via `state.extra`. The list index layout is defined in `lib/data/quiz_data.dart` and consumed by `SkinLogic.analyze()`.

### Skin analysis
`lib/logic/skin_logic.dart` — pure static class. `SkinLogic.analyze(answers)` maps quiz answers to a `SkinResult` (skin type + base recommendation + additional blocks). All text is Uzbek. No network calls.

### Local persistence (`lib/services/local_store.dart`)
- Singleton `LocalStore.instance`, initialized in `main()` before `runApp`.
- Backed by `SharedPreferences`. All reads are **synchronous** (prefs loaded at init). All writes are **async fire-and-forget** — callers must not await unless ordering matters.
- Stores: skin profile (`SkinResult` as JSON), auth flag, routine task completion per day, privacy consent.

### Data sources
- **Static data:** `lib/data/` — articles, lessons, products, quiz questions, yoga content. Repositories read from these lists directly.
- **Firestore:** only `CosmetologistRepository` fetches from `cosmetologists` collection; falls back to `_seed` list on error.
- **Firebase Auth:** email/password + Google Sign-In (google_sign_in v7, singleton `GoogleSignIn.instance`).

### Face scanner (`lib/features/skin_scan/presentation/pages/face_scan_page.dart`)
- Uses `camera` package + `google_mlkit_face_detection`.
- Android: YUV420 → NV21 conversion for ML Kit. iOS: BGRA8888 directly.
- Head-rotation tracking: 60 ring segments fill as user rotates head. Auto-completes when all segments done → pushes to `/analysis`.
- `_FaceState` enum: `waiting, tooDark, tracking, timedOut, done`. No manual capture button.

### Shell / navigation
`MainShell` (`lib/features/shell/main_shell.dart`) — `IndexedStack` with 5 tabs (Bugun, Mahsulot, Skan, Darslar, Ko'nikma). Tab 2 (Skan) opens `ScannerScreen`, which routes to `/scan-instructions`.

### Theme
- `AppColors` in `lib/core/theme/colors.dart` — primary `#7060AA`, background `#F0ECF8`, text `#2D2050`.
- Font: **Nunito** (Google Fonts) everywhere.
- `AppRadius` constants for consistent border radii.
- Two duplicate color files exist: `lib/core/colors.dart` (older, used by `main_shell.dart`) and `lib/core/theme/colors.dart` (canonical). Prefer the `theme/` version for new code.

### Duplicate/legacy note
`lib/core/colors.dart` and `lib/core/typography.dart` are older copies; the canonical versions are `lib/core/theme/colors.dart` and `lib/core/theme/typography.dart`.

## Project conventions

**Assets:** Any new asset must be declared in `pubspec.yaml` under `flutter.assets` before use — missing entry causes `FlutterError` at runtime.

**Firebase:** `firebase_options.dart` is auto-generated by FlutterFire CLI — never edit manually. Firestore is used only for the `cosmetologists` collection; all other content is static data in `lib/data/`.

**Google Sign-In v7:** `GoogleSignIn.instance.initialize()` is called once in `main()`. Never call it elsewhere.

**Wireless ADB:** Device connects via `adb connect 192.168.1.102:<port>`. Port changes each session — check device's Developer Options → Wireless debugging screen for current port. Pair first with `adb pair` if session expired.

**`flutter analyze` must pass with 0 issues before any commit.**

**Commit messages:** one line, short, imperative. No Claude/AI mention anywhere in commits — no `Co-Authored-By`, no `Generated by`, nothing.

## Testing

Use `mocktail` for mocking (`class MockFoo extends Mock implements Foo`). Never use `mockito`.

Write tests at the appropriate level:
- **Unit tests** (`test/`) — for logic classes (`SkinLogic`, `LocalStore`, cubits, repositories).
- **Widget tests** (`test/`) — for individual widgets and pages with mocked dependencies.
- **Integration tests** (`integration_test/`) — only when testing full user flows end-to-end (e.g. quiz → results flow).

Goal: every feature's core functionality must have a test that verifies it works and catches regressions.
