import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/models/user_model.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      gender: model.gender,
      profilePicture: model.avatar?.url,
      role: model.role,
      isVerified: model.isAccountVerified,
      isActive: true,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static UserModel toModel(UserEntity entity, String token) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      gender: entity.gender,
      role: entity.role,
      isAccountVerified: entity.isVerified,
      designation: 'Student', // Default designation
      token: token,
      avatar: entity.profilePicture != null 
          ? Avatar(url: entity.profilePicture)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}