import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
//import 'package:frontend/data/models/user_profile_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await AuthService.login(event.email, event.password);
        emit(AuthAuthenticated(
          userId: result.userId,
          token: result.token,
          userType: result.userType,
          isNewUser: result.isNewUser,
          userProfile: result.userProfile,
        ));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // بعد تعديل دالة register في AuthService، تُعيد LoggedUser بعد تسجيل الدخول تلقائيًا
        final result = await AuthService.register(
          event.fullName,
          event.email,
          event.password,
        );
        emit(AuthAuthenticated(
          userId: result.userId,
          token: result.token,
          userType: result.userType,
          isNewUser: result.isNewUser,
          userProfile: result.userProfile,
        ));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await AuthService.logout();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
