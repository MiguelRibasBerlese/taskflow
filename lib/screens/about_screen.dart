import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o TaskFlow')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Ícone ──────────────────────────────────────────
                  Icon(
                    Icons.task_alt_rounded,
                    size: 72,
                    color: cs.primary,
                    semanticLabel: 'Ícone do TaskFlow',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.version,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Card: Informações do projeto ───────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school_outlined,
                                  color: cs.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Informações do projeto',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: 'Objetivo',
                            value:
                                'Aplicativo acadêmico de controle de tarefas '
                                'para organização de atividades universitárias.',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Disciplina',
                            value:
                                '${AppStrings.discipline} — Programação Mobile II',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Instituição',
                            value:
                                '${AppStrings.university} — Campus Ribeirão Preto',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Professor',
                            value: 'Prof. Dr. Samuel Oliva',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Versão',
                            value: '1.0.0',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Card: Integrantes ──────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group_outlined,
                                  color: cs.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Integrantes',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _StudentRow(
                            name: 'Miguel Ribas Berlese',
                            ra: '839938',
                          ),
                          const SizedBox(height: 12),
                          _StudentRow(
                            name: 'Enzo Shimada Daun',
                            ra: '840552',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Botão Voltar ───────────────────────────────────
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String name;
  final String ra;

  const _StudentRow({required this.name, required this.ra});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cs.primaryContainer,
          child: Text(
            name[0],
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                'RA: $ra',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
