// lib/screens/firebase/firebase_categories_screen.dart
// Categorias em tempo real (RF005 — StreamBuilder + GridView).
// Adicionar (RF003) e atualizar (RF004) via diálogo. Excluir com confirmação.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/category_service.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_ui.dart';
import '../../utils/validators.dart';
import '../../widgets/empty_state.dart';

class FirebaseCategoriesScreen extends StatelessWidget {
  const FirebaseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CategoryService();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamCategorias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'Nenhuma categoria',
              subtitle: 'Toque em + para criar uma categoria.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final dados = doc.data();
              final nome = (dados['nome'] as String?) ?? '';
              final cor = FirebaseUi.corDeHex((dados['cor'] as String?) ?? '');
              final icone =
                  FirebaseUi.iconePorNome((dados['icone'] as String?) ?? '');
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      _showCategoryDialog(context, service, id: doc.id, dados: dados),
                  onLongPress: () =>
                      _confirmDelete(context, service, doc.id, nome),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: cor.withValues(alpha: 0.15),
                          child: Icon(icone, color: cor, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nome,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manter pressionado p/ excluir',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, service),
        tooltip: AppStrings.addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryService service,
    String id,
    String nome,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir a categoria "$nome"?'),
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
    if (confirmed != true) return;
    await service.excluirCategoria(id);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Categoria "$nome" excluída'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Diálogo reutilizado para criar (id == null) e editar (id != null).
  Future<void> _showCategoryDialog(
    BuildContext context,
    CategoryService service, {
    String? id,
    Map<String, dynamic>? dados,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: dados?['nome'] as String? ?? '');
    var corHex = (dados?['cor'] as String?) ?? FirebaseUi.coresDisponiveis.first;
    var icone = (dados?['icone'] as String?) ?? FirebaseUi.iconesDisponiveis.first;
    final messenger = ScaffoldMessenger.of(context);
    final isEdit = id != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar categoria' : AppStrings.addCategory),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: AppStrings.categoryName,
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) => Validators.required(v, label: 'Nome'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Cor'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: FirebaseUi.coresDisponiveis.map((hex) {
                      final cor = FirebaseUi.corDeHex(hex);
                      final selected = hex == corHex;
                      return GestureDetector(
                        onTap: () => setDialogState(() => corHex = hex),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cor,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: Theme.of(dialogContext)
                                        .colorScheme
                                        .onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ícone'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: FirebaseUi.iconesDisponiveis.map((nome) {
                      final selected = nome == icone;
                      final cs = Theme.of(dialogContext).colorScheme;
                      return GestureDetector(
                        onTap: () => setDialogState(() => icone = nome),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected
                                ? cs.primaryContainer
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            FirebaseUi.iconePorNome(nome),
                            color: selected
                                ? cs.onPrimaryContainer
                                : cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final nome = nameController.text.trim();
                Navigator.pop(dialogContext);
                if (isEdit) {
                  await service.atualizarCategoria(
                    id: id,
                    nome: nome,
                    cor: corHex,
                    icone: icone,
                  );
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Categoria atualizada!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  await service.adicionarCategoria(
                    nome: nome,
                    cor: corHex,
                    icone: icone,
                  );
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Categoria criada!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}
