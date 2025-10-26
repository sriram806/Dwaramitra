class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'emergency', 'maintenance'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final List<String> targetAudience;
  final bool isActive;
  final String createdBy;
  final DateTime expiresAt;
  final List<Map<String, dynamic>> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.targetAudience,
    required this.isActive,
    required this.createdBy,
    required this.expiresAt,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
  });

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    List<String>? targetAudience,
    bool? isActive,
    String? createdBy,
    DateTime? expiresAt,
    List<Map<String, dynamic>>? readBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetAudience: targetAudience ?? this.targetAudience,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      expiresAt: expiresAt ?? this.expiresAt,
      readBy: readBy ?? this.readBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'targetAudience': targetAudience,
      'isActive': isActive,
      'createdBy': createdBy,
      'expiresAt': expiresAt.toIso8601String(),
      'readBy': readBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      priority: map['priority']?.toString() ?? 'medium',
      targetAudience: List<String>.from(map['targetAudience'] ?? ['all']),
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy']?.toString() ?? '',
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      readBy: List<Map<String, dynamic>>.from(map['readBy'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, type: $type, priority: $priority, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnnouncementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper getters
  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedExpiresAt {
    return '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}';
  }

  String get typeDisplayName {
    switch (type) {
      case 'info':
        return 'Information';
      case 'warning':
        return 'Warning';
      case 'emergency':
        return 'Emergency';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Information';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  bool isReadBy(String userId) {
    return readBy.any((item) => item['user'].toString() == userId);
  }
}