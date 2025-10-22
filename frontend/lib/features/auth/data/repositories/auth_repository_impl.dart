import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_repository.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_repository.dart';
import 'package:frontend/features/auth/data/mappers/user_mapper.dart';
import 'package:frontend/core/services/sp_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteRepository _remoteRepository;
  final AuthLocalRepository _localRepository;
  final SpService _spService;

  AuthRepositoryImpl(
    this._remoteRepository,
    this._localRepository,
    this._spService,
  );

  @override
  Future<UserEntity> signUp(SignUpCredentials credentials) async {
    try {
      final userModel = await _remoteRepository.signUp(
        name: credentials.name,
        email: credentials.email,
        password: credentials.password,
        gender: credentials.gender,
      );

      // Save user locally
      try {
        await _localRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors (e.g., on web)
      }

      return UserMapper.toEntity(userModel);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> login(AuthCredentials credentials) async {
    try {
      final userModel = await _remoteRepository.login(
        email: credentials.email,
        password: credentials.password,
      );

      // Save user locally
      try {
        await _localRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors (e.g., on web)
      }

      return UserMapper.toEntity(userModel);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Try to get user from remote first
      final userModel = await _remoteRepository.getUserData();
      if (userModel != null) {
        // Update local storage
        try {
          await _localRepository.insertUser(userModel);
        } catch (e) {
          // Ignore local storage errors
        }
        return UserMapper.toEntity(userModel);
      }

      // If remote fails, try local storage
      final localUser = await _localRepository.getUser();
      if (localUser != null) {
        return UserMapper.toEntity(localUser);
      }

      return null;
    } catch (e) {
      // If all fails, try local storage as fallback
      try {
        final localUser = await _localRepository.getUser();
        if (localUser != null) {
          return UserMapper.toEntity(localUser);
        }
      } catch (e) {
        // Ignore local storage errors
      }
      return null;
    }
  }

  @override
  Future<UserEntity> verifyOtp(OtpVerification otpVerification) async {
    try {
      final userModel = await _remoteRepository.verifyOtp(
        otp: otpVerification.otp,
      );

      // Save user locally
      try {
        await _localRepository.insertUser(userModel);
      } catch (e) {
        // Ignore local storage errors
      }

      return UserMapper.toEntity(userModel);
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resendOtp() async {
    try {
      await _remoteRepository.resendOtp();
    } catch (e) {
      throw Exception('Failed to resend OTP: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteRepository.forgotPassword(email: email);
    } catch (e) {
      throw Exception('Failed to send forgot password OTP: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(PasswordReset passwordReset) async {
    try {
      await _remoteRepository.resetPassword(
        email: passwordReset.email,
        otp: passwordReset.otp,
        password: passwordReset.newPassword,
      );
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Logout from remote
      await _remoteRepository.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    } finally {
      // Clear local data
      try {
        await _localRepository.clearUser();
        await _spService.clearToken();
      } catch (e) {
        // Ignore local storage errors
      }
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _spService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}