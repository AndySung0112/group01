import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginButton(
      {required this.emailController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        BlocProvider.of<AuthBloc>(context).add(
          AuthLoginRequested(emailController.text, passwordController.text),
        );
      },
      child: Text('登入'),
    );
  }
}
