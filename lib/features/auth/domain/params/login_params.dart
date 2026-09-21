import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  const LoginParams({
    this.email = '',
    this.password = '',
    this.phone,
  });

  final String email;
  final String password;

  /// E.164 phone when signing in with phone OTP.
  final String? phone;

  bool get isPhone => phone != null && phone!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      };

  factory LoginParams.fromJson(Map<String, dynamic> json) => LoginParams(
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        phone: json['phone'] as String?,
      );

  @override
  List<Object?> get props => [email, password, phone];
}
