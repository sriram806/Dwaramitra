import 'dart:convert';

class VehicleLogModel {
  final String id;
  final String? vehicleId;
  final String vehicleNumber;
  final String vehicleType;
  final String ownerName;
  final String ownerType;
  final String? universityId;
  final String? department;
  final String? contactNumber;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String? entryBy;
  final GuardInfo? entryGuard;
  final GuardInfo? exitGuard;
  final String entryGate;
  final String? exitGate;
  final String entryShift;
  final String? purpose;
  final String status; // 'parked' or 'exited'
  final bool isPreRegistered;
  final DateTime? expectedExitTime;
  final String? notes;
  final bool isSuspicious;
  final Map<String, dynamic>? securityCheck;
  final VehicleInfo? vehicle;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleLogModel({
    required this.id,
    this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.ownerName,
    required this.ownerType,
    this.universityId,
    this.department,
    this.contactNumber,
    required this.entryTime,
    this.exitTime,
    this.entryBy,
    this.entryGuard,
    this.exitGuard,
    required this.entryGate,
    this.exitGate,
    required this.entryShift,
    this.purpose,
    required this.status,
    this.isPreRegistered = false,
    this.expectedExitTime,
    this.notes,
    this.isSuspicious = false,
    this.securityCheck,
    this.vehicle,
    required this.createdAt,
    required this.updatedAt,
  });

  VehicleLogModel copyWith({
    String? id,
    String? vehicleId,
    String? vehicleNumber,
    String? vehicleType,
    String? ownerName,
    String? ownerType,
    String? universityId,
    String? department,
    String? contactNumber,
    DateTime? entryTime,
    DateTime? exitTime,
    String? entryBy,
    GuardInfo? entryGuard,
    GuardInfo? exitGuard,
    String? entryGate,
    String? exitGate,
    String? entryShift,
    String? purpose,
    String? status,
    bool? isPreRegistered,
    DateTime? expectedExitTime,
    String? notes,
    bool? isSuspicious,
    Map<String, dynamic>? securityCheck,
    VehicleInfo? vehicle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleLogModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      ownerName: ownerName ?? this.ownerName,
      ownerType: ownerType ?? this.ownerType,
      universityId: universityId ?? this.universityId,
      department: department ?? this.department,
      contactNumber: contactNumber ?? this.contactNumber,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      entryBy: entryBy ?? this.entryBy,
      entryGuard: entryGuard ?? this.entryGuard,
      exitGuard: exitGuard ?? this.exitGuard,
      entryGate: entryGate ?? this.entryGate,
      exitGate: exitGate ?? this.exitGate,
      entryShift: entryShift ?? this.entryShift,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      isPreRegistered: isPreRegistered ?? this.isPreRegistered,
      expectedExitTime: expectedExitTime ?? this.expectedExitTime,
      notes: notes ?? this.notes,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      securityCheck: securityCheck ?? this.securityCheck,
      vehicle: vehicle ?? this.vehicle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      if (vehicleId != null) 'vehicle': vehicleId,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'ownerName': ownerName,
      'ownerType': ownerType,
      if (universityId != null) 'universityId': universityId,
      if (department != null) 'department': department,
      if (contactNumber != null) 'contactNumber': contactNumber,
      'entryTime': entryTime.toIso8601String(),
      if (exitTime != null) 'exitTime': exitTime!.toIso8601String(),
      if (entryBy != null) 'entryBy': entryBy,
      if (entryGuard != null) 'entryGuard': entryGuard!.toMap(),
      if (exitGuard != null) 'exitGuard': exitGuard!.toMap(),
      'entryGate': entryGate,
      if (exitGate != null) 'exitGate': exitGate,
      'entryShift': entryShift,
      if (purpose != null) 'purpose': purpose,
      'status': status,
      'isPreRegistered': isPreRegistered,
      if (expectedExitTime != null) 'expectedExitTime': expectedExitTime!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'isSuspicious': isSuspicious,
      if (securityCheck != null) 'securityCheck': securityCheck,
      if (vehicle != null) 'vehicle': vehicle!.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VehicleLogModel.fromMap(Map<String, dynamic> map) {
    return VehicleLogModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      vehicleId: map['vehicle'] is String ? map['vehicle'] : map['vehicle']?['_id']?.toString(),
      vehicleNumber: map['vehicleNumber']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      ownerType: map['ownerType']?.toString() ?? 'student',
      universityId: map['universityId']?.toString(),
      department: map['department']?.toString(),
      contactNumber: map['contactNumber']?.toString(),
      entryTime: DateTime.parse(map['entryTime'] ?? DateTime.now().toIso8601String()),
      exitTime: map['exitTime'] != null ? DateTime.parse(map['exitTime']) : null,
      entryBy: map['entryBy']?.toString(),
      entryGuard: map['entryGuard'] != null ? GuardInfo.fromMap(map['entryGuard']) : null,
      exitGuard: map['exitGuard'] != null ? GuardInfo.fromMap(map['exitGuard']) : null,
      entryGate: map['entryGate']?.toString() ?? 'GATE 1',
      exitGate: map['exitGate']?.toString(),
      entryShift: map['entryShift']?.toString() ?? 'Day Shift',
      purpose: map['purpose']?.toString(),
      status: map['status']?.toString() ?? 'parked',
      isPreRegistered: map['isPreRegistered'] ?? false,
      expectedExitTime: map['expectedExitTime'] != null ? DateTime.parse(map['expectedExitTime']) : null,
      notes: map['notes']?.toString(),
      isSuspicious: map['isSuspicious'] ?? false,
      securityCheck: map['securityCheck'] != null ? Map<String, dynamic>.from(map['securityCheck']) : null,
      vehicle: map['vehicle'] is Map ? VehicleInfo.fromMap(Map<String, dynamic>.from(map['vehicle'])) : null,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory VehicleLogModel.fromJson(String source) =>
      VehicleLogModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VehicleLogModel(id: $id, vehicleNumber: $vehicleNumber, status: $status, entryTime: $entryTime)';
  }

  // Utility getters
  bool get isParked => status == 'parked';
  bool get hasExited => status == 'exited';
  
  Duration get parkingDuration {
    final endTime = exitTime ?? DateTime.now();
    return endTime.difference(entryTime);
  }

  String get formattedDuration {
    final duration = parkingDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class GuardInfo {
  final String id;
  final String name;

  GuardInfo({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory GuardInfo.fromMap(Map<String, dynamic> map) {
    return GuardInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

class VehicleInfo {
  final String vehicleNumber;
  final String vehicleType;
  final String ownerName;

  VehicleInfo({
    required this.vehicleNumber,
    required this.vehicleType,
    required this.ownerName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'ownerName': ownerName,
    };
  }

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      ownerName: map['ownerName'] ?? '',
    );
  }
}

class UserInfo {
  final String name;
  final String email;

  UserInfo({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}