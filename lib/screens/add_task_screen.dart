import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.media;
  String? _categoryId;
  DateTime? _dueDate;

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
      helpText: 'Selecionar data de entrega',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TaskProvider>().add(
          Task(
            id: '',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            categoryId: _categoryId ?? '',
            dueDate: _dueDate,
            createdAt: DateTime.now(),
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa criada!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
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
                    // Título
                    Semantics(
                      label: 'Campo título da tarefa',
                      child: TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: AppStrings.taskTitle,
                          hintText: 'Ex.: Entregar trabalho de cálculo',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) =>
                            Validators.required(v, label: 'Título'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    Semantics(
                      label: 'Campo descrição da tarefa',
                      child: TextFormField(
                        controller: _descriptionController,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: AppStrings.taskDescription,
                          hintText: 'Detalhes opcionais...',
                          prefixIcon: Icon(Icons.notes_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prioridade
                    Semantics(
                      label: 'Selecionar prioridade',
                      child: DropdownButtonFormField<Priority>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: AppStrings.taskPriority,
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Priority.alta,
                            child: Text(AppStrings.priorityHigh),
                          ),
                          DropdownMenuItem(
                            value: Priority.media,
                            child: Text(AppStrings.priorityMedium),
                          ),
                          DropdownMenuItem(
                            value: Priority.baixa,
                            child: Text(AppStrings.priorityLow),
                          ),
                        ],
                        onChanged: (v) => _priority = v ?? Priority.media,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    Semantics(
                      label: 'Selecionar categoria',
                      child: DropdownButtonFormField<String?>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: AppStrings.taskCategory,
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sem categoria'),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: c.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => _categoryId = v,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Data de vencimento
                    _DatePickerField(
                      label: AppStrings.taskDueDate,
                      date: _dueDate,
                      formatter: fmt,
                      onPick: _pickDate,
                      onClear: () => setState(() => _dueDate = null),
                    ),
                    const SizedBox(height: 32),

                    // Botão Salvar
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(AppStrings.save),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão Cancelar
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(height: 24),
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

// ── Widget auxiliar para campo de data ──────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat formatter;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.formatter,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: 'Campo data de entrega',
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: date != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Remover data',
                    onPressed: onClear,
                  )
                : null,
          ),
          child: Text(
            date != null ? formatter.format(date!) : 'Opcional — toque para selecionar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: date != null ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
