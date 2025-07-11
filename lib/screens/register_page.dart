import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/bloc/auth_event.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/screens/home_page.dart';
import 'package:thriftin_app/screens/login_page.dart';

class RegisterPage extends StatelessWidget {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color:  Color.fromARGB(255, 94, 4, 59),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 60),
                    Text("Buat Akun,", style: TextStyle(color: Colors.white, fontSize: 20)),
                    Text("Let's get started Thrifterzz!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 60),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInput(nameC, "Full Name"),
                    const SizedBox(height: 16),
                    _buildInput(emailC, "Email"),
                    const SizedBox(height: 16),
                    _buildInput(passC, "Password", isPassword: true),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              RegisterRequested(nameC.text, emailC.text, passC.text),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 235, 218, 40),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Register", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      ),
                      child: const Text("Sudah punya akun? Login", style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hintText, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF0F1F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}