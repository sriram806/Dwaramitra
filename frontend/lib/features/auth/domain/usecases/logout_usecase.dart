import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<void> call() async {
    return await _authRepository.logout();
  }
}