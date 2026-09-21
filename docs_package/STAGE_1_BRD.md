# STAGE 1 — Business Requirements Document (BRD)
**Project Name:** Smart Attendance App  
**Document Version:** 1.0.0  
**Author:** Senior Business Analyst & Product Manager  

---

## 1. Executive Summary & Business Problem

### 1.1 The Business Problem
Educational institutions, corporate academies, and bootcamp providers lose **10–20 minutes per 2-hour lecture** performing manual paper-based attendance or verbal roll calls. These manual methods suffer from:
1. **High Inefficiency:** Up to 15% of class instruction time is lost to routine administrative overhead.
2. **Proxy Attendance ("Buddy Punching"):** Students sign attendance sheets or share static QR codes / passcodes remotely for absent peers.
3. **Connectivity Vulnerability:** Standard cloud-only solutions crash or stall when classroom cellular reception is weak or campus Wi-Fi drops.
4. **Data Fragmentation:** Absence records, late arrivals, and at-risk student lists remain locked on paper or disparate spreadsheets, delaying disciplinary and retention interventions until it is too late.

### 1.2 Business Objectives (Measurable)
* **OBJ-01 (Check-in Velocity):** Reduce total classroom check-in time to **< 5 seconds per student** (less than 90 seconds for a 50-student lecture hall).
* **OBJ-02 (Zero Disruption Offline Operations):** Achieve **100% check-in capability during offline network blackouts**, guaranteeing zero data loss with deterministic synchronization upon reconnection.
* **OBJ-03 (Fraud Elimination):** Mitigate remote buddy-punching by **≥ 95%** using rotating dynamic cryptographic tokens (20-second validity window) and cryptographic Ed25519 digital signatures.
* **OBJ-04 (Administrative Overhead Reduction):** Cut end-of-month and end-of-term attendance reporting and roster compilation effort by **≥ 80%** through instant CSV generation and KPI analytics.

---

## 2. Stakeholders & Target Users

| Stakeholder / Persona | Role in System | Key Needs & Objectives |
| :--- | :--- | :--- |
| **Academic Director / Admin** | System Owner | Oversees programs, tracks retention metrics, monitors compliance, issues credentials, audits reports. |
| **Instructor / Trainer** | Session Facilitator | Starts sessions, presents dynamic projector QR codes, scans offline student cards, manages rosters, marks excuses/delays. |
| **Student / Trainee** | Attendee | Views enrolled courses, joins via program QR code, presents offline student QR badge, scans dynamic in-class QR to self-check-in, monitors own attendance rate. |
| **IT & Operations Team** | Infrastructure Support | Requires low maintenance, zero-cost serverless elasticity (Firebase), offline cache resilience, and secure data backups. |

---

## 3. Project Scope

### 3.1 In-Scope (MVP)
* **Multi-Role Authentication & Access Control:** Secure email/password login, password resets, role-based navigation guards (`AdminLayout` vs `StudentLayout`), and instructor invite redemption codes.
* **Programs & Course Management:** Creation of programs (Course, Bootcamp, Event), automated 6-character invite code generation, Program QR code generation for quick class enrollment, and student join-via-scan flow.
* **Lecture / Session Scheduling:** Creation of program sessions, configurable late arrival threshold (grace period in minutes), and stateful lifecycle controls (`scheduled` → `open` → `closed`).
* **Multi-Method Attendance Verification:**
  * **Method A (Instructor Scans Student):** Offline student QR badge with Ed25519 cryptographic signature and dynamic brightness boost.
  * **Method B (Student Scans Instructor):** Rotating dynamic session QR in projector mode with 20-second countdown and ±1 window drift tolerance.
  * **Method C (Roster & Manual Overrides):** Live session attendee roster with manual status toggling (`present`, `late`, `absent`, `excused`).
* **Batch Student Enrollment:** CSV file upload parsing with schema validation and bulk Firestore writes.
* **Automated Session Finalization:** Auto-marking unmarked enrolled students as `absent` when an instructor closes a session.
* **Analytics & Native Export:** Program-level KPI dashboards (average attendance rate, at-risk students `< 80%`), segmented progress bars, and native one-tap CSV file export via device sharing.
* **Internationalization (i18n):** Native bilingual support for Arabic (RTL) and English (LTR) with instant hot-swapping.

### 3.2 Out-of-Scope (Deferred to Phase 2)
* GPS Geofencing and Wi-Fi SSID network whitelisting.
* BLE (Bluetooth Low Energy) beacon proximity check-in.
* Biometric facial recognition or fingerprint scanner hardware integration.
* Payment gateway integrations, course fee collections, or payroll processing.
* Native web desktop administration dashboard (mobile-first tablet/phone view only in MVP).

---

## 4. High-Level Business Requirements (BR)

* **BR-01 (Role Segregation & Security):** The system shall strictly isolate admin/instructor functionalities (session creation, scanner, reports) from student views via cryptographically verified role claims.
* **BR-02 (Frictionless Program Enrollment):** Students shall be able to join an academic program either by entering a 6-character alphanumeric invite code or by scanning a program-specific QR code displayed by the instructor.
* **BR-03 (Anti-Fraud Self Check-In):** The system shall allow students to self-check-in by scanning an in-class projector QR code that auto-refreshes every 20 seconds; past or photographed tokens older than the allowed tolerance window shall be permanently rejected.
* **BR-04 (Network-Resilient Scanning):** Instructors shall be capable of scanning students' offline QR badges in underground or low-connectivity lecture rooms; attendance records must be committed to local persistence and automatically queued for cloud synchronization upon network restoration.
* **BR-05 (Deterministic Conflict Resolution):** Simultaneous scans or duplicated offline sync packets for the same session and student shall resolve deterministically to a single canonical record (`sessionId_studentId`) with zero duplicate count inflation.
* **BR-06 (Automated Absence Enforcement):** When a session status transitions to `closed`, all enrolled students who lack an attendance record for that session shall be automatically marked as `absent`.
* **BR-07 (Executive KPI & Risk Visibility):** The system shall compute and display real-time attendance percentages per program and flag students whose attendance falls below the minimum policy threshold (e.g., `< 80%`).
* **BR-08 (Open Interoperability & Export):** Authorized instructors/admins shall be able to generate and export attendance registers into industry-standard CSV format and share them directly via native messaging, email, or cloud drives.
* **BR-09 (Bilingual Cultural Localization):** The entire application user interface, error messages, dates, and navigation layouts must fully support both Arabic (with complete RTL mirroring) and English (LTR).

---

## 5. Assumptions, Risks & Dependencies

### 5.1 Business Assumptions
1. Every student owns or has access to a smartphone running Android (SDK ≥ 23) or iOS (≥ 13.0) with an operational camera.
2. Instructors have access to a classroom projector, external monitor, or tablet to display the dynamic projector QR code for Method B.
3. Student clocks will synchronize with standard network time protocols (NTP) with drift under ±20 seconds.

### 5.2 Business Risks & Mitigations

| Risk ID | Risk Description | Severity | Mitigation Strategy |
| :--- | :--- | :---: | :--- |
| **RSK-01** | Screen glare or low ambient light preventing camera QR recognition in large lecture halls. | **High** | Auto-maximize student screen brightness (`screen_brightness`), provide high-contrast `pretty_qr_code` matrix rendering, and add in-app camera torch toggle. |
| **RSK-02** | Students sharing screenshots of self-check-in QR codes via WhatsApp/Telegram to remote peers. | **High** | Method B enforces a 20-second dynamic expiration window with SHA-256 HMAC verification. Method A relies on Ed25519 student identity tokens. |
| **RSK-03** | Extended classroom network outages lasting days or weeks. | **Medium** | Unlimited Firestore offline cache enabled on device; all writes queue deterministically in local SQLite/LevelDB and synchronize automatically. |
| **RSK-04** | Accidental double-scanning of the same student. | **Low** | Idempotent document keys (`${sessionId}_${studentId}`) guarantee atomic upserts without duplicate counting. |

### 5.3 System Dependencies
* **Firebase Cloud Infrastructure:** Firebase Auth, Cloud Firestore, Firebase Cloud Storage, and Node.js Cloud Functions.
* **Native Device Hardware:** Camera sensor with barcode/QR scanning capabilities (`mobile_scanner`).
* **Google Play Services / Apple Core:** Push notification delivery via FCM (`firebase_messaging`).

---

## 6. Success Metrics & Key Performance Indicators (KPIs)

* **KPI-01 (Adoption Rate):** ≥ 90% of enrolled students successfully join their academic programs and record attendance via the app within the first week of deployment.
* **KPI-02 (Check-in Efficiency):** Average check-in time per classroom session reduced from 12 minutes (manual baseline) to **< 90 seconds**.
* **KPI-03 (Offline Reliability):** 100% of offline-scanned attendance records successfully synced to Firestore once connection is restored, with **0% data loss**.
* **KPI-04 (At-Risk Early Detection):** 100% of students falling below the 80% minimum attendance threshold flagged in real-time on the instructor/admin dashboard.
* **KPI-05 (User Satisfaction Score):** Instructor and student app store / internal survey rating ≥ **4.6 / 5.0**.
