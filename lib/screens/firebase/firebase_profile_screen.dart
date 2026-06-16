// lib/screens/firebase/firebase_profile_screen.dart
// Perfil do usuário em tempo real (RF005) e atualização (RF004).
// Lê/grava na coleção "usuarios".

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class FirebaseProfileScreen extends StatelessWidget {
  const FirebaseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final service = UserService();

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: service.streamPerfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final dados = snapshot.data?.data() ?? <String, dynamic>{};
          final nome = (dados['nome'] as String?) ?? '—';
          final email = (dados['email'] as String?) ?? '—';
          final telefone = (dados['telefone'] as String?) ?? '—';
          final uf = (dados['uf'] as String?) ?? '—';

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nome,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _row(theme, Icons.email_outlined, 'E-mail', email),
                            const Divider(height: 24),
                            _row(theme, Icons.phone_outlined, 'Telefone',
                                telefone),
                            const Divider(height: 24),
                            _row(theme, Icons.map_outlined, 'Estado (UF)', uf),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(
                          context,
                          service,
                          nome: nome == '—' ? '' : nome,
                          telefone: telefone == '—' ? '' : telefone,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar perfil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(ThemeData theme, IconData icon, String label, String value) {
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
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
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    UserService service, {
    required String nome,
    required String telefone,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: nome);
    final phoneController = TextEditingController(text: telefone);
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: AppStrings.name,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.phone,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: Validators.phone,
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await service.atualizarPerfil(
                nome: nameController.text.trim(),
                telefone: phoneController.text.trim(),
              );
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Perfil atualizado!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
