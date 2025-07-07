
abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthRegisterRequested(this.name, this.email, this.password);
}
