// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String token;
  final bool isAccountVerified;
  final String? phone;
  final String? gender;
  final String? universityId;
  final String? department;
  final String designation;
  final String role;
  final String? shift; // For guards only: 'Day Shift' or 'Night Shift'
  final Avatar? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
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

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    bool? isAccountVerified,
    String? phone,
    String? gender,
    String? universityId,
    String? department,
    String? designation,
    String? role,
    String? shift,
    Avatar? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'email': email,
      'name': name,
      'token': token,
      'isAccountVerified': isAccountVerified,
      'phone': phone,
      'gender': gender,
      'universityId': universityId,
      'department': department,
      'designation': designation,
      'role': role,
      'shift': shift,
      'avatar': avatar?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      token: map['token'] ?? '',
      isAccountVerified: map['isAccountVerified'] ?? false,
      phone: map['phone'],
      gender: map['gender'],
      universityId: map['universityId'],
      department: map['department'],
      designation: map['designation'] ?? 'Student',
      role: map['role'] ?? 'user',
      shift: map['shift'],
      avatar: map['avatar'] != null ? Avatar.fromMap(map['avatar']) : null,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, token: $token, isAccountVerified: $isAccountVerified, phone: $phone, gender: $gender, universityId: $universityId, department: $department, designation: $designation, role: $role, shift: $shift, avatar: $avatar, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.name == name &&
        other.token == token &&
        other.isAccountVerified == isAccountVerified &&
        other.phone == phone &&
        other.gender == gender &&
        other.universityId == universityId &&
        other.department == department &&
        other.designation == designation &&
        other.role == role &&
        other.shift == shift &&
        other.avatar == avatar &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        token.hashCode ^
        isAccountVerified.hashCode ^
        phone.hashCode ^
        gender.hashCode ^
        universityId.hashCode ^
        department.hashCode ^
        designation.hashCode ^
        role.hashCode ^
        shift.hashCode ^
        avatar.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class Avatar {
  final String? publicId;
  final String? url;

  Avatar({
    this.publicId,
    this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }

  factory Avatar.fromMap(Map<String, dynamic> map) {
    return Avatar(
      publicId: map['public_id'],
      url: map['url'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Avatar &&
        other.publicId == publicId &&
        other.url == url;
  }

  @override
  int get hashCode => publicId.hashCode ^ url.hashCode;

  @override
  String toString() => 'Avatar(publicId: $publicId, url: $url)';
}
