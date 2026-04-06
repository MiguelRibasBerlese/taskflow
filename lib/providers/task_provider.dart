import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  final List<Task> _tasks = [
    Task(
      id: 'task-1',
      title: 'Entregar relatório de AC622',
      description: 'Finalizar e enviar o relatório final da disciplina.',
      priority: Priority.alta,
      categoryId: 'cat-1',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: 'task-2',
      title: 'Estudar para a prova de cálculo',
      description: 'Revisar capítulos 5 a 8 do livro.',
      priority: Priority.alta,
      categoryId: 'cat-2',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: 'task-3',
      title: 'Leitura obrigatória — artigo IEEE',
      description: 'Ler e resumir o artigo indicado pelo professor.',
      priority: Priority.media,
      categoryId: 'cat-4',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Task(
      id: 'task-4',
      title: 'Apresentação de seminário',
      description: 'Preparar slides e roteiro.',
      priority: Priority.baixa,
      categoryId: 'cat-5',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get pending => _tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completed => _tasks.where((t) => t.isCompleted).toList();

  List<Task> getByCategory(String categoryId) =>
      _tasks.where((t) => t.categoryId == categoryId).toList();

  Task? getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Task task) {
    _tasks.add(task.copyWith(id: _uuid.v4()));
    notifyListeners();
  }

  void update(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
  }

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );
    notifyListeners();
  }

  void delete(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
