import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/features/announcements/presentation/cubit/announcement_cubit.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AnnouncementsPage(),
      );

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    context.read<AnnouncementCubit>().getActiveAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppPallete.whiteColor,
          ),
        ),
        backgroundColor: AppPallete.gradient2,
        foregroundColor: AppPallete.whiteColor,
      ),
      body: BlocConsumer<AnnouncementCubit, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementError) {
            CustomToast.showError(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnnouncementLoaded) {
            if (state.announcements.isEmpty) {
              return const Center(
                child: Text(
                  'No announcements available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadAnnouncements(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.announcements.length,
                itemBuilder: (context, index) {
                  final announcement = state.announcements[index];
                  return _AnnouncementCard(
                    announcement: announcement,
                    onTap: () => _showAnnouncementDetail(announcement),
                    onMarkAsRead: () => _markAsRead(announcement.id),
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text(
              'Failed to load announcements',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  void _markAsRead(String announcementId) {
    context.read<AnnouncementCubit>().markAsRead(announcementId);
  }

  void _showAnnouncementDetail(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getPriorityIcon(announcement.priority),
            const SizedBox(width: 8),
            Expanded(child: Text(announcement.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _getTypeChip(announcement.type),
                  const SizedBox(width: 8),
                  _getPriorityChip(announcement.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${announcement.formattedCreatedAt}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'Expires: ${announcement.formattedExpiresAt}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!announcement.isReadBy('current_user_id')) // You'd get actual user ID from auth cubit
            ElevatedButton(
              onPressed: () {
                _markAsRead(announcement.id);
                Navigator.pop(context);
              },
              child: const Text('Mark as Read'),
            ),
        ],
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return const Icon(Icons.priority_high, color: Colors.red);
      case 'high':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'medium':
        return const Icon(Icons.info, color: Colors.blue);
      case 'low':
        return const Icon(Icons.info_outline, color: Colors.grey);
      default:
        return const Icon(Icons.info, color: Colors.blue);
    }
  }

  Widget _getTypeChip(String type) {
    Color chipColor;
    switch (type) {
      case 'emergency':
        chipColor = Colors.red;
        break;
      case 'warning':
        chipColor = Colors.orange;
        break;
      case 'maintenance':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        type.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _getPriorityChip(String priority) {
    Color chipColor;
    switch (priority) {
      case 'urgent':
        chipColor = Colors.red;
        break;
      case 'high':
        chipColor = Colors.orange;
        break;
      case 'medium':
        chipColor = Colors.blue;
        break;
      case 'low':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        priority.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getPriorityIcon(announcement.priority),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _getTypeChip(announcement.type),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.message,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    announcement.formattedCreatedAt,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      _getPriorityChip(announcement.priority),
                      const SizedBox(width: 8),
                      if (!announcement.isReadBy('current_user_id')) // You'd get actual user ID from auth cubit
                        TextButton(
                          onPressed: onMarkAsRead,
                          child: const Text('Mark as Read'),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return const Icon(Icons.priority_high, color: Colors.red, size: 20);
      case 'high':
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      case 'medium':
        return const Icon(Icons.info, color: Colors.blue, size: 20);
      case 'low':
        return const Icon(Icons.info_outline, color: Colors.grey, size: 20);
      default:
        return const Icon(Icons.info, color: Colors.blue, size: 20);
    }
  }

  Widget _getTypeChip(String type) {
    Color chipColor;
    switch (type) {
      case 'emergency':
        chipColor = Colors.red;
        break;
      case 'warning':
        chipColor = Colors.orange;
        break;
      case 'maintenance':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        type.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _getPriorityChip(String priority) {
    Color chipColor;
    switch (priority) {
      case 'urgent':
        chipColor = Colors.red;
        break;
      case 'high':
        chipColor = Colors.orange;
        break;
      case 'medium':
        chipColor = Colors.blue;
        break;
      case 'low':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Chip(
      label: Text(
        priority.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}