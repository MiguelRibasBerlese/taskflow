// lib/widgets/firebase_task_card.dart
// Card de tarefa para o modo Firebase — lê um documento do Firestore
// (Map<String, dynamic>) em vez do model Task da Parte 1.
// Usa Dismissible para exclusão e badge de prioridade (RF005).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import '../utils/firebase_ui.dart';

class FirebaseTaskCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> dados;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const FirebaseTaskCard({
    super.key,
    required this.id,
    required this.dados,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final titulo = (dados['titulo'] as String?) ?? '(sem título)';
    final prioridade = (dados['prioridade'] as String?) ?? 'Média';
    final categoria = (dados['categoria'] as String?) ?? '';
    final status = (dados['status'] as String?) ?? 'Pendente';
    final concluida = status == 'Concluída';
    final venc = (dados['dataVencimento'] as Timestamp?)?.toDate();
    final fmt = DateFormat(AppConfig.dateFormat);
    final atrasada = venc != null && !concluida && venc.isBefore(DateTime.now());
    final corPrio = FirebaseUi.corPrioridade(prioridade);

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Checkbox(
                    value: concluida,
                    onChanged: (_) => onToggle(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              titulo,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: concluida
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: concluida
                                    ? cs.onSurfaceVariant
                                    : cs.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge de prioridade
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: corPrio.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: corPrio.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              prioridade,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: corPrio,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (categoria.isNotEmpty)
                            Text(
                              categoria,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          if (venc != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color:
                                      atrasada ? cs.error : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fmt.format(venc),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: atrasada
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                                    fontWeight:
                                        atrasada ? FontWeight.w600 : null,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
