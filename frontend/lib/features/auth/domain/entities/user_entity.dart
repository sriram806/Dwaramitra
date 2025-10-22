class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? profilePicture;
  final String role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.profilePicture,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.gender == gender &&
        other.profilePicture == profilePicture &&
        other.role == role &&
        other.isVerified == isVerified &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      phone,
      gender,
      profilePicture,
      role,
      isVerified,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, role: $role, isVerified: $isVerified)';
  }
}