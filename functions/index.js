const { onCall, HttpsError, onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { beforeUserCreated } = require("firebase-functions/v2/identity");
const admin = require("firebase-admin");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const { getPasswordResetEmailTemplate } = require("./email_template");

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Configure email transport based on environment variables.
 * Supports:
 * - SMTP (Gmail, Hostinger, custom domain SMTP)
 * - Resend API
 * - SendGrid API
 */
function createEmailTransporter() {
  const smtpHost = process.env.SMTP_HOST;
  const smtpPort = process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT, 10) : 587;
  const smtpUser = process.env.SMTP_USER;
  const smtpPass = process.env.SMTP_PASS;

  if (smtpHost && smtpUser && smtpPass) {
    return nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpPort === 465,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });
  }

  return null;
}

/**
 * Cloud Function to generate a secure password reset link and send a branded,
 * responsive email (supporting Arabic RTL & English LTR).
 *
 * Call from Flutter:
 *   FirebaseFunctions.instance.httpsCallable('sendCustomPasswordResetEmail')
 *     .call({'email': email, 'languageCode': 'ar'});
 */
exports.sendCustomPasswordResetEmail = onCall(
  {
    cors: true,
    region: "europe-west3", // aligns with firebase.json location
  },
  async (request) => {
    const email = String(request.data?.email ?? "").trim().toLowerCase();
    const languageCode = String(request.data?.languageCode ?? "ar").toLowerCase();

    // Basic email sanity check
    if (!email || !email.includes("@")) {
      throw new HttpsError("invalid-argument", "A valid email address is required.");
    }

    try {
      // 1. Generate one-time secure Firebase Auth reset action link
      const resetLink = await admin.auth().generatePasswordResetLink(email);

      // 2. Build branded HTML email template (Arabic or English)
      const { subject, html } = getPasswordResetEmailTemplate({
        resetLink,
        languageCode,
        appName: languageCode === "ar" ? "الحضور" : "Attendance App",
      });

      const senderEmail = process.env.MAIL_FROM || "noreply@attendanceapp.com";
      const senderName = languageCode === "ar" ? "فريق تطبيق الحضور" : "Attendance App Team";

      // 3. Dispatch email
      const transporter = createEmailTransporter();
      if (transporter) {
        await transporter.sendMail({
          from: `"${senderName}" <${senderEmail}>`,
          to: email,
          subject,
          html,
        });
      } else if (process.env.RESEND_API_KEY) {
        const response = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${process.env.RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: `${senderName} <${senderEmail}>`,
            to: [email],
            subject,
            html,
          }),
        });

        if (!response.ok) {
          const errData = await response.text();
          console.error("Resend API error:", errData);
        }
      } else {
        console.log(`[DEV MODE] Password reset email generated for: ${email}`);
        console.log(`[DEV MODE] Reset Link: ${resetLink}`);
      }
    } catch (error) {
      if (error?.code === "auth/user-not-found") {
        console.log(`Password reset requested for non-existent user: ${email}`);
        return { ok: true };
      }
      console.error("Error generating password reset link:", error);
    }

    return { ok: true };
  }
);

/**
 * Blocking Auth function triggered before user creation.
 * Sets default role claim to 'student' and provisions users/{uid} document.
 */
exports.beforeUserCreated = beforeUserCreated(
  {
    region: "europe-west3",
  },
  async (event) => {
    const user = event.data;
    const uid = user.uid;

    try {
      await admin.firestore().collection("users").doc(uid).set({
        uid: uid,
        email: user.email || "",
        name: user.displayName || user.email?.split("@")[0] || "User",
        role: "student",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    } catch (err) {
      console.error("Error provisioning user document:", err);
    }

    return {
      customClaims: {
        role: "student",
      },
    };
  }
);

/**
 * Callable function to redeem a single-use instructor invite code.
 * Validates code, marks it used, and upgrades user custom claims and profile to 'admin'.
 */
exports.redeemInstructorCode = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in to redeem an instructor code.");
    }

    const uid = request.auth.uid;
    const code = String(request.data?.code ?? "").trim();

    if (!code) {
      throw new HttpsError("invalid-argument", "An instructor invite code is required.");
    }

    const inviteRef = admin.firestore().collection("instructorInvites").doc(code);
    const userRef = admin.firestore().collection("users").doc(uid);

    await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(inviteRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Invalid instructor invite code.");
      }

      const invite = snap.data();
      if (invite.used) {
        throw new HttpsError("already-exists", "This instructor invite code has already been redeemed.");
      }

      if (invite.expiresAt && invite.expiresAt.toMillis() < Date.now()) {
        throw new HttpsError("failed-precondition", "This instructor invite code has expired.");
      }

      // Mark invite code as used
      tx.update(inviteRef, {
        used: true,
        usedBy: uid,
        redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update user doc in Firestore
      tx.set(
        userRef,
        {
          role: "admin",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    // Set custom claims for instant server-verified admin access
    await admin.auth().setCustomUserClaims(uid, { role: "admin" });

    return { ok: true, role: "admin" };
  }
);

/**
 * Callable function to join a program via invite code.
 * Validates program code, enrolls student, and updates studentCount.
 */
exports.joinProgram = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in to join a program.");
    }

    const uid = request.auth.uid;
    const inviteCode = String(request.data?.inviteCode ?? "").trim().toUpperCase();
    const studentName = String(request.data?.studentName ?? "").trim() || "Student";

    if (!inviteCode) {
      throw new HttpsError("invalid-argument", "Program invite code is required.");
    }

    const query = await admin.firestore().collection("programs")
      .where("inviteCode", "==", inviteCode)
      .limit(1)
      .get();

    if (query.empty) {
      throw new HttpsError("not-found", "No program found for this invite code.");
    }

    const programDoc = query.docs[0];
    const programId = programDoc.id;
    const programData = programDoc.data();

    const studentRef = admin.firestore()
      .collection("programs")
      .doc(programId)
      .collection("students")
      .doc(uid);

    const programRef = programDoc.ref;

    await admin.firestore().runTransaction(async (tx) => {
      const studentSnap = await tx.get(studentRef);
      if (!studentSnap.exists) {
        tx.set(studentRef, {
          id: uid,
          name: studentName,
          joinedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "active",
        });

        tx.update(programRef, {
          studentIds: admin.firestore.FieldValue.arrayUnion(uid),
          studentCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    return {
      ok: true,
      programId,
      programTitle: programData.title,
    };
  }
);

/**
 * Firestore Trigger: Validates attendance records upon creation.
 * Checks enrollment status and session window, automatically setting flagged: true if suspicious.
 */
exports.onAttendanceCreated = onDocumentCreated(
  {
    document: "programs/{programId}/sessions/{sessionId}/attendance/{attendanceId}",
    region: "europe-west3",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const record = snap.data();
    const { programId, sessionId } = event.params;
    const studentId = record.studentId;

    if (!studentId) return;

    const [sessionDoc, studentDoc] = await Promise.all([
      admin.firestore()
        .collection("programs")
        .doc(programId)
        .collection("sessions")
        .doc(sessionId)
        .get(),
      admin.firestore()
        .collection("programs")
        .doc(programId)
        .collection("students")
        .doc(studentId)
        .get(),
    ]);

    let isFlagged = false;
    let reason = "";

    if (!studentDoc.exists) {
      isFlagged = true;
      reason = "Student not enrolled in program";
    }

    if (sessionDoc.exists) {
      const session = sessionDoc.data();
      if (record.scannedAt && session.startAt && session.endAt) {
        const scannedMillis = record.scannedAt.toMillis ? record.scannedAt.toMillis() : new Date(record.scannedAt).getTime();
        const startMillis = session.startAt.toMillis ? session.startAt.toMillis() : new Date(session.startAt).getTime();
        const endMillis = session.endAt.toMillis ? session.endAt.toMillis() : new Date(session.endAt).getTime();

        // 45-minute grace/setup window buffer
        const buffer = 45 * 60 * 1000;
        if (scannedMillis < startMillis - buffer || scannedMillis > endMillis + buffer) {
          isFlagged = true;
          reason = reason ? `${reason}; Timestamp outside session window` : "Timestamp outside session window";
        }
      }
    }

    if (isFlagged) {
      await snap.ref.update({
        flagged: true,
        flagReason: reason,
        flaggedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

/**
 * Callable function to send an FCM session reminder to a program topic.
 */
exports.sendSessionReminder = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    const programId = String(request.data?.programId ?? "").trim();
    const sessionTitle = String(request.data?.sessionTitle ?? "").trim();
    const minutesBefore = parseInt(request.data?.minutesBefore ?? 15, 10);

    if (!programId || !sessionTitle) {
      throw new HttpsError("invalid-argument", "programId and sessionTitle are required.");
    }

    const topic = `programs_${programId}`;
    const payload = {
      topic,
      notification: {
        title: "Upcoming Session",
        body: `${sessionTitle} starts in ${minutesBefore} minutes. Open your app to prepare your pass.`,
      },
      data: {
        type: "session_reminder",
        programId,
        sessionTitle,
      },
    };

    try {
      const messageId = await admin.messaging().send(payload);
      return { ok: true, messageId };
    } catch (err) {
      console.error("Error broadcasting session reminder:", err);
      throw new HttpsError("internal", "Failed to broadcast notification.");
    }
  }
);

/**
 * Callable function to issue an Ed25519-signed QR credential for a student.
 * Signs {sid, name, iat, exp} with the Ed25519 private key and returns the token string.
 */
exports.issueCredential = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required to issue credential.");
    }

    const studentId = request.auth.uid;
    const studentName = String(request.data?.studentName ?? request.auth.token.name ?? "Student").trim();
    const expiresInDays = parseInt(request.data?.expiresInDays ?? 365, 10);

    const now = Date.now();
    const exp = now + expiresInDays * 24 * 60 * 60 * 1000;

    const payload = {
      sid: studentId,
      name: studentName,
      iat: now,
      exp: exp,
    };

    const payloadJson = JSON.stringify(payload);
    const payloadB64 = Buffer.from(payloadJson).toString("base64url");

    // In production, load the Ed25519 private key from environment or Secret Manager (ED25519_PRIVATE_KEY)
    let privateKeyPem = process.env.ED25519_PRIVATE_KEY;
    if (!privateKeyPem) {
      const keyPair = crypto.generateKeyPairSync("ed25519", {
        privateKeyEncoding: { type: "pkcs8", format: "pem" },
        publicKeyEncoding: { type: "spki", format: "pem" },
      });
      privateKeyPem = keyPair.privateKey;
    }

    const signature = crypto.sign(null, Buffer.from(payloadJson), privateKeyPem);
    const sigB64 = signature.toString("base64url");

    return {
      token: `${payloadB64}.${sigB64}`,
      expiresAt: exp,
    };
  }
);

/**
 * Callable function to export full attendance report for a program.
 * Aggregates all sessions and attendees for large programs where client export is heavy.
 */
exports.exportReport = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    const programId = String(request.data?.programId ?? "").trim();
    if (!programId) {
      throw new HttpsError("invalid-argument", "programId is required.");
    }

    // Verify caller is admin of program
    const programDoc = await admin.firestore().collection("programs").doc(programId).get();
    if (!programDoc.exists) {
      throw new HttpsError("not-found", "Program not found.");
    }

    const programData = programDoc.data();
    const callerUid = request.auth.uid;
    const isOwner = programData.ownerId === callerUid;
    const isAdmin = Array.isArray(programData.adminIds) && programData.adminIds.includes(callerUid);

    if (!isOwner && !isAdmin && request.auth.token?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only instructors can export program reports.");
    }

    const attendanceSnap = await admin.firestore()
      .collectionGroup("attendance")
      .where("programId", "==", programId)
      .get();

    const records = attendanceSnap.docs.map((doc) => {
      const d = doc.data();
      return {
        id: doc.id,
        sessionId: d.sessionId,
        studentId: d.studentId,
        studentName: d.studentName,
        status: d.status,
        method: d.method,
        scannedAt: d.scannedAt?.toDate?.()?.toISOString?.() || d.scannedAt,
        flagged: !!d.flagged,
      };
    });

    return {
      ok: true,
      programTitle: programData.title,
      totalRecords: records.length,
      records: records,
    };
  }
);

/**
 * HTTP trigger (one-shot) to seed the default admin account.
 *
 * Usage — call ONCE then disable or delete this function:
 *   curl https://europe-west3-attendance-app-44578.cloudfunctions.net/seedDefaultAdmin
 *
 * Reads credentials from environment variables (set in functions/.env):
 *   DEFAULT_ADMIN_EMAIL    (default: admin@attendanceapp.com)
 *   DEFAULT_ADMIN_PASSWORD (default: Admin@1234!)
 *   DEFAULT_ADMIN_NAME     (default: Default Admin)
 *
 * Safe to re-run: updates existing account, never duplicates.
 */
exports.seedDefaultAdmin = onRequest(
  {
    region: "europe-west3",
    invoker: "private", // Only callable by authenticated Firebase principals
  },
  async (req, res) => {
    const email    = process.env.DEFAULT_ADMIN_EMAIL    || "admin@attendanceapp.com";
    const password = process.env.DEFAULT_ADMIN_PASSWORD || "Admin@1234!";
    const name     = process.env.DEFAULT_ADMIN_NAME     || "Default Admin";

    try {
      let uid;
      let action = "created";

      // ── 1. Create or fetch the Firebase Auth user ──────────────────────────
      try {
        const existing = await admin.auth().getUserByEmail(email);
        uid = existing.uid;
        action = "updated";
        await admin.auth().updateUser(uid, { password, displayName: name });
      } catch (err) {
        if (err.code === "auth/user-not-found") {
          const created = await admin.auth().createUser({
            email,
            password,
            displayName: name,
            emailVerified: true,
          });
          uid = created.uid;
        } else {
          throw err;
        }
      }

      // ── 2. Set custom claims so the JWT carries role:'admin' ───────────────
      await admin.auth().setCustomUserClaims(uid, { role: "admin" });

      // ── 3. Upsert the Firestore users/{uid} document ───────────────────────
      await admin.firestore().collection("users").doc(uid).set(
        {
          uid,
          email,
          name,
          role: "admin",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log(`[seedDefaultAdmin] Admin ${action}: ${email} (uid=${uid})`);
      res.status(200).json({
        ok: true,
        action,
        uid,
        email,
        role: "admin",
        message: `Default admin ${action} successfully. UID: ${uid}`,
      });
    } catch (err) {
      console.error("[seedDefaultAdmin] Error:", err);
      res.status(500).json({ ok: false, error: err.message });
    }
  }
);

/**
 * Callable function — allows an existing admin to promote any user to 'admin'.
 *
 * Call from Flutter (admin-only action):
 *   FirebaseFunctions.instance
 *     .httpsCallable('promoteToAdmin')
 *     .call({'uid': '<target_uid>'});   // OR use 'email' instead
 */
exports.promoteToAdmin = onCall(
  {
    cors: true,
    region: "europe-west3",
  },
  async (request) => {
    // ── Guard: caller must be an admin ─────────────────────────────────────
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }
    if (request.auth.token?.role !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can promote users.");
    }

    const targetUid   = String(request.data?.uid   ?? "").trim();
    const targetEmail = String(request.data?.email ?? "").trim().toLowerCase();

    if (!targetUid && !targetEmail) {
      throw new HttpsError("invalid-argument", "Provide either uid or email of the user to promote.");
    }

    // ── Resolve UID ────────────────────────────────────────────────────────
    let uid = targetUid;
    if (!uid) {
      const authUser = await admin.auth().getUserByEmail(targetEmail);
      uid = authUser.uid;
    }

    // ── Set custom claims ──────────────────────────────────────────────────
    await admin.auth().setCustomUserClaims(uid, { role: "admin" });

    // ── Update Firestore document ──────────────────────────────────────────
    await admin.firestore().collection("users").doc(uid).set(
      {
        role: "admin",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    console.log(`[promoteToAdmin] Promoted uid=${uid} to admin by ${request.auth.uid}`);
    return { ok: true, uid, role: "admin" };
  }
);
