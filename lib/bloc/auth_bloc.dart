import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authService.login(event.email, event.password);
        final role = await authService.getRole(token);

        // 🧠 Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        emit(AuthSuccess(token, role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authService.register(event.name, event.email, event.password);
        final role = await authService.getRole(token);

        // 🧠 Simpan token juga saat register
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        emit(AuthSuccess(token, role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      // 🔥 Hapus token saat logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      emit(AuthInitial());
    });
  }
}
