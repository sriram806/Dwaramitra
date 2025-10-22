import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';

class LogoutService {
  static void showAdvancedLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'What happens when you logout:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• You will be signed out of your account',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• All local data will be cleared',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• You will need to login again',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Any unsaved changes will be lost',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _performLogout(dialogContext, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _performLogout(BuildContext dialogContext, BuildContext mainContext) {
    // Close the dialog
    Navigator.of(dialogContext).pop();
    
    // Show loading indicator
    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Signing you out...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Perform logout after a short delay for better UX
    Future.delayed(const Duration(milliseconds: 1500), () async {
      // Close loading dialog
      Navigator.of(mainContext).pop();
      
      // Perform actual logout
      mainContext.read<AuthCubit>().logout();
      
      // Clear all navigation stack and navigate to login
      Navigator.of(mainContext).pushNamedAndRemoveUntil(
        '/', 
        (route) => false,
      );
      
      // Show success message after navigation
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(mainContext).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Successfully logged out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    });
  }

  /// Quick logout without confirmation dialog - for emergency situations
  static void quickLogout(BuildContext context) {
    context.read<AuthCubit>().logout();
  }

  /// Logout with custom callback
  static void logoutWithCallback(BuildContext context, VoidCallback? onLogoutComplete) {
    showAdvancedLogoutDialog(context);
    if (onLogoutComplete != null) {
      Future.delayed(const Duration(milliseconds: 2000), onLogoutComplete);
    }
  }
}
