import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Semantics(
      label: 'Prioridade $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  (String, Color) _resolve() => switch (priority) {
    Priority.alta => (AppStrings.priorityHigh, AppColors.priorityHigh),
    Priority.media => (AppStrings.priorityMedium, AppColors.priorityMedium),
    Priority.baixa => (AppStrings.priorityLow, AppColors.priorityLow),
  };
}
