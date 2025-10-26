part of 'announcement_cubit.dart';

abstract class AnnouncementState {}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;
  
  AnnouncementLoaded(this.announcements);
}

class AnnouncementManagementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;
  final Map<String, dynamic> pagination;
  
  AnnouncementManagementLoaded(this.announcements, this.pagination);
}

class AnnouncementCreated extends AnnouncementState {
  final AnnouncementModel announcement;
  
  AnnouncementCreated(this.announcement);
}

class AnnouncementUpdated extends AnnouncementState {
  final AnnouncementModel announcement;
  
  AnnouncementUpdated(this.announcement);
}

class AnnouncementDeleted extends AnnouncementState {}

class AnnouncementError extends AnnouncementState {
  final String message;
  
  AnnouncementError(this.message);
}