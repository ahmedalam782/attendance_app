import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    this.email = '',
    this.password = '',
    this.phone,
  });

  final String name;
  final String email;
  final String password;

  /// E.164 phone when registering with phone OTP.
  final String? phone;

  bool get isPhone => phone != null && phone!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      };

  factory RegisterParams.fromJson(Map<String, dynamic> json) => RegisterParams(
        name: json['name'] as String,
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        phone: json['phone'] as String?,
      );

  @override
  List<Object?> get props => [name, email, password, phone];
}
