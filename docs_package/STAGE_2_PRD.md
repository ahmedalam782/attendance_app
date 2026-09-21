# STAGE 2 — Product Requirements Document (PRD)
**Project Name:** Smart Attendance App  
**Document Version:** 1.0.0  
**Traceability Base:** Approved BRD v1.0.0  
**Author:** Senior Product Manager & Scrum Master  

---

## 1. Product Overview & Strategic Goals

The Smart Attendance App is an offline-first mobile application built for Android and iOS that eliminates attendance friction and fraud in educational institutions. Powered by cryptographic verification (Ed25519) and rotating dynamic projector tokens, the product offers flexible multi-method attendance recording, batch student roster administration, and instant analytics reporting.

### Core Goals
1. **Zero-Latency In-Class Experience:** Instant visual and haptic feedback during scanning (< 300ms verification).
2. **Resilience to Infrastructure Failure:** Full functional capability without internet connectivity.
3. **Seamless Anti-Fraud Protections:** Automated mitigation of remote proxy check-ins.
4. **Bilingual Simplicity:** Complete Arabic/English parity with instant runtime language switching.

---

## 2. User Personas & User Journeys

### 2.1 Personas

#### Persona A: Dr. Tariq (Academy Instructor / Admin)
* **Demographics:** 42 years old, instructs technical bootcamps with 60+ students per cohort.
* **Pain Points:** Spends the first 15 minutes of every lecture verifying attendance; frustrated when students share codes with absent friends; struggles with poor Wi-Fi in the campus auditorium.
* **Needs:** A 1-tap solution to project a dynamic QR code on screen, an offline camera scanner to verify students quickly at the door, and an instant CSV export at the end of the month.

#### Persona B: Salma (Bootcamp Student)
* **Demographics:** 21 years old, enrolled in mobile software engineering.
* **Pain Points:** Waits in long queues to sign physical paper; loses track of her attendance percentage and risks getting disqualified without prior warning.
* **Needs:** Quick self-check-in by pointing her phone at the projector, access to an offline personal QR card, and clear real-time visibility into her attendance history.

---

## 3. Product Epics, User Stories & Acceptance Criteria

### Epic 1: Identity, Roles & Session Guard (AUTH)
*Traceable to: BR-01, BR-09*

#### US-1.1: Multi-Role Secure Login & Routing
* **User Story:** As a registered user, I want to sign in with my email and password so that I am automatically directed to the correct layout (Admin or Student) based on my account role.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-01
* **Acceptance Criteria:**
  * **Given** an unauthenticated user on the login screen,
  * **When** they enter valid credentials with role `admin`,
  * **Then** the app navigates to `AdminLayoutRoute`.
  * **Given** valid credentials with role `student`,
  * **When** authentication succeeds,
  * **Then** the app navigates to `StudentLayoutRoute`.

#### US-1.2: Upgrade to Instructor via Invite Code
* **User Story:** As an authorized staff member registered as a student, I want to redeem an instructor invite code in settings so that my account role is immediately promoted to `admin`.
* **Priority:** Should Have (MoSCoW) | **Traceability:** BR-01
* **Acceptance Criteria:**
  * **Given** a student user in Settings,
  * **When** they open "Become an Instructor" and input an unused code from `instructorInvites/{code}`,
  * **Then** Firestore updates `role: 'admin'`, marks the invite code as `used: true`, and immediately swaps the navigation shell to `AdminLayoutRoute`.

---

### Epic 2: Programs & Course Management (PROG)
*Traceable to: BR-02, BR-09*

#### US-2.1: Program Creation & Invite Generation
* **User Story:** As an instructor, I want to create a new program with a title, type, and minimum attendance threshold so that a unique 6-character invite code and enrollment QR are automatically generated.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-02
* **Acceptance Criteria:**
  * **Given** an instructor on the Programs tab,
  * **When** they fill the program creation form and submit,
  * **Then** a new program document is created in Firestore with an uppercase 6-character code (e.g. `FLT123`).

#### US-2.2: Program Enrollment via QR Scan or Code
* **User Story:** As a student, I want to join a program by either typing the 6-character invite code or scanning the program QR code with my camera so that I can enroll without manual typing errors.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-02
* **Acceptance Criteria:**
  * **Given** a student on the "Join Program" sheet,
  * **When** they tap "Scan Program QR Code" and scan the instructor's program QR,
  * **Then** the invite code auto-populates, submits automatically, enrolls the student into `programs/{id}/enrollments/{uid}`, and triggers a success toast.

#### US-2.3: Instructor Program QR Display Sheet
* **User Story:** As an instructor, I want to view a large, high-contrast QR code for my program so that I can present it on a screen for in-class enrollment.
* **Priority:** Should Have (MoSCoW) | **Traceability:** BR-02
* **Acceptance Criteria:**
  * **Given** an instructor viewing a Program card or details page,
  * **When** they tap the QR icon next to the invite code,
  * **Then** a modal opens rendering a smooth high-contrast `PrettyQrView`, the invite code in bold with copy functionality, and student instructions.

---

### Epic 3: Lecture Sessions & State Lifecycle (SESS)
*Traceable to: BR-03, BR-06*

#### US-3.1: Session Scheduling & Lifecycle Management
* **User Story:** As an instructor, I want to schedule sessions with a start/end time and late threshold, and control their state (`scheduled` → `open` → `closed`).
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-03, BR-06
* **Acceptance Criteria:**
  * **Given** a scheduled session,
  * **When** the instructor taps "Open Session",
  * **Then** the session status updates to `open`, allowing check-ins to proceed.
  * **When** the instructor taps "Close Session",
  * **Then** the status transitions to `closed`, terminating all check-in flows.

#### US-3.2: Automated Absentee Finalization
* **User Story:** As an instructor, I want all enrolled students who failed to check in to be marked as `absent` when I close a session so that I do not need to mark absences manually.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-06
* **Acceptance Criteria:**
  * **Given** an open session with 10 enrolled students and only 7 checked in,
  * **When** the session status is changed to `closed`,
  * **Then** the system queries enrolled students, identifies the 3 missing students, and commits `status: 'absent'` records for each using deterministic IDs.

---

### Epic 4: Anti-Fraud Multi-Method Check-In (ATTD)
*Traceable to: BR-03, BR-04, BR-05*

#### US-4.1: Method A — Offline Student Badge & Instructor Scanner
* **User Story:** As a student, I want to display an offline cryptographically signed QR badge, and as an instructor, I want to scan it even without internet connectivity.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-04, BR-05
* **Acceptance Criteria:**
  * **Given** a student without cellular connection opening the "My QR" tab,
  * **Then** a token signed with Ed25519 is generated and screen brightness is increased to maximum.
  * **Given** an instructor in an offline lecture hall,
  * **When** the instructor scans the student's badge,
  * **Then** the signature is verified locally, an attendance record (`present` or `late`) is written to the offline Firestore cache, and a pending-sync badge is shown.

#### US-4.2: Method B — Projector Mode & Student Self Check-In
* **User Story:** As an instructor, I want to broadcast a rotating dynamic QR code on the lecture projector, and as a student, I want to scan it to verify my presence.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-03, BR-05
* **Acceptance Criteria:**
  * **Given** an active session in Projector Mode,
  * **Then** a dynamic QR code refreshes every 20 seconds with a real-time countdown bar.
  * **Given** an enrolled student scanning this QR code,
  * **When** the token timestamp is verified within the active window (±1 window tolerance),
  * **Then** an attendance record is created and the instructor's live attendee counter increments.
  * **Given** an expired or photographed code scanned after > 40 seconds,
  * **Then** the check-in is rejected with an invalid token error.

#### US-4.3: Method C — Manual Roster Overrides & Batch CSV Import
* **User Story:** As an instructor, I want to view the student roster, manually toggle attendance status, and import student rosters in bulk via CSV files.
* **Priority:** Should Have (MoSCoW) | **Traceability:** BR-04, BR-05
* **Acceptance Criteria:**
  * **Given** an instructor on the Students tab,
  * **When** they tap on an enrolled student's tile,
  * **Then** they can manually override the record to `present`, `late`, `excused`, or `absent`.
  * **When** they upload a CSV roster containing `Name` and `Email` columns,
  * **Then** all valid entries are parsed and batch-written to the program enrollments.

---

### Epic 5: Analytics, Reports & Native Sharing (REPO)
*Traceable to: BR-07, BR-08*

#### US-5.1: KPI Dashboard & At-Risk Highlighting
* **User Story:** As an academic director or instructor, I want to view program attendance health metrics so that I can intervene with at-risk students immediately.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-07
* **Acceptance Criteria:**
  * **Given** an instructor opening the Reports tab,
  * **Then** the dashboard displays: Total Sessions, Average Attendance Rate (%), and At-Risk Student Count (< 80%).
  * **Given** a student with attendance rate below the minimum threshold,
  * **Then** their profile is highlighted with a warning badge and warning metrics.

#### US-5.2: Instant CSV Export with Native Device Sharing
* **User Story:** As an instructor, I want to export the complete attendance sheet into a CSV file and share it via WhatsApp, email, or Google Drive directly from my phone.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-08
* **Acceptance Criteria:**
  * **Given** an instructor selecting a program on the Reports tab,
  * **When** they tap "Export CSV",
  * **Then** a standardized CSV file is compiled containing Student Names, Emails, Session Titles, Dates, and Statuses, and the native device share sheet is launched automatically.

---

### Epic 6: Internationalization & Localization (I18N)
*Traceable to: BR-09*

#### US-6.1: Hot-Swappable Arabic/English Parity
* **User Story:** As a user in the MENA region, I want to switch between Arabic (RTL) and English (LTR) seamlessly without restarting the app.
* **Priority:** Must Have (MoSCoW) | **Traceability:** BR-09
* **Acceptance Criteria:**
  * **Given** any screen in the app,
  * **When** the user selects Arabic in Settings,
  * **Then** the layout switches dynamically to Right-to-Left (RTL), typography aligns correctly, and all strings reflect accurate terminology.

---

## 4. Functional & Non-Functional Requirements

### 4.1 Functional Requirements (FR)

| Req ID | Description | Traceability |
| :--- | :--- | :--- |
| **FR-01** | Support email/password registration, login, logout, and password recovery. | BR-01 |
| **FR-02** | Provide role-based navigation guards (`AdminLayout` vs `StudentLayout`). | BR-01 |
| **FR-03** | Support program creation, editing, and listing with auto-generated 6-char codes. | BR-02 |
| **FR-04** | Render high-contrast Program QR display sheets using `pretty_qr_code`. | BR-02 |
| **FR-05** | Provide in-app camera scanner for joining programs via QR. | BR-02 |
| **FR-06** | Support session creation with customizable start/end times and late thresholds. | BR-03 |
| **FR-07** | Support session status transitions (`scheduled` → `open` → `closed`). | BR-03, BR-06 |
| **FR-08** | Generate offline student Ed25519 cryptographic QR tokens. | BR-04 |
| **FR-09** | Broadcast rotating 20-second dynamic projector tokens with SHA-256 HMAC. | BR-03 |
| **FR-10** | Provide laser-guided camera scanner with torch toggle and vector cutout overlay. | BR-03, BR-04 |
| **FR-11** | Idempotent attendance writing using deterministic document keys (`${sessionId}_${studentId}`). | BR-05 |
| **FR-12** | Automatic absent record generation on session closure for unmarked students. | BR-06 |
| **FR-13** | Parse and import batch student rosters from CSV files. | BR-04 |
| **FR-14** | Display program KPI cards, segmented progress bars, and at-risk alerts. | BR-07 |
| **FR-15** | Generate and export CSV attendance ledgers via native device share sheets. | BR-08 |
| **FR-16** | Provide runtime language toggling between Arabic (RTL) and English (LTR). | BR-09 |

### 4.2 Non-Functional Requirements (NFR)

| Category | Requirement | Metric / Specification |
| :--- | :--- | :--- |
| **Performance** | QR Verification Latency | Scan detection to validation feedback in **< 300 ms**. |
| **Performance** | App Launch Time | Cold start to interactive dashboard in **< 2.0 seconds**. |
| **Offline** | Persistence Capacity | Unlimited Firestore offline persistence using local LevelDB cache. |
| **Security** | Anti-Tampering | Ed25519 digital signatures on student identity payloads; SHA-256 HMAC on dynamic session tokens. |
| **Security** | Access Control | Firestore Security Rules enforcing role claims; client writes restricted to enrolled programs. |
| **Localization** | Dual-Language RTL/LTR | 100% string externalization in `ar-EG.json` and `en-US.json`. |
| **Reliability** | Conflict Resolution | Zero duplicate records on concurrent or batched offline synchronization. |
| **Accessibility** | High Contrast & Haptics | Screen brightness auto-boost for QR display; tactile haptic feedback on successful scans. |

---

## 5. Core Data Entities (Firestore Schema)

```
users/{uid}
  ├── email: string
  ├── name: string
  ├── role: "admin" | "student"
  └── updatedAt: timestamp

programs/{programId}
  ├── title: string
  ├── description: string
  ├── type: "course" | "bootcamp" | "event"
  ├── inviteCode: string (e.g. "FLT123")
  ├── instructorId: string
  ├── minAttendancePercent: number (e.g. 80)
  ├── createdAt: timestamp
  └── enrollments/{studentId}
        ├── studentId: string
        ├── studentName: string
        └── enrolledAt: timestamp

sessions/{sessionId}
  ├── programId: string
  ├── title: string
  ├── startTime: timestamp
  ├── endTime: timestamp
  ├── lateThresholdMinutes: number (e.g. 15)
  ├── status: "scheduled" | "open" | "closed"
  ├── secretToken: string (HMAC key)
  └── createdAt: timestamp

attendance/{sessionId_studentId}
  ├── sessionId: string
  ├── programId: string
  ├── studentId: string
  ├── studentName: string
  ├── status: "present" | "late" | "absent" | "excused"
  ├── checkInMethod: "method_a" | "method_b" | "manual" | "auto_absent"
  ├── timestamp: timestamp
  └── isSynced: boolean

instructorInvites/{code}
  ├── used: boolean
  ├── usedBy: string
  └── redeemedAt: timestamp
```
