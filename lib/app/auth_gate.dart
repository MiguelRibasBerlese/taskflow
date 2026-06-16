// lib/app/auth_gate.dart
// ─────────────────────────────────────────────────────────────────────────────
// Porteiro da aplicação: decide qual "mundo" rodar.
//
//   kFirebaseEnabled == false  → MODO SEGURO (Parte 1): app mockado em memória.
//                                AuthService/FirebaseAuth NUNCA são construídos,
//                                então nada do Firebase é tocado em runtime.
//
//   kFirebaseEnabled == true   → MODO FIREBASE: ouve authStateChanges() e troca
//                                entre login e home conforme a sessão.
//
// A troca é estrutural: no modo seguro a subárvore do StreamBuilder abaixo
// jamais é construída — por isso o app funciona sem firebase_options.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_config.dart';
import '../screens/login_screen.dart';
import '../screens/firebase/firebase_home_screen.dart';
import '../screens/firebase/firebase_login_screen.dart';
import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // MODO SEGURO — retorna a tela de login mockada da Parte 1.
    // Nada do Firebase é instanciado neste caminho.
    if (!kFirebaseEnabled) {
      return const LoginScreen();
    }

    // MODO FIREBASE — redireciona conforme o estado de autenticação (RF005).
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const FirebaseHomeScreen();
        }
        return const FirebaseLoginScreen();
      },
    );
  }
}
