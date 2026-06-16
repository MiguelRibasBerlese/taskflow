// lib/screens/firebase/firebase_home_screen.dart
// Listagem de tarefas em tempo real (RF005 — StreamBuilder + ListView).
// Filtrada por uid no TaskService. Drawer dá acesso às demais telas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/firebase_task_card.dart';
import '../about_screen.dart';
import '../ibge/estados_screen.dart';
import '../tasks/search_tasks_screen.dart';
import 'firebase_add_task_screen.dart';
import 'firebase_categories_screen.dart';
import 'firebase_edit_task_screen.dart';
import 'firebase_profile_screen.dart';

class FirebaseHomeScreen extends StatelessWidget {
  const FirebaseHomeScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final taskService = TaskService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: cs.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.task_alt_rounded, color: cs.onPrimary, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AuthService().usuarioAtual?.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Tarefas'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Pesquisar'),
                onTap: () {
                  Navigator.pop(context);
                  _push(context, const SearchTasksScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text(AppStrings.categories),
                onTap: () {
                  Navigator.pop(context);
                  _push(context, const FirebaseCategoriesScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Estados (IBGE)'),
                onTap: () {
                  Navigator.pop(context);
                  _push(context, const EstadosScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Meu perfil'),
                onTap: () {
                  Navigator.pop(context);
                  _push(context, const FirebaseProfileScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text(AppStrings.about),
                onTap: () {
                  Navigator.pop(context);
                  _push(context, const AboutScreen());
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text(AppStrings.logout,
                    style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.pop(context);
                  AuthService().logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: taskService.streamTarefas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar tarefas: ${snapshot.error}'),
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.checklist_rounded,
              title: AppStrings.noTasks,
              subtitle: 'Toque em + para criar sua primeira tarefa.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final dados = doc.data();
              final titulo = (dados['titulo'] as String?) ?? '';
              final concluida = (dados['status'] as String?) == 'Concluída';
              return FirebaseTaskCard(
                key: Key(doc.id),
                id: doc.id,
                dados: dados,
                onToggle: () =>
                    taskService.alternarConclusao(doc.id, titulo, concluida),
                onDelete: () => taskService.excluirTarefa(doc.id, titulo),
                onTap: () => _push(
                  context,
                  FirebaseEditTaskScreen(id: doc.id, dados: dados),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _push(context, const FirebaseAddTaskScreen()),
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
