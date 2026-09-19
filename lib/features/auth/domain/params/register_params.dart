import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  factory RegisterParams.fromJson(Map<String, dynamic> json) => RegisterParams(
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
  );

  @override
  List<Object?> get props => [name, email, password];
}
