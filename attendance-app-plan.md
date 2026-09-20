b  # Attendance App: Courses, Events & Bootcamps

A Flutter app for tracking student attendance with **QR check-in that works offline**. Admin and student roles both live on mobile.

---

## 1. Goals

- Track attendance for **courses**, **events**, and **bootcamps** in one app.
- Admin/instructor works fully from a phone (no web dashboard required).
- QR check-in works with **no internet** and syncs when the connection returns.
- Resistant to cheating (screenshot sharing, fake QR codes, duplicate scans).

---

## 2. Roles & Features

### Admin / Instructor
- Create a **program** (course, event, or bootcamp) with title, dates, location.
- Add **sessions** (each day/lecture is one session).
- Enroll students: manual add, CSV import, or invite link/code.
- Start / close a session and scan students in.
- Manual check-in (fallback) and manual status edit (present / late / absent / excused).
- Live attendance list for the running session.
- Reports per session, per student, per program, with export to Excel/PDF.
- Announcements and push notifications.
- (Optional) Multiple admins/assistants per program.

### Student
- Join a program by invite code or link.
- View schedule and upcoming sessions.
- Show **personal QR code** (works offline).
- Attendance history and attendance percentage.
- Notifications and reminders (session starting, low attendance warning).

---

## 3. Attendance Methods

| Method | Who scans | Offline? | Best for |
|---|---|---|---|
| **A. Student QR, admin scans** (primary) | Admin | Yes, fully | Any group size, most reliable |
| **B. Rotating session QR, student scans** | Student | Yes, but confirmed only after sync | Self check-in, no admin at the door |
| **C. Manual check-in** (fallback) | Admin | Yes | Dead phone, no QR |
| **D. Extras** (optional) | n/a | Partly | Geofence, PIN code |

**Recommended:** ship **A + C** first. Add **B** later if you need self check-in.

---

## 4. Offline QR Design

### 4.1 Method A: signed student credential

**Enrollment (online):**

1. Student joins a program.
2. Server (Cloud Function) creates a credential and signs it with a private key (**Ed25519**):

```json
{ "v": 1, "sid": "student_123", "pid": "program_456", "iat": 1790000000, "exp": 1800000000 }
```

3. Token format: `base64url(payload).base64url(signature)`
4. Student app stores the token locally and renders it as a QR code. **No internet needed to display it.**

**Check-in (offline):**

1. Admin app ships with the server's **public key** (bundled, or fetched once and cached).
2. Admin scans the QR, splits the token, and verifies the signature locally.
3. Checks: signature valid, `exp` not passed, `pid` matches the running session's program, student is in the downloaded roster.
4. Saves the record locally (`synced = false`) and shows green/red feedback instantly.
5. When online, records upload automatically.

**Why it's safe:** a forged QR fails signature verification, and the private key never leaves the server.

### 4.2 Anti-screenshot hardening (optional, phase 2)

A signed QR could be screenshotted and shared. Mitigations:

- Add a **rotating code** (TOTP, 30s window) to the QR, derived from a per-student secret.
- The admin app downloads the session roster **with per-student secrets** while online (store in encrypted storage), so it can verify the rotating code offline.
- Simpler alternative: rely on the admin seeing the student's face/ID at check-in, plus the duplicate-scan block.

### 4.3 Method B: rotating session QR (student scans)

- Admin app generates a QR every 20-30 seconds: `HMAC(sessionSecret, floor(time / 30))`. This is a local calculation, so it works offline.
- Student app scans and stores a **pending** check-in: `{sessionId, code, scannedAt, deviceId}`.
- The student's phone **cannot verify** the code (the secret stays with admin/server). The server validates it on sync.
- Trade-off: students learn whether it was accepted only after they reconnect.

### 4.4 Sync rules

- **Idempotent writes:** one record per `(sessionId, studentId)`. Use a deterministic ID such as `${sessionId}_${studentId}`, so retries and double-syncs never duplicate.
- **First scan wins:** if two admins scan the same student, keep the earliest timestamp.
- **Clock tampering:** on sync, reject or flag scans whose timestamp falls outside the session window.
- **Retry with backoff** when connectivity returns (`connectivity_plus`).
- Show a **"pending sync" badge** so the admin knows what hasn't uploaded yet.

---

## 5. Architecture

**Flutter** with **Clean Architecture** and **Cubit/BLoC**.

```
lib/
├── core/
│   ├── di/                    # get_it / injectable
│   ├── network/               # connectivity, error mapping
│   ├── crypto/                # token verify, TOTP
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/ domain/ presentation/
│   ├── programs/              # courses, events, bootcamps
│   ├── sessions/
│   ├── enrollment/
│   ├── attendance/
│   │   ├── data/
│   │   │   ├── datasources/   # remote (Firestore), local (Drift/Firestore cache)
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/      # ScanStudentQr, ManualCheckIn, SyncPending
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── pages/         # scanner, live list, student QR
│   ├── reports/
│   └── notifications/
└── main.dart
```

Role-based routing after login: `admin` goes to the Admin shell, `student` goes to the Student shell.

---

## 6. Backend Options

### Option 1: Firebase (fastest to ship)

- **Auth:** email/phone (+ Google if wanted)
- **Firestore:** enable offline persistence (on by default on mobile)
- **Cloud Functions:** issue signed credentials, validate rotating codes, generate reports
- **FCM:** notifications
- Use **deterministic doc IDs** for attendance (`sessionId_studentId`), so offline writes queue automatically and can never duplicate.
- Use `metadata.hasPendingWrites` to show the "pending sync" badge.

### Option 2: Supabase (SQL)

- Better if you want heavy relational reports.
- You'll need your own local queue (**Drift**) for offline scans.

**Recommendation:** Firebase for v1.

---

## 7. Data Model

### Firestore layout

```
users/{uid}
  name, email, role: "admin" | "student", createdAt

programs/{programId}
  type: "course" | "event" | "bootcamp"
  title, description, location
  startDate, endDate
  ownerId, adminIds: []
  inviteCode

programs/{programId}/students/{studentId}
  name, joinedAt, status

programs/{programId}/sessions/{sessionId}
  title, startAt, endAt
  status: "scheduled" | "open" | "closed"
  lateAfterMinutes

programs/{programId}/sessions/{sessionId}/attendance/{sessionId_studentId}
  studentId, scannedAt, scannedBy
  method: "qr" | "manual" | "self"
  status: "present" | "late" | "absent" | "excused"
  deviceId, syncedAt
```

### Local (if using Drift)

```dart
class AttendanceRecords extends Table {
  TextColumn get id => text()();                 // sessionId_studentId
  TextColumn get sessionId => text()();
  TextColumn get studentId => text()();
  DateTimeColumn get scannedAt => dateTime()();
  TextColumn get method => text()();             // qr | manual | self
  TextColumn get status => text()();             // present | late
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 8. Key Code Sketches

### 8.1 Verify a student QR offline (Dart, `cryptography` package)

```dart
import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class TokenVerifier {
  TokenVerifier(this._publicKeyBytes);
  final List<int> _publicKeyBytes;
  final _algo = Ed25519();

  Future<Map<String, dynamic>?> verify(String token) async {
    final parts = token.split('.');
    if (parts.length != 2) return null;

    final payloadBytes = base64Url.decode(base64Url.normalize(parts[0]));
    final sigBytes = base64Url.decode(base64Url.normalize(parts[1]));

    final ok = await _algo.verify(
      payloadBytes,
      signature: Signature(
        sigBytes,
        publicKey: SimplePublicKey(_publicKeyBytes, type: KeyPairType.ed25519),
      ),
    );
    if (!ok) return null;

    final payload = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
    final exp = payload['exp'] as int;
    if (DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp) return null;
    return payload;
  }
}
```

### 8.2 Scan use case (domain layer)

```dart
class ScanStudentQr {
  ScanStudentQr(this._verifier, this._repo);
  final TokenVerifier _verifier;
  final AttendanceRepository _repo;

  Future<ScanResult> call({required String token, required Session session}) async {
    final payload = await _verifier.verify(token);
    if (payload == null) return ScanResult.invalid;
    if (payload['pid'] != session.programId) return ScanResult.wrongProgram;

    final studentId = payload['sid'] as String;
    if (!await _repo.isEnrolled(session.programId, studentId)) {
      return ScanResult.notEnrolled;
    }

    final id = '${session.id}_$studentId';
    if (await _repo.exists(id)) return ScanResult.alreadyScanned;

    final now = DateTime.now();
    final late = now.isAfter(session.startAt.add(Duration(minutes: session.lateAfterMinutes)));
    await _repo.save(AttendanceRecord(
      id: id,
      sessionId: session.id,
      studentId: studentId,
      scannedAt: now,
      method: 'qr',
      status: late ? 'late' : 'present',
    ));
    return late ? ScanResult.late : ScanResult.present;
  }
}
```

### 8.3 Issue a credential (Cloud Function, Node.js)

```js
const crypto = require("crypto");
const b64u = (b) => Buffer.from(b).toString("base64url");

function issueToken(studentId, programId, privateKeyPem) {
  const payload = JSON.stringify({
    v: 1,
    sid: studentId,
    pid: programId,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 180,
  });
  const sig = crypto.sign(null, Buffer.from(payload), privateKeyPem); // Ed25519
  return `${b64u(payload)}.${b64u(sig)}`;
}
```

Store the private key in **Secret Manager**, never in the app.

### 8.4 Firestore security rules (sketch)

```
match /programs/{pid}/sessions/{sid}/attendance/{aid} {
  allow read: if isProgramAdmin(pid)
              || (isSignedIn() && resource.data.studentId == request.auth.uid);
  allow create, update: if isProgramAdmin(pid);
  allow delete: if false;
}
```

---

## 9. Screens

**Shared:** Splash, Login/Register, Role redirect, Profile/Settings

**Admin**
1. Programs list
2. Create/Edit program
3. Program details (sessions, students, reports tabs)
4. Session details, **Scanner screen** (camera + live counter + last scanned student)
5. Live attendance list (search, manual edit)
6. Enroll students (add, CSV, invite)
7. Reports and export

**Student**
1. My programs
2. Program details and schedule
3. **My QR** (large, high brightness, works offline)
4. Attendance history and percentage
5. Notifications

---

## 10. Packages

| Purpose | Package |
|---|---|
| QR scan | `mobile_scanner` |
| QR generate | `qr_flutter` |
| State management | `flutter_bloc` |
| DI | `get_it`, `injectable` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging` |
| Crypto | `cryptography` |
| Secure storage | `flutter_secure_storage` |
| Connectivity | `connectivity_plus` |
| Local DB (if needed) | `drift` |
| Reports | `excel`, `pdf`, `printing`, `share_plus` |
| CSV import | `csv`, `file_picker` |
| Screen brightness | `screen_brightness` (for the student QR) |

---

## 11. Security Checklist

- [ ] Private signing key only on the server (Secret Manager)
- [ ] Public key bundled/cached in the admin app
- [ ] Credentials have an expiry and are revocable (refresh on re-enroll)
- [ ] One record per student per session (deterministic ID)
- [ ] Attendance writes restricted to program admins (security rules)
- [ ] Timestamps validated against the session window on sync
- [ ] Roster and any secrets stored encrypted on the admin device
- [ ] Rate limits on Cloud Functions

---

## 12. Roadmap

### Current slice (only this now)

**Auth + minimal core from Al Faris user** — no programs, sessions, QR, or reports yet.

**Source:** `D:\mdsoft project\al_faris_user`

**Backend note:** Al Faris login is **phone + REST (Dio)**. Attendance uses the same Al Faris auth **UI/core**, but credentials are **email + password** on **Firebase Auth** (not phone, not Dio).

#### Take from Al Faris (adapt into attendance `core/`)

| Area | Files / folders |
|---|---|
| Theme | `core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart`, `input_borders.dart` |
| Auth UI widgets | `core/common/widgets/custom_button.dart`, `custom_text_field.dart`, `pass_text_field.dart`, `custom_toast.dart`, `app_status_bar_overlay.dart`, `app_loading_dialog.dart`, `loading_dialog_bloc_listener.dart` |
| Validation | `core/config/validations/validations.dart` (email/password only; drop phone/OTP rules if unused) |
| Shared chrome | `features/shared/widgets/app_logo.dart` (if assets exist / are copied) |
| UI look of auth | Layout/patterns from `features/login` + `features/register` presentation widgets only |

#### Keep in attendance (already / Firebase)

- `features/auth` with Firebase: register, login, session restore, logout, `AuthUser`
- `core/config` Firebase options for the attendance project
- Light `get_it` DI for auth only
- **Localization like Al Faris:** `easy_localization` + `assets/localization/{ar-EG,en-US}.json` + `LocaleKeys` (email copy, not phone)

#### Do not take from Al Faris yet

- Dio / `core/api` / end points / interceptors
- Phone field, OTP, forget-password API, governorates/regions, location picker
- Full `injectable` graph, `auto_route` app router, FCM / notification helpers
- `UserHelper` token/secure-storage session (Firebase Auth owns the session)
- Cart, stores, orders, profile product features

**Done when:** user can register, sign in, stay signed in across restarts, and sign out with Al Faris–matching auth UI. Post-login screen is a placeholder until attendance features start.

### Later (full product — not this slice)

**Phase 1: MVP**
1. Roles (`admin` / `student`) and role redirect
2. Programs and sessions
3. Enrollment (manual + invite code)
4. Signed student QR + admin scanner (offline)
5. Manual check-in and edit
6. Basic attendance list

**Phase 2**
7. Reports and Excel/PDF export
8. Push notifications and reminders
9. CSV import
10. Late/absent rules and attendance percentage

**Phase 3**
11. Rotating QR (anti-screenshot)
12. Self check-in (Method B)
13. Geofencing / PIN
14. Multi-admin, multi-organization support
15. Analytics dashboard

---

## 13. Testing Checklist

- [ ] Scan works in airplane mode, then syncs on reconnect
- [ ] Same student scanned twice gives "already scanned"
- [ ] Expired or tampered QR is rejected
- [ ] QR from another program is rejected
- [ ] Two admins scan the same student offline, one record after sync
- [ ] Device clock changed gives flagged/rejected on sync
- [ ] 100+ students scanned in quick succession stays smooth
- [ ] App killed mid-scan, no data lost

---

## 14. Open Decisions

- Single organization or **multi-tenant** (multiple organizations using the same app)?
- Small groups (scan one by one) or large events (100+ people, need fast entry)?
- Do students need **instant confirmation** (Method A) or is self check-in with delayed confirmation (Method B) acceptable?
- Languages: Arabic/English with RTL support?

---

## 15. Design System & Education Color Palette

A clean and trustworthy palette designed for education apps.

### Brand Colors

| Role | Hex | Use |
|---|---|---|
| Primary | `#4F46E5` (indigo) | Buttons, app bar, active states |
| Primary dark | `#3730A3` | Pressed states, headers |
| Primary light | `#E0E7FF` | Chips, selected items, card highlights |
| Accent | `#06B6D4` (cyan) | Scan button, highlights, progress |

### Light Theme

| Role | Hex |
|---|---|
| Background | `#F8FAFC` |
| Surface (cards) | `#FFFFFF` |
| Text primary | `#0F172A` |
| Text secondary | `#64748B` |
| Border/divider | `#E2E8F0` |

### Dark Theme

| Role | Hex |
|---|---|
| Background | `#0B1020` |
| Surface (cards) | `#151B2E` |
| Text primary | `#E5E7EB` |
| Text secondary | `#94A3B8` |
| Primary (contrast) | `#818CF8` |

### Attendance Status Colors

| Status | Hex | Symbol / Icon |
|---|---|---|
| Present | `#16A34A` (green) | ✓ Present |
| Late | `#F59E0B` (amber) | ⏱ Late |
| Absent | `#DC2626` (red) | ✕ Absent |
| Excused | `#0284C7` (blue) | ℹ Excused |
| Pending sync / Offline | `#64748B` (slate) | ⟳ Pending |

### Scanner & Accessibility Rules

- **QR Display**: Always render the QR code black on white in both light and dark themes for optical scanner reliability.
- **Scanner Result Feedback**: Flash the full screen green (present), amber (late), or red (absent/invalid) for 1 second for instant door feedback without having to read text.
- **Color-Blind Accessibility**: Never rely on color alone; always pair status colors with distinctive symbols/icons and clear text labels.

