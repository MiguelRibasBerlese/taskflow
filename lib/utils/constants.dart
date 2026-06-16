import 'package:flutter/material.dart';

// ─── Cores ────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6750A4);
  static const Color primaryDark = Color(0xFF4F378B);
  static const Color primaryLight = Color(0xFFD0BCFF);
  static const Color secondary = Color(0xFF625B71);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color error = Color(0xFFB3261E);
  static const Color background = Color(0xFFFFFBFE);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);

  static const Color priorityHigh = Color(0xFFB3261E);
  static const Color priorityMedium = Color(0xFFF57C00);
  static const Color priorityLow = Color(0xFF2E7D32);

  static const Color categoryDefault = Color(0xFF6750A4);
}

// ─── Strings ──────────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName = 'TaskFlow';
  static const String appSubtitle = 'Controle de Tarefas Acadêmicas';
  static const String university = 'UNAERP';
  static const String discipline = 'AC622';

  // Auth
  static const String login = 'Entrar';
  static const String logout = 'Sair';
  static const String register = 'Criar conta';
  static const String forgotPassword = 'Esqueci minha senha';
  static const String resetPassword = 'Redefinir senha';
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar senha';
  static const String name = 'Nome completo';
  static const String phone = 'Telefone';
  static const String alreadyHaveAccount = 'Já tem uma conta? Entrar';
  static const String dontHaveAccount = 'Não tem conta? Criar conta';

  // Tasks
  static const String tasks = 'Tarefas';
  static const String addTask = 'Nova tarefa';
  static const String editTask = 'Editar tarefa';
  static const String taskDetail = 'Detalhes da tarefa';
  static const String taskTitle = 'Título';
  static const String taskDescription = 'Descrição';
  static const String taskPriority = 'Prioridade';
  static const String taskCategory = 'Categoria';
  static const String taskDueDate = 'Data de entrega';
  static const String taskCompleted = 'Concluída';
  static const String taskPending = 'Pendente';
  static const String noTasks = 'Nenhuma tarefa encontrada';
  static const String deleteTask = 'Excluir tarefa';
  static const String confirmDelete = 'Confirmar exclusão';
  static const String confirmDeleteMessage =
      'Deseja realmente excluir esta tarefa?';

  // Priority labels
  static const String priorityHigh = 'Alta';
  static const String priorityMedium = 'Média';
  static const String priorityLow = 'Baixa';

  // Categories
  static const String categories = 'Categorias';
  static const String addCategory = 'Nova categoria';
  static const String categoryName = 'Nome da categoria';

  // About
  static const String about = 'Sobre';
  static const String version = 'Versão 2.0.0 — Parte 2 (Firebase + API IBGE)';

  // General
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String yes = 'Sim';
  static const String no = 'Não';
  static const String loading = 'Carregando...';
  static const String error = 'Erro';
  static const String success = 'Sucesso';
  static const String required = 'Campo obrigatório';
}

// ─── Rotas ────────────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String home = '/home';
  static const String addTask = '/addTask';
  static const String editTask = '/editTask';
  static const String taskDetail = '/taskDetail';
  static const String categories = '/categories';
  static const String about = '/about';
  static const String estados = '/estados';
  static const String search = '/search';
  static const String profile = '/profile';
}

// ─── Configurações gerais ─────────────────────────────────────────────────────
class AppConfig {
  AppConfig._();

  static const int passwordMinLength = 6;
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Usuário demo (autenticação simulada)
  static const String demoEmail = 'aluno@unaerp.br';
  static const String demoPassword = '123456';
  static const String demoName = 'Aluno UNAERP';
  static const String demoPhone = '(16) 99999-9999';
}
