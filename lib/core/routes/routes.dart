abstract class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String register = '/register';
  static const String programDetails = '/program-details';

  // Admin shell & tabs
  static const String admin = '/admin';
  static const String adminPrograms = 'programs';
  static const String adminScanner = 'scanner';
  static const String adminReports = 'reports';
  static const String adminSettings = 'settings';

  // Student shell & tabs
  static const String student = '/student';
  static const String studentPrograms = 'programs';
  static const String studentQr = 'my-qr';
  static const String studentHistory = 'history';
  static const String studentSettings = 'settings';
}
