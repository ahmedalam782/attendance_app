import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  const LoginParams({
    this.email = '',
    this.password = '',
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  factory LoginParams.fromJson(Map<String, dynamic> json) => LoginParams(
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  @override
  List<Object?> get props => [email, password];
}
