import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';
import 'package:group_01/presentation/routes/auth/widget/register_form.dart';
import 'widget/login_form.dart';

class AuthRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('登入')),
        body: BlocProvider(
          create: (_) => AuthBloc(FirebaseAuth.instance),
          child: Column(
            children: [
              Expanded(child: LoginForm()), // 保持登入表單
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                                value: BlocProvider.of<AuthBloc>(context),
                                child: RegisterForm(),
                              )));
                },
                child: Text('沒有帳號？點此註冊'),
              ),
            ],
          ),
        ));
  }
}
