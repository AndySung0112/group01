part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated(this.userId);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthRegistered extends AuthState {
  final String userId;

  AuthRegistered(this.userId);
}

class AuthLoggedOut extends AuthState {}

class AuthNameUpdated extends AuthState {}
