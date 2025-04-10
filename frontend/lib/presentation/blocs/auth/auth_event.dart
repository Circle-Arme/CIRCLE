abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  RegisterEvent(this.fullName, this.email, this.password);
}

class LogoutEvent extends AuthEvent {}
