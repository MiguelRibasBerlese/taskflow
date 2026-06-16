// lib/services/task_service.dart
// CRUD de tarefas no Firestore — todos os dados isolados por usuário (uid).
// Coleções tocadas: "tarefas" e "registros_atividade" (RF003/RF004/RF005/RF006).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UID do usuário logado — usado em TODAS as operações.
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream em tempo real das tarefas do usuário (RF005 — StreamBuilder).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamTarefas() {
    return _firestore
        .collection('tarefas')
        .where('uid', isEqualTo: _uid)
        .orderBy('dataCriacao', descending: true)
        .snapshots();
  }

  // Inserir nova tarefa (RF003).
  Future<void> adicionarTarefa({
    required String titulo,
    required String descricao,
    required String prioridade,
    required String categoria,
    required String status,
    DateTime? dataVencimento,
  }) async {
    final agora = FieldValue.serverTimestamp();
    final docRef = await _firestore.collection('tarefas').add({
      'uid': _uid,
      'titulo': titulo.trim(),
      // Campos *Lower para pesquisa case-insensitive (RF006).
      'tituloLower': titulo.trim().toLowerCase(),
      'descricao': descricao.trim(),
      'descricaoLower': descricao.trim().toLowerCase(),
      'prioridade': prioridade,
      'categoria': categoria,
      'status': status,
      'dataVencimento':
          dataVencimento != null ? Timestamp.fromDate(dataVencimento) : null,
      'dataCriacao': agora,
      'dataAtualizacao': agora,
    });

    await _registrarAtividade(
      tarefaId: docRef.id,
      tarefaTitulo: titulo,
      acao: 'criou',
      descricao: 'Tarefa "$titulo" criada',
    );
  }

  // Atualizar tarefa existente (RF004).
  Future<void> atualizarTarefa({
    required String id,
    required String titulo,
    required String descricao,
    required String prioridade,
    required String categoria,
    required String status,
    DateTime? dataVencimento,
  }) async {
    await _firestore.collection('tarefas').doc(id).update({
      'titulo': titulo.trim(),
      'tituloLower': titulo.trim().toLowerCase(),
      'descricao': descricao.trim(),
      'descricaoLower': descricao.trim().toLowerCase(),
      'prioridade': prioridade,
      'categoria': categoria,
      'status': status,
      'dataVencimento':
          dataVencimento != null ? Timestamp.fromDate(dataVencimento) : null,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    });

    await _registrarAtividade(
      tarefaId: id,
      tarefaTitulo: titulo,
      acao: 'editou',
      descricao: 'Tarefa "$titulo" editada',
    );
  }

  // Excluir tarefa.
  Future<void> excluirTarefa(String id, String titulo) async {
    await _firestore.collection('tarefas').doc(id).delete();
    await _registrarAtividade(
      tarefaId: id,
      tarefaTitulo: titulo,
      acao: 'excluiu',
      descricao: 'Tarefa "$titulo" excluída',
    );
  }

  // Concluir tarefa rapidamente (atalho de RF004).
  Future<void> concluirTarefa(String id, String titulo) async {
    await _firestore.collection('tarefas').doc(id).update({
      'status': 'Concluída',
      'dataAtualizacao': FieldValue.serverTimestamp(),
    });
    await _registrarAtividade(
      tarefaId: id,
      tarefaTitulo: titulo,
      acao: 'concluiu',
      descricao: 'Tarefa "$titulo" marcada como concluída',
    );
  }

  // Alterna o status entre "Concluída" e "Pendente" (usado pelo checkbox).
  Future<void> alternarConclusao(String id, String titulo, bool concluida) async {
    if (concluida) {
      await _firestore.collection('tarefas').doc(id).update({
        'status': 'Pendente',
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
      await _registrarAtividade(
        tarefaId: id,
        tarefaTitulo: titulo,
        acao: 'reabriu',
        descricao: 'Tarefa "$titulo" reaberta',
      );
    } else {
      await concluirTarefa(id, titulo);
    }
  }

  // Pesquisa com case-insensitive (RF006).
  // Firestore não suporta LIKE; usamos o campo 'tituloLower' (minúsculas) com
  // range query para simular "começa com" sem diferenciar maiúsculas.
  Stream<QuerySnapshot<Map<String, dynamic>>> pesquisarTarefas(String termo) {
    if (termo.trim().isEmpty) return streamTarefas();

    final termoLower = termo.toLowerCase().trim();
    return _firestore
        .collection('tarefas')
        .where('uid', isEqualTo: _uid)
        .where('tituloLower', isGreaterThanOrEqualTo: termoLower)
        .where('tituloLower', isLessThan: '${termoLower}z')
        .snapshots();
  }

  // Registrar atividade na coleção "registros_atividade" (4ª coleção — RF003).
  Future<void> _registrarAtividade({
    required String tarefaId,
    required String tarefaTitulo,
    required String acao,
    required String descricao,
  }) async {
    await _firestore.collection('registros_atividade').add({
      'uid': _uid,
      'tarefaId': tarefaId,
      'tarefaTitulo': tarefaTitulo,
      'acao': acao,
      'descricao': descricao,
      'dataHora': FieldValue.serverTimestamp(),
    });
  }
}
