import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/empty_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // Cores predefinidas para novas categorias (tokens do projeto)
  static const _presetColors = [
    AppColors.primary,
    AppColors.error,
    AppColors.priorityLow,
    AppColors.priorityMedium,
    AppColors.secondary,
    AppColors.tertiary,
  ];

  Future<void> _showAddDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    var selectedColor = _presetColors[0];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text(AppStrings.addCategory),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Campo nome da categoria',
                  child: TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: AppStrings.categoryName,
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) =>
                        Validators.required(v, label: 'Nome'),
                    autofocus: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cor',
                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _presetColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () =>
                          setStateDialog(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context
                    .read<CategoryProvider>()
                    .add(nameController.text.trim(), selectedColor);
                Navigator.pop(ctx);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content:
            Text('Deseja excluir a categoria "$name"?\n'
                'As tarefas vinculadas perderão a categoria.'),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'Nenhuma categoria',
              subtitle: 'Toque em + para criar uma categoria.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return Dismissible(
                key: Key(cat.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(ctx, cat.name),
                onDismissed: (_) {
                  provider.delete(cat.id);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Categoria "${cat.name}" excluída'),
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: cs.onErrorContainer, size: 28),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor:
                          cat.color.withValues(alpha: 0.15),
                      child: Icon(Icons.circle,
                          color: cat.color, size: 20),
                    ),
                    title: Text(
                      cat.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.drag_indicator,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: AppStrings.addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
