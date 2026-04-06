import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  User? _currentUser;
  String? _errorMessage;

  // Registro simulado em memória
  final List<User> _registeredUsers = [
    User(
      name: AppConfig.demoName,
      email: AppConfig.demoEmail,
      phone: AppConfig.demoPhone,
      password: AppConfig.demoPassword,
    ),
  ];

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _registeredUsers.where(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
    );

    if (user.isNotEmpty) {
      _currentUser = user.first;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _errorMessage = 'E-mail ou senha incorretos';
    notifyListeners();
    return false;
  }

  Future<bool> register(User user) async {
    _errorMessage = null;
    await Future.delayed(const Duration(milliseconds: 600));

    final exists = _registeredUsers.any(
      (u) => u.email.toLowerCase() == user.email.toLowerCase(),
    );

    if (exists) {
      _errorMessage = 'Este e-mail já está cadastrado';
      notifyListeners();
      return false;
    }

    _registeredUsers.add(user);
    _currentUser = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    await Future.delayed(const Duration(milliseconds: 600));

    final exists = _registeredUsers.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (!exists) {
      _errorMessage = 'E-mail não encontrado';
      notifyListeners();
      return false;
    }

    // Simulação: apenas retorna sucesso
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
