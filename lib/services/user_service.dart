// lib/services/user_service.dart
// Dados do perfil do usuário na coleção "usuarios" (RF004 — atualização).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Buscar dados do perfil uma vez.
  Future<Map<String, dynamic>?> buscarPerfil() async {
    final doc = await _firestore.collection('usuarios').doc(_uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Stream do perfil (exibir nome/UF em tempo real — RF005).
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamPerfil() {
    return _firestore.collection('usuarios').doc(_uid).snapshots();
  }

  // Atualizar perfil na coleção "usuarios" (RF004).
  Future<void> atualizarPerfil({
    required String nome,
    required String telefone,
  }) async {
    await _firestore.collection('usuarios').doc(_uid).update({
      'nome': nome.trim(),
      'telefone': telefone.trim(),
      'dataAtualizacao': FieldValue.serverTimestamp(),
    });
  }
}
