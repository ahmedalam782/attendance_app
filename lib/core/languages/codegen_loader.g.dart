// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _ar_EG = {
  "global": {
    "app_name": "الحضور",
    "loading": "جارٍ التحميل...",
    "retry": "إعادة المحاولة",
    "setup_incomplete": "إعداد التطبيق غير مكتمل. تواصل مع المسؤول."
  },
  "login": {
    "title": "سجل الدخول إلى حسابك",
    "subtitle": "استخدم بريدك الإلكتروني وكلمة المرور للمتابعة",
    "email_hint": "البريد الإلكتروني",
    "password_hint": "كلمة المرور",
    "login_button": "تسجيل الدخول",
    "dont_have_account": "ليس لديك حساب؟",
    "create_account": "إنشاء حساب",
    "signed_in": "تم تسجيل الدخول",
    "logout": "تسجيل الخروج",
    "logout_title": "تسجيل الخروج",
    "logout_confirm": "هل أنت متأكد من تسجيل الخروج؟",
    "logout_button": "تسجيل الخروج",
    "logout_cancel": "إلغاء",
    "logout_success": "تم تسجيل الخروج بنجاح",
    "forgot_password": "نسيت كلمة المرور؟",
    "forgot_password_title": "استعادة كلمة المرور",
    "forgot_password_subtitle": "أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور",
    "forgot_password_button": "إرسال رابط الاستعادة",
    "forgot_password_success": "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح.",
    "forgot_password_back": "العودة لتسجيل الدخول"
  },
  "register": {
    "title": "أنشئ حسابك",
    "subtitle": "سجّل ببريدك الإلكتروني للبدء",
    "name_hint": "الاسم الكامل",
    "email_hint": "البريد الإلكتروني",
    "password_hint": "كلمة المرور",
    "confirm_password_hint": "تأكيد كلمة المرور",
    "create_button": "إنشاء حساب",
    "already_have_account": "لديك حساب؟",
    "login": "تسجيل الدخول"
  },
  "validations": {
    "name_required": "أدخل اسمك.",
    "email_required": "يرجى إدخال بريدك الإلكتروني",
    "email_invalid": "أدخل بريداً إلكترونياً صحيحاً.",
    "password_required": "أدخل كلمة المرور.",
    "password_short": "استخدم 6 أحرف على الأقل.",
    "confirm_password_required": "تأكيد كلمة المرور مطلوب",
    "confirm_password_mismatch": "كلمتا المرور غير متطابقتين."
  },
  "auth_errors": {
    "email_already_in_use": "هذا البريد مسجل بالفعل. سجل الدخول.",
    "weak_password": "اختر كلمة مرور أقوى.",
    "invalid_credential": "البريد الإلكتروني أو كلمة المرور غير صحيحة.",
    "network_request_failed": "تحقق من اتصال الإنترنت وحاول مجدداً.",
    "too_many_requests": "محاولات كثيرة. حاول لاحقاً.",
    "operation_not_allowed": "تسجيل الدخول بالبريد غير مفعل بعد.",
    "user_disabled": "تم تعطيل هذا الحساب.",
    "unknown": "حدث خطأ. حاول مجدداً."
  },
  "splash": {
    "subtitle": "نظام تسجيل وتوثيق الحضور الذكي",
    "offline_ready": "جاهز للعمل دون اتصال بالإنترنت"
  }
};
static const Map<String,dynamic> _en_US = {
  "global": {
    "app_name": "Attendance",
    "loading": "Loading...",
    "retry": "Retry",
    "setup_incomplete": "App setup is incomplete. Contact the administrator."
  },
  "login": {
    "title": "Sign in to your account",
    "subtitle": "Use your email and password to continue",
    "email_hint": "Email address",
    "password_hint": "Password",
    "login_button": "Sign in",
    "dont_have_account": "Don't have an account?",
    "create_account": "Create Account",
    "signed_in": "You are signed in",
    "logout": "Sign out",
    "logout_title": "Sign out",
    "logout_confirm": "Are you sure you want to sign out?",
    "logout_button": "Sign out",
    "logout_cancel": "Cancel",
    "logout_success": "Signed out successfully",
    "forgot_password": "Forgot password?",
    "forgot_password_title": "Reset password",
    "forgot_password_subtitle": "Enter your email address to receive a password reset link",
    "forgot_password_button": "Send Reset Link",
    "forgot_password_success": "A password reset link has been sent to your email.",
    "forgot_password_back": "Back to sign in"
  },
  "register": {
    "title": "Create your account",
    "subtitle": "Register with your email to get started",
    "name_hint": "Full name",
    "email_hint": "Email address",
    "password_hint": "Password",
    "confirm_password_hint": "Confirm password",
    "create_button": "Create account",
    "already_have_account": "Already have an account?",
    "login": "Sign in"
  },
  "validations": {
    "name_required": "Enter your name.",
    "email_required": "Please enter your email",
    "email_invalid": "Enter a valid email address.",
    "password_required": "Enter your password.",
    "password_short": "Use at least 6 characters.",
    "confirm_password_required": "Confirm password is required",
    "confirm_password_mismatch": "Passwords do not match."
  },
  "auth_errors": {
    "email_already_in_use": "This email already has an account. Sign in instead.",
    "weak_password": "Choose a stronger password.",
    "invalid_credential": "Email or password is incorrect.",
    "network_request_failed": "Check your internet connection and try again.",
    "too_many_requests": "Too many attempts. Please try again later.",
    "operation_not_allowed": "Email sign-in is not enabled yet.",
    "user_disabled": "This account has been disabled.",
    "unknown": "Something went wrong. Please try again."
  },
  "splash": {
    "subtitle": "Smart Offline Attendance System",
    "offline_ready": "Offline Ready • Cloud Sync"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar_EG": _ar_EG, "en_US": _en_US};
}
