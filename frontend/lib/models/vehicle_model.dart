import 'dart:convert';

class VehicleModel {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String ownerName;
  final String ownerRole;
  final String? universityId;
  final String? department;
  final String contactNumber;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String gateName;
  final String status; 
  final int duration;
  final String? purpose;
  final String? verifiedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.ownerName,
    required this.ownerRole,
    this.universityId,
    this.department,
    required this.contactNumber,
    required this.entryTime,
    this.exitTime,
    required this.gateName,
    required this.status,
    required this.duration,
    this.purpose,
    this.verifiedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  VehicleModel copyWith({
    String? id,
    String? vehicleNumber,
    String? vehicleType,
    String? ownerName,
    String? ownerRole,
    String? universityId,
    String? department,
    String? contactNumber,
    DateTime? entryTime,
    DateTime? exitTime,
    String? gateName,
    String? status,
    int? duration,
    String? purpose,
    String? verifiedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      ownerName: ownerName ?? this.ownerName,
      ownerRole: ownerRole ?? this.ownerRole,
      universityId: universityId ?? this.universityId,
      department: department ?? this.department,
      contactNumber: contactNumber ?? this.contactNumber,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      gateName: gateName ?? this.gateName,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      purpose: purpose ?? this.purpose,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'ownerName': ownerName,
      'ownerRole': ownerRole,
      'universityId': universityId,
      'department': department,
      'contactNumber': contactNumber,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'gateName': gateName,
      'status': status,
      'duration': duration,
      'purpose': purpose,
      'verifiedBy': verifiedBy,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['_id'] ?? map['id'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerRole: map['ownerRole'] ?? 'student',
      universityId: map['universityId'],
      department: map['department'],
      contactNumber: map['contactNumber'] ?? '',
      entryTime: DateTime.parse(map['entryTime'] ?? DateTime.now().toIso8601String()),
      exitTime: map['exitTime'] != null ? DateTime.parse(map['exitTime']) : null,
      gateName: map['gateName'] ?? '',
      status: map['status'] ?? 'inside',
      duration: map['duration']?.toInt() ?? 0,
      purpose: map['purpose'],
      verifiedBy: map['verifiedBy'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory VehicleModel.fromJson(String source) =>
      VehicleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VehicleModel(id: $id, vehicleNumber: $vehicleNumber, vehicleType: $vehicleType, ownerName: $ownerName, status: $status)';
  }

  @override
  bool operator ==(covariant VehicleModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.vehicleNumber == vehicleNumber &&
        other.vehicleType == vehicleType &&
        other.ownerName == ownerName &&
        other.ownerRole == ownerRole &&
        other.universityId == universityId &&
        other.department == department &&
        other.contactNumber == contactNumber &&
        other.entryTime == entryTime &&
        other.exitTime == exitTime &&
        other.gateName == gateName &&
        other.status == status &&
        other.duration == duration &&
        other.purpose == purpose &&
        other.verifiedBy == verifiedBy &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        vehicleNumber.hashCode ^
        vehicleType.hashCode ^
        ownerName.hashCode ^
        ownerRole.hashCode ^
        universityId.hashCode ^
        department.hashCode ^
        contactNumber.hashCode ^
        entryTime.hashCode ^
        exitTime.hashCode ^
        gateName.hashCode ^
        status.hashCode ^
        duration.hashCode ^
        purpose.hashCode ^
        verifiedBy.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  // Utility getters
  String get formattedDuration {
    if (duration == 0) return '0 mins';

    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  bool get isInside => status == 'inside';
  bool get hasExited => status == 'exited';
  
  // Backward compatibility
  bool get isParked => status == 'inside';
  String get plateNumber => vehicleNumber; // For backward compatibility
}
