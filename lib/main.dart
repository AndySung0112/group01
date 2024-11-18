import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/auth/auth_bloc.dart';
import 'package:group_01/presentation/routes/auth/auth_route.dart';
import 'package:group_01/presentation/routes/chat/chat_route.dart';
import 'package:group_01/presentation/routes/home/home_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FirebaseAuth.instance)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue[100],
          scaffoldBackgroundColor: Colors.blue[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[100],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // 設置文字顏色
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        title: '群組管理App',
        initialRoute: '/',
        routes: {
          '/': (context) => HomeRoute(),
          '/login': (context) => AuthRoute(),
          '/home': (context) => HomeRoute(),
          '/chat': (context) => ChatRoute(),
        },
      ),
    );
  }
}
