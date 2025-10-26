import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ProfilePageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const ProfilePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.cardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimary),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppPallete.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: actions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppPallete.borderColor,
          ),
        ),
      ),
      body: body,
    );
  }
}
