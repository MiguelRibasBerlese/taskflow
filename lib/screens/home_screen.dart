import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          Semantics(
            label: 'Sair da conta',
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.logout,
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),

      // ── Drawer ──────────────────────────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho do drawer
              DrawerHeader(
                decoration: BoxDecoration(color: cs.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.task_alt_rounded,
                        color: cs.onPrimary, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user != null)
                      Text(
                        user.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Itens de navegação
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text(AppStrings.categories),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.categories);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text(AppStrings.about),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.about);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text(AppStrings.logout,
                    style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          final pending = taskProvider.pending;
          final completed = taskProvider.completed;

          if (pending.isEmpty && completed.isEmpty) {
            return const EmptyState(
              icon: Icons.checklist_rounded,
              title: AppStrings.noTasks,
              subtitle: 'Toque em + para adicionar sua primeira tarefa.',
            );
          }

          // Monta lista plana com headers
          final items = <_ListItem>[];
          if (pending.isNotEmpty) {
            items.add(_ListItem.header(
                'Pendentes (${pending.length})'));
            for (final t in pending) {
              items.add(_ListItem.task(t.id));
            }
          }
          if (completed.isNotEmpty) {
            items.add(_ListItem.header(
                'Concluídas (${completed.length})'));
            for (final t in completed) {
              items.add(_ListItem.task(t.id));
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final item = items[index];
              if (item.isHeader) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                  child: Text(
                    item.label!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final task = taskProvider.getById(item.taskId!);
              if (task == null) return const SizedBox.shrink();

              return TaskCard(
                key: Key(task.id),
                task: task,
                onToggle: () =>
                    context.read<TaskProvider>().toggleComplete(task.id),
                onDelete: () {
                  context.read<TaskProvider>().delete(task.id);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: const Text('Tarefa excluída'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                onTap: () => Navigator.pushNamed(
                  ctx,
                  AppRoutes.taskDetail,
                  arguments: task,
                ),
              );
            },
          );
        },
      ),

      // ── FAB ─────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTask),
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Helper interno para a lista mista (header + task)
class _ListItem {
  final bool isHeader;
  final String? label;
  final String? taskId;

  const _ListItem._({required this.isHeader, this.label, this.taskId});

  factory _ListItem.header(String label) =>
      _ListItem._(isHeader: true, label: label);

  factory _ListItem.task(String id) =>
      _ListItem._(isHeader: false, taskId: id);
}
