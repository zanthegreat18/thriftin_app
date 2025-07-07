import 'package:bloc/bloc.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/repositories/auth_repository.dart';
import 'package:thriftin_app/bloc/auth_event.dart';



class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await repository.login(event.email, event.password);
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await repository.register(event.name, event.email, event.password);
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
