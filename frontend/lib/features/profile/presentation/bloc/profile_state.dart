part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  ProfileLoaded(this.profile);
}

final class ProfileRefreshing extends ProfileState {
  final ProfileEntity profile;
  ProfileRefreshing(this.profile);
}

final class ProfileUpdating extends ProfileState {
  final ProfileEntity profile;
  ProfileUpdating(this.profile);
}

final class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;
  ProfileUpdated(this.profile);
}

final class ProfilePictureUpdated extends ProfileState {
  final ProfileEntity profile;
  ProfilePictureUpdated(this.profile);
}

final class ProfilePasswordChanging extends ProfileState {}

final class ProfilePasswordChanged extends ProfileState {}

final class ProfileDeleting extends ProfileState {}

final class ProfileDeleted extends ProfileState {}

final class ProfileSyncing extends ProfileState {
  final ProfileEntity profile;
  ProfileSyncing(this.profile);
}

final class ProfileSynced extends ProfileState {
  final ProfileEntity profile;
  ProfileSynced(this.profile);
}

final class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
