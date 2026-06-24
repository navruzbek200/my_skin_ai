# My Skin AI

Uzbek-language Korean-style skincare app for Android and iOS. Analyzes skin type via face scan and quiz, generates personalized daily routines, and connects users with cosmetologists.

## Features

- **Skin analysis** — face scan (ML Kit) + quiz → skin type, concerns, personalized routine
- **Daily routine** — auto-generated AM/PM steps based on skin profile, updates each day
- **Products** — Korean skincare catalog with skin-type filtering
- **Lessons & articles** — educational content with video steps
- **Cosmetologists** — directory with Firestore-backed profiles
- **Wellness** — yoga video section
- **Auth** — email/password and Google Sign-In via Firebase

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.44+ / Dart 3.12+ |
| State management | flutter_bloc (Cubit) |
| Routing | go_router |
| Auth | Firebase Auth + google_sign_in v7 |
| Database | Firestore (cosmetologists), static data (everything else) |
| Local storage | SharedPreferences via `LocalStore` singleton |
| Camera | `camera` package + `google_mlkit_face_detection` |
| Cloud functions | `cloud_functions` (optional AI skin analysis) |
| DI | get_it |

## Project Structure

```
lib/
├── core/
│   ├── di/injection.dart          # GetIt singletons (AuthCubit)
│   ├── router/app_router.dart     # go_router + auth redirect guards
│   ├── theme/                     # AppColors, Typography
│   └── permissions/               # CameraPermissionService
├── data/                          # Static data: articles, lessons, products, quiz
├── features/
│   ├── auth/                      # Firebase email + Google Sign-In
│   ├── home/                      # Bugun (Today) page + routine display
│   ├── skin_scan/                 # Face scan page (camera + ML Kit)
│   ├── onboarding/                # Quiz → Analysis → Results flow
│   ├── products/                  # Product catalog + filtering
│   ├── lessons/                   # Lessons, articles, yoga
│   ├── cosmetologists/            # Cosmetologist directory (Firestore)
│   ├── routine/                   # RoutineEngine: generates daily steps
│   ├── skin_analysis/             # Cloud AI analysis (optional)
│   ├── scanner/                   # Scanner tab entry point
│   ├── shell/                     # MainShell: IndexedStack 5-tab navigation
│   └── account/                   # Profile, logout, delete account
├── logic/skin_logic.dart          # SkinLogic.analyze(): quiz → SkinResult
├── models/                        # Data models
├── services/local_store.dart      # SharedPreferences wrapper (sync reads)
└── widgets/                       # Shared widgets
```

## Getting Started

### Prerequisites

- Flutter 3.44+
- Android SDK (minSdk 24, targetSdk 36)
- Firebase project with Auth and Firestore enabled
- `google-services.json` in `android/app/`
- `GoogleService-Info.plist` in `ios/Runner/`

### Setup

```bash
# Install dependencies
flutter pub get

# Run on device
flutter run -d <device-id>

# List connected devices
flutter devices
adb devices
```

### Wireless ADB

```bash
adb pair 192.168.1.102:<pair-port>   # pair (port from Developer Options)
adb connect 192.168.1.102:<port>     # connect (port changes each session)
```

### Firebase

Firebase config is auto-generated via FlutterFire CLI — never edit `firebase_options.dart` manually:

```bash
flutterfire configure
```

## Skin Analysis Flow

```
/quiz → /scan-instructions → /face-scan → /analysis → /results → /home
```

Each route receives `List<dynamic> quizAnswers` (quiz) or `AnalysisArgs` (analysis) via `state.extra`. Router guards redirect to `/home` on wrong/null extra.

**Face scan states:** `waiting → tooFar → tooClose → offCenter → notFrontal → eyesClosed → tooDark → ready → countdown → done → timedOut`

Auto-captures when face is stable for 1.2s + 1s countdown. Falls back to quiz-only analysis if camera unavailable or user declines.

## Architecture Notes

**State management**
- `AuthCubit` — app-level singleton in GetIt, provided at root in `app.dart`
- Feature cubits (`ProductsCubit`, `CosmetologistsCubit`, `QuizCubit`) — page-level, created inline in `BlocProvider`

**LocalStore**
- Singleton initialized in `main()` before `runApp`
- All reads synchronous (prefs loaded at init)
- Writes are async fire-and-forget

**Camera (Android)**
- YUV420 → NV21 manual conversion for ML Kit
- Fast detector for live guidance, accurate detector for final validation
- Lifecycle-aware: camera paused on `inactive`/`paused`, resumed on `resumed`

## Commands

```bash
flutter analyze          # lint (zero issues expected before commit)
flutter test             # run all tests
flutter build apk        # build release APK
flutter build appbundle  # build AAB for Play Store
```

## Testing

Uses `mocktail` for mocking. Never use `mockito`.

```bash
flutter test                              # all tests
flutter test test/widget_test.dart        # single file
```

## Release Signing

Create `android/key.properties`:

```properties
storeFile=/path/to/upload-keystore.jks
storePassword=your-password
keyAlias=upload
keyPassword=your-password
```

Generate keystore:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> `key.properties` and `*.jks` are gitignored — never commit them.
