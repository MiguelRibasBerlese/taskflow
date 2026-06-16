// lib/services/auth_service.dart
// Serviço de autenticação com Firebase Authentication (RF001/RF002).
// Comentários em português conforme padrão da disciplina.
//
// OBS.: Este arquivo só é usado quando kFirebaseEnabled = true. Em modo seguro
// ele compila normalmente (os pacotes firebase_* estão no pubspec), mas nenhum
// método é chamado — portanto FirebaseAuth.instance nunca é tocado.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream do estado de autenticação — ouvir mudanças de sessão (RF005).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário logado atualmente.
  User? get usuarioAtual => _auth.currentUser;

  // Login com email e senha (RF001).
  Future<String?> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return null; // null = sucesso
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    }
  }

  // Cadastro de novo usuário + perfil na coleção "usuarios" (RF002/RF003).
  Future<String?> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String telefone,
    required String uf,
  }) async {
    try {
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      // Salva dados adicionais na coleção "usuarios" (5+ campos — RF003).
      await _firestore.collection('usuarios').doc(resultado.user!.uid).set({
        'uid': resultado.user!.uid,
        'nome': nome.trim(),
        'email': email.trim(),
        'telefone': telefone.trim(),
        'uf': uf,
        'dataCadastro': FieldValue.serverTimestamp(),
      });

      return null; // null = sucesso
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    }
  }

  // Recuperação de senha por email (RF001).
  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    }
  }

  // Logout.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Tradução dos códigos de erro do Firebase para português.
  String _traduzirErroAuth(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em alguns minutos.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}
