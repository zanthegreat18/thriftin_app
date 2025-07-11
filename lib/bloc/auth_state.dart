abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final String role;

  AuthSuccess(this.token, this.role);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
