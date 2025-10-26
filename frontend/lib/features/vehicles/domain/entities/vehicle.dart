class Vehicle {
  final String? id;
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

  const Vehicle({
    this.id,
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

  Vehicle copyWith({
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
    return Vehicle(
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

  @override
  bool operator ==(covariant Vehicle other) {
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

  @override
  String toString() {
    return 'Vehicle(id: $id, vehicleNumber: $vehicleNumber, vehicleType: $vehicleType, ownerName: $ownerName, status: $status)';
  }
}