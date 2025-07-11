import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/bloc/auth_event.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/screens/login_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Welcome ${state.role}'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  )
                ],
              ),
              body: Center(
                child: Text(
                  state.role == 'admin'
                      ? 'Ini Dashboard Admin'
                      : 'Ini Homepage User',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            );
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
