import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/screens/login_page.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'package:thriftin_app/screens/admin_dashboard_page.dart';
import 'package:thriftin_app/screens/user_dashboard_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => LoginPage(),
          '/admin-dashboard': (_) => AdminDashboardPage(),
          '/user-dashboard': (_) => UserDashboardPage(),
        },
      ),
    );
  }
}