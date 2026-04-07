import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/empty_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const _presetColors = [
    AppColors.primary,
    AppColors.error,
    AppColors.priorityLow,
    AppColors.priorityMedium,
    AppColors.secondary,
    AppColors.tertiary,
  ];

  // GlobalKey garante acesso ao ScaffoldMessenger sem depender de BuildContext
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  // Controller no nível do State — dispose gerenciado por dispose(), nunca manualmente
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    // Reseta antes de abrir para reutilizar o controller com segurança
    _nameController.clear();

    // Tudo capturado sincronamente — zero uso de context após qualquer await
    final provider = context.read<CategoryProvider>();
    final formKey = GlobalKey<FormState>();
    var selectedColor = _presetColors[0];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: AppStrings.categoryName,
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) => Validators.required(v, label: 'Nome'),
                    autofocus: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cor',
                  style: Theme.of(dialogContext).textTheme.labelMedium?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _presetColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(dialogContext).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                provider.add(_nameController.text.trim(), selectedColor);
                Navigator.of(dialogContext).pop();
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.categories)),
        body: Consumer<CategoryProvider>(
          builder: (consumerContext, provider, _) {
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
              itemBuilder: (_, index) {
                final cat = categories[index];
                return Dismissible(
                  key: Key(cat.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final confirmed = await showDialog<bool>(
                      context: consumerContext,
                      builder: (d) => AlertDialog(
                        title: const Text('Excluir categoria'),
                        content: Text(
                          'Deseja excluir a categoria "${cat.name}"?\n'
                          'As tarefas vinculadas perderão a categoria.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(d, false),
                            child: const Text(AppStrings.cancel),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(d).colorScheme.error,
                            ),
                            onPressed: () => Navigator.pop(d, true),
                            child: const Text(AppStrings.delete),
                          ),
                        ],
                      ),
                    ) ??
                        false;

                    // Guarda caso a tela tenha sido desmontada durante o diálogo
                    if (!mounted) return false;

                    if (confirmed) {
                      // SnackBar ANTES do dismiss — via GlobalKey, sem depender de context
                      _messengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text('Categoria "${cat.name}" excluída'),
                        ),
                      );
                    }
                    return confirmed;
                  },
                  // onDismissed só chama o provider — zero uso de context
                  onDismissed: (_) => provider.delete(cat.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete_outline, color: cs.onErrorContainer, size: 28),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: cat.color.withValues(alpha: 0.15),
                        child: Icon(Icons.circle, color: cat.color, size: 20),
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
          onPressed: _showAddDialog,
          tooltip: AppStrings.addCategory,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
