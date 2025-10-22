import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call(String password) async {
    return await repository.deleteAccount(password);
  }
}