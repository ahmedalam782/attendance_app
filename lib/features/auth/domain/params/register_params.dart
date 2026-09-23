import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.phone,
    this.email = '',
    this.password = '',
  });

  final String name;

  /// E.164 phone number, e.g. +201012345678.
  final String phone;

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      };

  factory RegisterParams.fromJson(Map<String, dynamic> json) => RegisterParams(
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  @override
  List<Object?> get props => [name, phone, email, password];
}
