import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/features/announcements/data/repositories/announcement_repository.dart';

part 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  // Get active announcements for current user
  Future<void> getActiveAnnouncements() async {
    try {
      emit(AnnouncementLoading());
      
      final result = await _repository.getActiveAnnouncements();
      
      if (result['success']) {
        final announcements = result['announcements'] as List<AnnouncementModel>;
        emit(AnnouncementLoaded(announcements));
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to load announcements: $e'));
    }
  }

  // Mark announcement as read
  Future<void> markAsRead(String announcementId) async {
    try {
      final result = await _repository.markAnnouncementAsRead(announcementId);
      
      if (result['success']) {
        // Refresh announcements after marking as read
        await getActiveAnnouncements();
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to mark announcement as read: $e'));
    }
  }

  // Create new announcement (Admin only)
  Future<void> createAnnouncement({
    required String title,
    required String message,
    String type = 'info',
    String priority = 'medium',
    List<String>? targetAudience,
    DateTime? expiresAt,
  }) async {
    try {
      emit(AnnouncementLoading());
      
      final result = await _repository.createAnnouncement(
        title: title,
        message: message,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        expiresAt: expiresAt,
      );
      
      if (result['success']) {
        final announcement = result['announcement'] as AnnouncementModel;
        emit(AnnouncementCreated(announcement));
        // Refresh announcements list
        await getAllAnnouncements();
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to create announcement: $e'));
    }
  }

  // Get all announcements (Admin only)
  Future<void> getAllAnnouncements({
    int page = 1,
    int limit = 10,
    bool? isActive,
  }) async {
    try {
      emit(AnnouncementLoading());
      
      final result = await _repository.getAllAnnouncements(
        page: page,
        limit: limit,
        isActive: isActive,
      );
      
      if (result['success']) {
        final announcements = result['announcements'] as List<AnnouncementModel>;
        final pagination = result['pagination'];
        emit(AnnouncementManagementLoaded(announcements, pagination));
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to load announcements: $e'));
    }
  }

  // Update announcement (Admin only)
  Future<void> updateAnnouncement({
    required String id,
    String? title,
    String? message,
    String? type,
    String? priority,
    List<String>? targetAudience,
    DateTime? expiresAt,
    bool? isActive,
  }) async {
    try {
      emit(AnnouncementLoading());
      
      final result = await _repository.updateAnnouncement(
        id: id,
        title: title,
        message: message,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        expiresAt: expiresAt,
        isActive: isActive,
      );
      
      if (result['success']) {
        final announcement = result['announcement'] as AnnouncementModel;
        emit(AnnouncementUpdated(announcement));
        // Refresh announcements list
        await getAllAnnouncements();
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to update announcement: $e'));
    }
  }

  // Delete announcement (Admin only)
  Future<void> deleteAnnouncement(String id) async {
    try {
      emit(AnnouncementLoading());
      
      final result = await _repository.deleteAnnouncement(id);
      
      if (result['success']) {
        emit(AnnouncementDeleted());
        // Refresh announcements list
        await getAllAnnouncements();
      } else {
        emit(AnnouncementError(result['message']));
      }
    } catch (e) {
      emit(AnnouncementError('Failed to delete announcement: $e'));
    }
  }

  void clearError() {
    if (state is AnnouncementError) {
      emit(AnnouncementInitial());
    }
  }
}