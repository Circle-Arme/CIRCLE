import 'package:frontend/data/models/user_profile_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final int userId;
  final String token;
  final String userType;
  final bool isNewUser;
  final UserProfileModel userProfile;

  AuthAuthenticated({
    required this.userId,
    required this.token,
    required this.userType,
    required this.isNewUser,
    required this.userProfile,
  });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {}
