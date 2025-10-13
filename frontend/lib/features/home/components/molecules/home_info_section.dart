import 'package:flutter/material.dart';
import '../atoms/home_card.dart';
import '../atoms/home_section_header.dart';

class HomeInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color? color;

  const HomeInfoSection({
    Key? key,
    required this.title,
    required this.children,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: title,
            icon: icon,
            color: color,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
