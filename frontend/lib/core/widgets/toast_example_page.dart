import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/widgets.dart';

class ToastExamplePage extends StatelessWidget {
  const ToastExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Toast Examples'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Top Toast Examples',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Success Toast
            ElevatedButton.icon(
              onPressed: () {
                CustomToast.showSuccess(
                  context: context,
                  message: 'Account created successfully! Welcome to the app.',
                  actionLabel: 'View Profile',
                  onActionPressed: () {
                    print('Profile action pressed');
                  },
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Show Success Toast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Error Toast
            ElevatedButton.icon(
              onPressed: () {
                CustomToast.showError(
                  context: context,
                  message: 'Failed to connect to server. Please check your internet connection and try again.',
                  actionLabel: 'Retry',
                  onActionPressed: () {
                    print('Retry action pressed');
                  },
                );
              },
              icon: const Icon(Icons.error, color: Colors.white),
              label: const Text('Show Error Toast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Warning Toast
            ElevatedButton.icon(
              onPressed: () {
                CustomToast.showWarning(
                  context: context,
                  message: 'Your session will expire in 5 minutes. Please save your work.',
                  actionLabel: 'Extend',
                  onActionPressed: () {
                    print('Extend session pressed');
                  },
                );
              },
              icon: const Icon(Icons.warning, color: Colors.white),
              label: const Text('Show Warning Toast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info Toast
            ElevatedButton.icon(
              onPressed: () {
                CustomToast.showInfo(
                  context: context,
                  message: 'New features are now available! Check out the latest updates.',
                  actionLabel: 'Learn More',
                  onActionPressed: () {
                    print('Learn more pressed');
                  },
                );
              },
              icon: const Icon(Icons.info, color: Colors.white),
              label: const Text('Show Info Toast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Bottom Toast Examples',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Bottom Success Toast
            ElevatedButton.icon(
              onPressed: () {
                BottomToast.showSuccess(
                  context: context,
                  message: 'File uploaded successfully!',
                  actionLabel: 'View',
                  onActionPressed: () {
                    print('View file pressed');
                  },
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Show Bottom Success'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bottom Error Toast
            ElevatedButton.icon(
              onPressed: () {
                BottomToast.showError(
                  context: context,
                  message: 'Login failed. Invalid credentials.',
                  actionLabel: 'Reset',
                  onActionPressed: () {
                    print('Reset password pressed');
                  },
                );
              },
              icon: const Icon(Icons.error, color: Colors.white),
              label: const Text('Show Bottom Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Simple Toast (No Action)
            ElevatedButton.icon(
              onPressed: () {
                BottomToast.showInfo(
                  context: context,
                  message: 'Settings saved successfully.',
                );
              },
              icon: const Icon(Icons.info, color: Colors.white),
              label: const Text('Show Simple Toast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Hide Current Toast
            OutlinedButton.icon(
              onPressed: () {
                CustomToast.hide();
                BottomToast.hide();
              },
              icon: const Icon(Icons.close),
              label: const Text('Hide Current Toast'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}