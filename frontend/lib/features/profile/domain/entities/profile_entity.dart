class ProfileEntity {
  final String id;
  final String email;
  final String name;
  final bool isAccountVerified;
  final String? phone;
  final String? gender;
  final String? universityId;
  final String? department;
  final String designation;
  final String role;
  final String? shift;
  final ProfileAvatarEntity? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.isAccountVerified,
    this.phone,
    this.gender,
    this.universityId,
    this.department,
    required this.designation,
    required this.role,
    this.shift,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAccountVerified,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? role,
    String? shift,
    ProfileAvatarEntity? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAccountVerified: isAccountVerified ?? this.isAccountVerified,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      universityId: universityId ?? this.universityId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProfileAvatarEntity {
  final String url;
  final String? publicId;

  const ProfileAvatarEntity({
    required this.url,
    this.publicId,
  });

  ProfileAvatarEntity copyWith({
    String? url,
    String? publicId,
  }) {
    return ProfileAvatarEntity(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
    );
  }
}