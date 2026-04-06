import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/priority_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String? _taskId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final task = ModalRoute.of(context)!.settings.arguments as Task;
      _taskId = task.id;
      _initialized = true;
    }
  }

  Future<void> _confirmDelete(BuildContext context, String taskId) async {
    // Captura referências antes do gap assíncrono
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final taskProvider = context.read<TaskProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    taskProvider.delete(taskId);
    messenger.showSnackBar(
      const SnackBar(content: Text('Tarefa excluída')),
    );
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_taskId == null) return const Scaffold(body: SizedBox.shrink());

    // Watch do provider para refletir edições feitas na tela de edição
    final task = context.watch<TaskProvider>().getById(_taskId!);

    // Tarefa foi excluída por outro caminho — volta para home
    if (task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (r) => false);
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final category = context.watch<CategoryProvider>().getById(task.categoryId);
    final fmt = DateFormat(AppConfig.dateFormat);
    final fmtFull = DateFormat(AppConfig.dateTimeFormat);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppStrings.edit,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.editTask,
              arguments: task,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.delete,
            onPressed: () => _confirmDelete(context, task.id),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Status badge ────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? cs.secondaryContainer
                              : cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: task.isCompleted
                                  ? cs.onSecondaryContainer
                                  : cs.onTertiaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.isCompleted
                                  ? AppStrings.taskCompleted
                                  : AppStrings.taskPending,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: task.isCompleted
                                    ? cs.onSecondaryContainer
                                    : cs.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: task.priority),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Título ──────────────────────────────────────────
                  Text(
                    task.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Detalhes ────────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (task.description.isNotEmpty) ...[
                            _DetailRow(
                              icon: Icons.notes_outlined,
                              label: AppStrings.taskDescription,
                              value: task.description,
                            ),
                            const Divider(height: 24),
                          ],
                          if (category != null) ...[
                            _DetailRow(
                              icon: Icons.circle,
                              iconColor: category.color,
                              label: AppStrings.taskCategory,
                              value: category.name,
                            ),
                            const Divider(height: 24),
                          ],
                          if (task.dueDate != null) ...[
                            _DetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: AppStrings.taskDueDate,
                              value: fmt.format(task.dueDate!),
                              valueColor: !task.isCompleted &&
                                      task.dueDate!.isBefore(DateTime.now())
                                  ? cs.error
                                  : null,
                            ),
                            const Divider(height: 24),
                          ],
                          _DetailRow(
                            icon: Icons.access_time_outlined,
                            label: 'Criada em',
                            value: fmtFull.format(task.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Botões ──────────────────────────────────────────
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.editTask,
                        arguments: task,
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(AppStrings.edit),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error),
                      ),
                      onPressed: () => _confirmDelete(context, task.id),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(AppStrings.deleteTask),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor ?? cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? cs.onSurface,
                  fontWeight:
                      valueColor != null ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
