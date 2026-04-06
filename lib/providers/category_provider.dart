import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  final List<Category> _categories = [
    Category(id: 'cat-1', name: 'Trabalho', color: Color(0xFF6750A4)),
    Category(id: 'cat-2', name: 'Prova', color: Color(0xFFB3261E)),
    Category(id: 'cat-3', name: 'Projeto', color: Color(0xFF2E7D32)),
    Category(id: 'cat-4', name: 'Leitura', color: Color(0xFFF57C00)),
    Category(id: 'cat-5', name: 'Seminário', color: Color(0xFF0277BD)),
  ];

  List<Category> get categories => List.unmodifiable(_categories);

  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(String name, Color color) {
    _categories.add(Category(
      id: _uuid.v4(),
      name: name,
      color: color,
    ));
    notifyListeners();
  }

  void update(String id, {String? name, Color? color}) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _categories[index] = _categories[index].copyWith(name: name, color: color);
    notifyListeners();
  }

  void delete(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
