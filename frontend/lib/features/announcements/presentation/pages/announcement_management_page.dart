import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/custom_toast.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/features/announcements/presentation/cubit/announcement_cubit.dart';

class AnnouncementManagementPage extends StatefulWidget {
  const AnnouncementManagementPage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AnnouncementManagementPage(),
      );

  @override
  State<AnnouncementManagementPage> createState() => _AnnouncementManagementPageState();
}

class _AnnouncementManagementPageState extends State<AnnouncementManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAnnouncements() {
    context.read<AnnouncementCubit>().getAllAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Announcements',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppPallete.whiteColor,
          ),
        ),
        backgroundColor: AppPallete.gradient2,
        foregroundColor: AppPallete.whiteColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.whiteColor,
          unselectedLabelColor: AppPallete.whiteColor.withOpacity(0.7),
          indicatorColor: AppPallete.whiteColor,
          tabs: const [
            Tab(text: 'All Announcements'),
            Tab(text: 'Create New'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AnnouncementListTab(),
          _CreateAnnouncementTab(),
        ],
      ),
    );
  }
}

class _AnnouncementListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnnouncementCubit, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementError) {
          CustomToast.showError(
            context: context,
            message: state.message,
          );
        } else if (state is AnnouncementDeleted) {
          CustomToast.showSuccess(
            context: context,
            message: 'Announcement deleted successfully',
          );
        }
      },
      builder: (context, state) {
        if (state is AnnouncementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AnnouncementManagementLoaded) {
          if (state.announcements.isEmpty) {
            return const Center(
              child: Text(
                'No announcements found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AnnouncementCubit>().getAllAnnouncements();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.announcements.length,
              itemBuilder: (context, index) {
                final announcement = state.announcements[index];
                return _AnnouncementManagementCard(
                  announcement: announcement,
                  onEdit: () => _showEditDialog(context, announcement),
                  onDelete: () => _showDeleteConfirmation(context, announcement),
                  onToggleActive: () => _toggleActiveStatus(context, announcement),
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
    );
  }

  void _showEditDialog(BuildContext context, AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => _EditAnnouncementDialog(announcement: announcement),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AnnouncementCubit>().deleteAnnouncement(announcement.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleActiveStatus(BuildContext context, AnnouncementModel announcement) {
    context.read<AnnouncementCubit>().updateAnnouncement(
          id: announcement.id,
          isActive: !announcement.isActive,
        );
  }
}

class _CreateAnnouncementTab extends StatefulWidget {
  @override
  State<_CreateAnnouncementTab> createState() => _CreateAnnouncementTabState();
}

class _CreateAnnouncementTabState extends State<_CreateAnnouncementTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  String _selectedPriority = 'medium';
  List<String> _selectedAudience = ['all'];
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 7));

  final List<String> _types = ['info', 'warning', 'emergency', 'maintenance'];
  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];
  final List<String> _audiences = ['all', 'students', 'faculty', 'staff', 'guards', 'visitors'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnnouncementCubit, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementCreated) {
          CustomToast.showSuccess(
            context: context,
            message: 'Announcement created successfully',
          );
          _resetForm();
        } else if (state is AnnouncementError) {
          CustomToast.showError(
            context: context,
            message: state.message,
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: _priorities.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Target Audience:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                children: _audiences.map((audience) {
                  return CheckboxListTile(
                    title: Text(audience.toUpperCase()),
                    value: _selectedAudience.contains(audience),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedAudience.add(audience);
                        } else {
                          _selectedAudience.remove(audience);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                title: const Text('Expires At'),
                subtitle: Text(_expiresAt.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectExpiryDate,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createAnnouncement,
                  child: const Text('Create Announcement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectExpiryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        _expiresAt = selectedDate;
      });
    }
  }

  void _createAnnouncement() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAudience.isEmpty) {
        CustomToast.showError(
          context: context,
          message: 'Please select at least one target audience',
        );
        return;
      }

      context.read<AnnouncementCubit>().createAnnouncement(
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _selectedType,
            priority: _selectedPriority,
            targetAudience: _selectedAudience,
            expiresAt: _expiresAt,
          );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _selectedType = 'info';
      _selectedPriority = 'medium';
      _selectedAudience = ['all'];
      _expiresAt = DateTime.now().add(const Duration(days: 7));
    });
  }
}

class _AnnouncementManagementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _AnnouncementManagementCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: announcement.isActive,
                  onChanged: (_) => onToggleActive(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              announcement.message,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _getTypeChip(announcement.type),
                const SizedBox(width: AppSpacing.sm),
                _getPriorityChip(announcement.priority),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expires: ${announcement.formattedExpiresAt}',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _EditAnnouncementDialog extends StatefulWidget {
  final AnnouncementModel announcement;

  const _EditAnnouncementDialog({required this.announcement});

  @override
  State<_EditAnnouncementDialog> createState() => _EditAnnouncementDialogState();
}

class _EditAnnouncementDialogState extends State<_EditAnnouncementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late String _selectedType;
  late String _selectedPriority;
  late List<String> _selectedAudience;
  late DateTime _expiresAt;
  late bool _isActive;

  final List<String> _types = ['info', 'warning', 'emergency', 'maintenance'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _messageController = TextEditingController(text: widget.announcement.message);
    _selectedType = widget.announcement.type;
    _selectedPriority = widget.announcement.priority;
    _selectedAudience = List.from(widget.announcement.targetAudience);
    _expiresAt = widget.announcement.expiresAt;
    _isActive = widget.announcement.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnnouncementCubit, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementUpdated) {
          Navigator.pop(context);
          CustomToast.showSuccess(
            context: context,
            message: 'Announcement updated successfully',
          );
        } else if (state is AnnouncementError) {
          CustomToast.showError(
            context: context,
            message: state.message,
          );
        }
      },
      child: AlertDialog(
        title: const Text('Edit Announcement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _updateAnnouncement,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateAnnouncement() {
    context.read<AnnouncementCubit>().updateAnnouncement(
          id: widget.announcement.id,
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          type: _selectedType,
          priority: _selectedPriority,
          targetAudience: _selectedAudience,
          expiresAt: _expiresAt,
          isActive: _isActive,
        );
  }
}