// lib/screens/tasks/search_tasks_screen.dart
// Tela EXCLUSIVA de pesquisa de tarefas (RF006).
// Campo de busca case-insensitive (campo tituloLower) + ordenação por 4
// critérios (client-side). Não se mistura com a listagem principal.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/task_service.dart';
import '../../utils/firebase_ui.dart';
import '../../widgets/firebase_task_card.dart';
import '../firebase/firebase_edit_task_screen.dart';

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({super.key});

  @override
  State<SearchTasksScreen> createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  final _taskService = TaskService();
  String _termoBusca = '';
  String _ordenacao = 'dataVencimento_asc';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _ordenar(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final lista = [...docs];
    switch (_ordenacao) {
      case 'titulo_az':
        lista.sort((a, b) => ((a.data()['titulo'] as String?) ?? '')
            .toLowerCase()
            .compareTo(((b.data()['titulo'] as String?) ?? '').toLowerCase()));
        break;
      case 'prioridade':
        lista.sort((a, b) {
          final pa =
              FirebaseUi.ordemPrioridade[a.data()['prioridade']] ?? 1;
          final pb =
              FirebaseUi.ordemPrioridade[b.data()['prioridade']] ?? 1;
          return pa.compareTo(pb);
        });
        break;
      case 'dataVencimento_desc':
        lista.sort((a, b) => _venc(b).compareTo(_venc(a)));
        break;
      case 'dataVencimento_asc':
      default:
        lista.sort((a, b) => _venc(a).compareTo(_venc(b)));
    }
    return lista;
  }

  DateTime _venc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final ts = doc.data()['dataVencimento'] as Timestamp?;
    // Tarefas sem data vão para o fim na ordenação ascendente.
    return ts?.toDate() ?? DateTime(9999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Tarefas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _termoBusca = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _ordenacao,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                prefixIcon: Icon(Icons.sort),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'dataVencimento_asc',
                  child: Text('Data de vencimento (↑)'),
                ),
                DropdownMenuItem(
                  value: 'dataVencimento_desc',
                  child: Text('Data de vencimento (↓)'),
                ),
                DropdownMenuItem(value: 'titulo_az', child: Text('Título (A-Z)')),
                DropdownMenuItem(value: 'prioridade', child: Text('Prioridade')),
              ],
              onChanged: (v) =>
                  setState(() => _ordenacao = v ?? 'dataVencimento_asc'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _taskService.pesquisarTarefas(_termoBusca),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      _termoBusca.isEmpty
                          ? 'Digite algo para pesquisar'
                          : 'Nenhum resultado para "$_termoBusca"',
                    ),
                  );
                }
                final ordenados = _ordenar(docs);
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: ordenados.length,
                  itemBuilder: (context, index) {
                    final doc = ordenados[index];
                    final dados = doc.data();
                    final titulo = (dados['titulo'] as String?) ?? '';
                    final concluida =
                        (dados['status'] as String?) == 'Concluída';
                    return FirebaseTaskCard(
                      key: Key(doc.id),
                      id: doc.id,
                      dados: dados,
                      onToggle: () => _taskService.alternarConclusao(
                          doc.id, titulo, concluida),
                      onDelete: () =>
                          _taskService.excluirTarefa(doc.id, titulo),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FirebaseEditTaskScreen(id: doc.id, dados: dados),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
