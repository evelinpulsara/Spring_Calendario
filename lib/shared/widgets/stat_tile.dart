import 'package:flutter/material.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';

/// Small card with an icon, a value and a label.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return LunarCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.purple, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
