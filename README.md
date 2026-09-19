# Attendance app

Separate Flutter app. Auth UI/core follows **Al Faris user**. Backend: **Firebase** project `attendance-app-44578`.

Broader product plan: `docs/attendance-app-plan.md`.

## Firebase

Project: `attendance-app-44578`  
Android app: `1:1071993155969:android:f0447fe11525e4415d7880` (`com.example.attendance_app`)

Services:
- **Authentication** — Email/Password
- **Cloud Firestore** — `(default)` in `eur3` (user profiles in `users/{uid}`)
- **Hosting** — Flutter web

Config:
- `.env` / `lib/core/env/env.dart` — Envied keys
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firestore.rules` / `firestore.indexes.json`

After changing `.env`:

```sh
dart run build_runner build
```

Run:

```sh
flutter run
```

### Deploy backend

```sh
npx -y firebase-tools@latest deploy --only auth,firestore --project attendance-app-44578
```

### Hosting

```sh
flutter build web --release
npx -y firebase-tools@latest deploy --only hosting --project attendance-app-44578
```

Live: https://attendance-app-44578.web.app

## Localization / DI

```sh
dart run build_runner build
flutter analyze
flutter test
```
