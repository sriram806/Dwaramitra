// Profile Feature Dependency Injection
// This file registers all profile-related dependencies with proper Clean Architecture

import 'package:http/http.dart' as http;
import '../presentation/bloc/profile_cubit.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';

class ProfileDependencyInjection {
  static ProfileCubit getProfileCubit() {
    // Initialize HTTP client
    final httpClient = http.Client();
    
    // Initialize data sources
    final remoteDataSource = ProfileRemoteDataSourceImpl(client: httpClient);
    final localDataSource = ProfileLocalDataSourceImpl();
    
    // Initialize repository
    final repository = ProfileRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    
    // Return ProfileCubit with real repository
    return ProfileCubit(repository: repository);
  }
}