import 'package:flutter_bloc/flutter_bloc.dart';
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
        emit(AuthSuccess(token, role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) {
        emit(AuthInitial()); // Balik ke state awal
    });
  }
}

