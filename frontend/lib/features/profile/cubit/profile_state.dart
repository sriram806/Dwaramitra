part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserModel user;
  ProfileLoaded(this.user);
}

final class ProfileRefreshing extends ProfileState {
  final UserModel user;
  ProfileRefreshing(this.user);
}

final class ProfileUpdating extends ProfileState {
  final UserModel user;
  ProfileUpdating(this.user);
}

final class ProfileUpdated extends ProfileState {
  final UserModel user;
  ProfileUpdated(this.user);
}

final class ProfilePictureUpdated extends ProfileState {
  final UserModel user;
  ProfilePictureUpdated(this.user);
}

final class ProfilePasswordChanging extends ProfileState {}

final class ProfilePasswordChanged extends ProfileState {}

final class ProfileDeleting extends ProfileState {}

final class ProfileDeleted extends ProfileState {}

final class ProfileSyncing extends ProfileState {
  final UserModel user;
  ProfileSyncing(this.user);
}

final class ProfileSynced extends ProfileState {
  final UserModel user;
  ProfileSynced(this.user);
}

final class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}