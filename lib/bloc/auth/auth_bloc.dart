import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(this._firebaseAuth) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUpdateNameRequested>(_onUpdateNameRequested);
  }
  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userCredential.user!.uid));
    } catch (e) {
      emit(AuthError("登入失敗: ${e.toString()}"));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      //創建用戶
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      //儲存用戶名等
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': event.name,
        'email': event.email,
      });
      emit(AuthRegistered(userCredential.user!.uid));
    } catch (e) {
      emit(AuthError("註冊失敗: ${e.toString()}"));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError("登出失敗: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateNameRequested(
      AuthUpdateNameRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      //更新暱稱
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .update({
        'name': event.newName,
      });
      emit(AuthNameUpdated());
    } catch (e) {
      emit(AuthError("更新名稱失敗: ${e.toString()}"));
    }
  }
}
