import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';
import 'package:group_01/bloc/group/group_bloc.dart';
import 'package:group_01/presentation/routes/home/widgets/home_content.dart';

class HomeRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        //用戶以登出
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('首頁'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(AuthLogoutRequested());
                },
              ),
            ],
          ),
          body: BlocProvider(
            create: (_) => GroupBloc()..add(GroupLoadRequested()),
            child: HomeContent(),
          )),
    );
  }
}
