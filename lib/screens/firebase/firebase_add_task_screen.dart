// lib/screens/firebase/firebase_add_task_screen.dart
// Inserção de tarefa no Firestore (RF003). Grava na coleção "tarefas" e
// registra atividade em "registros_atividade". Exibe SnackBar de confirmação.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/category_service.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_ui.dart';
import '../../utils/validators.dart';

class FirebaseAddTaskScreen extends StatefulWidget {
  const FirebaseAddTaskScreen({super.key});

  @override
  State<FirebaseAddTaskScreen> createState() => _FirebaseAddTaskScreenState();
}

class _FirebaseAddTaskScreenState extends State<FirebaseAddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();

  String _prioridade = 'Média';
  String _status = 'Pendente';
  String? _categoria;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: 'Selecionar data de vencimento',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await _taskService.adicionarTarefa(
        titulo: _titleController.text.trim(),
        descricao: _descriptionController.text.trim(),
        prioridade: _prioridade,
        categoria: _categoria ?? '',
        status: _status,
        dataVencimento: _dueDate,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tarefa criada com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao criar tarefa: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(AppConfig.dateFormat);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addTask)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskTitle,
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) => Validators.required(v, label: 'Título'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskDescription,
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _prioridade,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskPriority,
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: FirebaseUi.prioridades
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setState(
                        () => _prioridade = v ?? 'Média',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.timelapse_outlined),
                      ),
                      items: FirebaseUi.statuses
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(
                        () => _status = v ?? 'Pendente',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categoria — alimentada em tempo real pelo Firestore.
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: CategoryService().streamCategorias(),
                      builder: (context, snapshot) {
                        final nomes = <String>[
                          ...?snapshot.data?.docs.map(
                            (d) => (d.data()['nome'] as String?) ?? '',
                          ),
                        ].where((n) => n.isNotEmpty).toList();
                        return DropdownButtonFormField<String>(
                          initialValue: _categoria,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: AppStrings.taskCategory,
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Sem categoria'),
                            ),
                            ...nomes.map(
                              (n) => DropdownMenuItem(value: n, child: Text(n)),
                            ),
                          ],
                          onChanged: (v) => setState(() => _categoria = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: AppStrings.taskDueDate,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: _dueDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _dueDate = null),
                                )
                              : null,
                        ),
                        child: Text(
                          _dueDate != null
                              ? fmt.format(_dueDate!)
                              : 'Opcional — toque para selecionar',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_isLoading ? 'Salvando...' : AppStrings.save),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
