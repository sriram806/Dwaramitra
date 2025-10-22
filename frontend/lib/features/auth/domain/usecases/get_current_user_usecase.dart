import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<UserEntity?> call() async {
    return await _authRepository.getCurrentUser();
  }
}