part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthRegisterRequested(
      {required this.name, required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateNameRequested extends AuthEvent {
  final String userId;
  final String newName;

  AuthUpdateNameRequested(this.userId, this.newName);
}
