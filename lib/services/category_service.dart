// lib/services/category_service.dart
// CRUD de categorias no Firestore — coleção "categorias" (RF003/RF004/RF005).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream em tempo real das categorias (RF005 — StreamBuilder + GridView).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCategorias() {
    return _firestore
        .collection('categorias')
        .where('uid', isEqualTo: _uid)
        .orderBy('ordem')
        .snapshots();
  }

  // Adicionar categoria (RF003).
  Future<void> adicionarCategoria({
    required String nome,
    required String cor,
    required String icone,
  }) async {
    final snap = await _firestore
        .collection('categorias')
        .where('uid', isEqualTo: _uid)
        .count()
        .get();

    await _firestore.collection('categorias').add({
      'uid': _uid,
      'nome': nome.trim(),
      'cor': cor,
      'icone': icone,
      'dataCriacao': FieldValue.serverTimestamp(),
      'ordem': snap.count ?? 0,
    });
  }

  // Atualizar categoria (RF004).
  Future<void> atualizarCategoria({
    required String id,
    required String nome,
    required String cor,
    required String icone,
  }) async {
    await _firestore.collection('categorias').doc(id).update({
      'nome': nome.trim(),
      'cor': cor,
      'icone': icone,
    });
  }

  // Excluir categoria.
  Future<void> excluirCategoria(String id) async {
    await _firestore.collection('categorias').doc(id).delete();
  }

  // Criar categorias padrão para um novo usuário (batch write).
  Future<void> criarCategoriasPadrao() async {
    final categoriasPadrao = <Map<String, dynamic>>[
      {'nome': 'Trabalho', 'cor': '0xFF6366F1', 'icone': 'work', 'ordem': 0},
      {'nome': 'Pessoal', 'cor': '0xFF8B5CF6', 'icone': 'person', 'ordem': 1},
      {'nome': 'Estudos', 'cor': '0xFF10B981', 'icone': 'school', 'ordem': 2},
      {'nome': 'Saúde', 'cor': '0xFFEF4444', 'icone': 'favorite', 'ordem': 3},
      {
        'nome': 'Financeiro',
        'cor': '0xFFF59E0B',
        'icone': 'attach_money',
        'ordem': 4
      },
    ];

    final batch = _firestore.batch();
    for (final cat in categoriasPadrao) {
      final ref = _firestore.collection('categorias').doc();
      batch.set(ref, {
        ...cat,
        'uid': _uid,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
