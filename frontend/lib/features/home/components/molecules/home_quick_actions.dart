import 'package:flutter/material.dart';
import '../atoms/home_card.dart';
import '../atoms/home_section_header.dart';

class HomeQuickActions extends StatelessWidget {
  final List<HomeActionItem> actions;

  const HomeQuickActions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(
            title: 'Quick Actions',
            icon: Icons.flash_on,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: actions.map((action) => _ActionButton(action: action)).toList(),
          ),
        ],
      ),
    );
  }
}

class HomeActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  HomeActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _ActionButton extends StatelessWidget {
  final HomeActionItem action;

  const _ActionButton({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
