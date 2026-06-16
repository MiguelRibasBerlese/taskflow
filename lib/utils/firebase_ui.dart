// lib/utils/firebase_ui.dart
// Helpers de UI compartilhados pelas telas do modo Firebase.
// Mapeiam os valores em texto guardados no Firestore para cores/ícones.

import 'package:flutter/material.dart';

class FirebaseUi {
  FirebaseUi._();

  // Valores canônicos guardados no Firestore (campos de texto).
  static const List<String> prioridades = ['Alta', 'Média', 'Baixa'];
  static const List<String> statuses = ['Pendente', 'Em andamento', 'Concluída'];

  // Ordem usada na ordenação por prioridade (RF006).
  static const Map<String, int> ordemPrioridade = {
    'Alta': 0,
    'Média': 1,
    'Baixa': 2,
  };

  static Color corPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return const Color(0xFFB3261E);
      case 'Baixa':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFF57C00); // Média
    }
  }

  // Converte uma cor guardada como "0xFF6366F1" em Color.
  static Color corDeHex(String hex, {Color fallback = const Color(0xFF6366F1)}) {
    var s = hex.trim();
    if (s.startsWith('0x') || s.startsWith('0X')) s = s.substring(2);
    final v = int.tryParse(s, radix: 16);
    return v != null ? Color(v) : fallback;
  }

  // Converte o nome do ícone guardado no Firestore em IconData.
  static IconData iconePorNome(String nome) {
    switch (nome) {
      case 'work':
        return Icons.work_outline;
      case 'person':
        return Icons.person_outline;
      case 'school':
        return Icons.school_outlined;
      case 'favorite':
        return Icons.favorite_border;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.label_outline;
    }
  }

  // Nomes de ícone disponíveis para o seletor de categoria.
  static const List<String> iconesDisponiveis = [
    'work',
    'person',
    'school',
    'favorite',
    'attach_money',
    'label',
  ];

  // Cores disponíveis (hex) para o seletor de categoria.
  static const List<String> coresDisponiveis = [
    '0xFF6366F1',
    '0xFF8B5CF6',
    '0xFF10B981',
    '0xFFEF4444',
    '0xFFF59E0B',
    '0xFF0277BD',
  ];
}
