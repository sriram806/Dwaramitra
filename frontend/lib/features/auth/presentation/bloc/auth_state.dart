part of "auth_cubit.dart";

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignUp extends AuthState {
  final UserModel user;
  AuthSignUp(this.user);
}

final class AuthOtpVerified extends AuthState {
  final UserModel user;
  AuthOtpVerified(this.user);
}

final class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);
}

final class AuthPasswordResetOtpSent extends AuthState {}

final class AuthPasswordReset extends AuthState {}

final class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}
