import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('註冊')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("註冊成功，請登入")),
            );
            Navigator.pop(context); // 註冊後返回登入頁
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '暱稱'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '電子郵件'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(
                    AuthRegisterRequested(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                },
                child: Text('註冊'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
