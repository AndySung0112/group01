import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = BlocProvider.of<AuthBloc>(context).state is AuthAuthenticated
        ? (BlocProvider.of<AuthBloc>(context).state as AuthAuthenticated).userId
        : ''; // 獲取當前用戶ID
    return Scaffold(
      appBar: AppBar(title: Text('修改名稱')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '新名稱'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = _nameController.text;
                if (userId.isNotEmpty) {
                  BlocProvider.of<AuthBloc>(context).add(
                    AuthUpdateNameRequested(userId, newName),
                  );
                }
              },
              child: Text('更新名稱'),
            ),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthNameUpdated) {
                  //顯示更新成功
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('名稱更新成功!'),
                    backgroundColor: Colors.green,
                  ));
                } else if (state is AuthError) {
                  //錯誤
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
