class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.role = 'student',
  });

  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String role;

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
}
