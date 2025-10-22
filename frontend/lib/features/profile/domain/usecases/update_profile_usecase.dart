import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? shift,
    Map<String, String>? avatar,
  }) async {
    return await repository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      universityId: universityId,
      department: department,
      designation: designation,
      shift: shift,
      avatar: avatar,
    );
  }
}