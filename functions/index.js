const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
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
        // Send via Resend REST API if key provided
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
        // In local development / preview or until SMTP credentials are configured:
        console.log(`[DEV MODE] Password reset email generated for: ${email}`);
        console.log(`[DEV MODE] Reset Link: ${resetLink}`);
      }
    } catch (error) {
      // Security best practice:
      // If user does not exist (auth/user-not-found), swallow the error
      // so attackers cannot enumerate valid user emails.
      if (error?.code === "auth/user-not-found") {
        console.log(`Password reset requested for non-existent user: ${email}`);
        return { ok: true };
      }
      console.error("Error generating password reset link:", error);
      // For any other unexpected error, log and return generic success or handle safely
    }

    return { ok: true };
  }
);
