import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thriftin App',
      home: BlocProvider(
        create: (_) => AuthBloc(authRepo),
        child: LoginScreen(),
      ),
    );
  }
}