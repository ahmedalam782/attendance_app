/**
 * Generates a branded, responsive HTML email template for password reset.
 * Supports both Arabic (RTL) and English (LTR).
 *
 * @param {Object} options
 * @param {string} options.resetLink - The Firebase password reset action URL.
 * @param {string} [options.languageCode='ar'] - Language code ('ar' or 'en').
 * @param {string} [options.appName='الحضور | Attendance App'] - App display name.
 * @returns {{ subject: string, html: string }}
 */
function getPasswordResetEmailTemplate({ resetLink, languageCode = 'ar', appName = 'الحضور' }) {
  const isArabic = languageCode === 'ar';

  const texts = isArabic
    ? {
        subject: `إعادة تعيين كلمة المرور - ${appName}`,
        previewText: 'طلب إعادة تعيين كلمة المرور لحسابك في تطبيق الحضور',
        greeting: 'مرحباً،',
        title: 'إعادة تعيين كلمة المرور',
        message:
          'لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في تطبيق الحضور. اضغط على الزر أدناه لاختيار كلمة مرور جديدة:',
        buttonText: 'إعادة تعيين كلمة المرور',
        linkFallbackTitle: 'إذا لم يعمل الزر أعلاه، يمكنك نسخ هذا الرابط ولصقه في متصفحك:',
        securityNotice:
          'إذا لم تطلب إعادة تعيين كلمة المرور، يمكنك تجاهل هذا البريد الإلكتروني بأمان. لن يتم تغيير كلمة المرور الخاصة بك دون الدخول إلى هذا الرابط.',
        expiresNote: 'ملاحظة: هذا الرابط صالح لفترة زمنية محدودة.',
        footer: `© ${new Date().getFullYear()} ${appName}. جميع الحقوق محفوظة.`,
      }
    : {
        subject: `Reset your password - ${appName}`,
        previewText: 'Password reset request for your Attendance App account',
        greeting: 'Hello,',
        title: 'Reset Your Password',
        message:
          'We received a request to reset the password for your Attendance App account. Click the button below to set a new password:',
        buttonText: 'Reset Password',
        linkFallbackTitle: 'If the button above does not work, copy and paste this link into your browser:',
        securityNotice:
          "If you did not request a password reset, you can safely ignore this email. Your password won't change until you access this link.",
        expiresNote: 'Note: This link is valid for a limited time.',
        footer: `© ${new Date().getFullYear()} ${appName}. All rights reserved.`,
      };

  const dir = isArabic ? 'rtl' : 'ltr';
  const textAlign = isArabic ? 'right' : 'left';
  const fontFamily = isArabic
    ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Noto Sans Arabic', 'Helvetica Neue', Arial, sans-serif"
    : "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif";

  const html = `<!DOCTYPE html>
<html lang="${languageCode}" dir="${dir}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>${texts.subject}</title>
  <!--[if mso]>
  <style type="text/css">
    body, table, td {font-family: Arial, Helvetica, sans-serif !important;}
  </style>
  <![endif]-->
</head>
<body style="margin: 0; padding: 0; background-color: #F8FAFC; font-family: ${fontFamily}; color: #1E293B; -webkit-font-smoothing: antialiased; line-height: 1.6;">
  <div style="display: none; font-size: 1px; color: #F8FAFC; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
    ${texts.previewText}
  </div>

  <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #F8FAFC; padding: 40px 16px;">
    <tr>
      <td align="center">
        <!-- Main Card -->
        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width: 520px; background-color: #FFFFFF; border-radius: 20px; border: 1px solid #E2E8F0; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05); overflow: hidden;">
          <!-- Header Banner -->
          <tr>
            <td style="padding: 36px 32px 24px 32px; text-align: center; background: linear-gradient(135deg, #4F46E5 0%, #3B82F6 100%);">
              <table role="presentation" border="0" cellspacing="0" cellpadding="0" style="margin: 0 auto;">
                <tr>
                  <td style="width: 56px; height: 56px; background-color: rgba(255, 255, 255, 0.2); border-radius: 16px; text-align: center; vertical-align: middle;">
                    <!-- Shield Key Icon in pure inline SVG -->
                    <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="display: inline-block; vertical-align: middle;">
                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                  </td>
                </tr>
              </table>
              <h1 style="margin: 14px 0 0 0; color: #FFFFFF; font-size: 22px; font-weight: 700; letter-spacing: -0.3px;">
                ${appName}
              </h1>
            </td>
          </tr>

          <!-- Content Body -->
          <tr>
            <td style="padding: 32px; text-align: ${textAlign}; direction: ${dir};">
              <p style="margin: 0 0 12px 0; font-size: 17px; font-weight: 600; color: #0F172A;">
                ${texts.greeting}
              </p>
              <h2 style="margin: 0 0 14px 0; font-size: 20px; font-weight: 700; color: #1E293B;">
                ${texts.title}
              </h2>
              <p style="margin: 0 0 26px 0; font-size: 15px; color: #475569; line-height: 1.7;">
                ${texts.message}
              </p>

              <!-- CTA Button -->
              <table role="presentation" border="0" cellspacing="0" cellpadding="0" style="margin: 0 auto 28px auto; width: 100%;">
                <tr>
                  <td align="center">
                    <table role="presentation" border="0" cellspacing="0" cellpadding="0" style="width: 100%;">
                      <tr>
                        <td align="center" style="border-radius: 14px; background: linear-gradient(135deg, #4F46E5 0%, #3B82F6 100%);">
                          <a href="${resetLink}" target="_blank" rel="noopener noreferrer" style="display: block; padding: 15px 32px; font-size: 16px; font-weight: 700; color: #FFFFFF; text-decoration: none; border-radius: 14px; text-align: center; letter-spacing: 0.2px;">
                            ${texts.buttonText}
                          </a>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Expiry & Security Notice Box -->
              <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #F1F5F9; border-radius: 12px; border: 1px solid #E2E8F0; margin-bottom: 24px;">
                <tr>
                  <td style="padding: 16px; font-size: 13px; color: #475569; line-height: 1.6; text-align: ${textAlign}; direction: ${dir};">
                    <strong style="color: #1E293B;">🔒 ${texts.expiresNote}</strong><br>
                    ${texts.securityNotice}
                  </td>
                </tr>
              </table>

              <!-- Fallback Plain Link -->
              <p style="margin: 0 0 6px 0; font-size: 12px; color: #94A3B8;">
                ${texts.linkFallbackTitle}
              </p>
              <p style="margin: 0; font-size: 12px; word-break: break-all; color: #4F46E5; direction: ltr; text-align: ${textAlign};">
                <a href="${resetLink}" style="color: #4F46E5; text-decoration: underline;">
                  ${resetLink}
                </a>
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding: 20px 32px; background-color: #F8FAFC; border-top: 1px solid #E2E8F0; text-align: center; font-size: 12px; color: #94A3B8;">
              ${texts.footer}
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

  return {
    subject: texts.subject,
    html,
  };
}

module.exports = {
  getPasswordResetEmailTemplate,
};
