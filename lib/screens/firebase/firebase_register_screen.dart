// lib/screens/firebase/firebase_register_screen.dart
// Cadastro de usuário no modo Firebase (RF002).
// Grava 5+ campos na coleção "usuarios" (RF003) e cria categorias padrão.
// O campo UF é populado pela API do IBGE (RF007 — integração no cadastro).

import 'package:flutter/material.dart';

import '../../models/estado.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/ibge_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class FirebaseRegisterScreen extends StatefulWidget {
  const FirebaseRegisterScreen({super.key});

  @override
  State<FirebaseRegisterScreen> createState() => _FirebaseRegisterScreenState();
}

class _FirebaseRegisterScreenState extends State<FirebaseRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _auth = AuthService();
  late final Future<List<Estado>> _futureEstados;
  String? _ufSelecionada;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureEstados = IbgeService().listarEstados();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    final erro = await _auth.cadastrar(
      email: _emailController.text.trim(),
      senha: _passwordController.text,
      nome: _nameController.text.trim(),
      telefone: _phoneController.text.trim(),
      uf: _ufSelecionada ?? '',
    );

    if (!mounted) return;

    if (erro != null) {
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Cadastro OK — cria categorias padrão para o novo usuário (RF003).
    try {
      await CategoryService().criarCategoriasPadrao();
    } catch (_) {
      // Categorias são auxiliares — não bloqueiam o fluxo de cadastro.
    }

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Conta criada com sucesso!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Volta — o AuthGate já estará na Home graças ao authStateChanges().
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crie sua conta',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.name,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        hintText: 'seu@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.phone,
                        hintText: '(XX) XXXXX-XXXX',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 16),
                    // ── UF via API IBGE (RF007) ───────────────────────────
                    FutureBuilder<List<Estado>>(
                      future: _futureEstados,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Não foi possível carregar os estados (IBGE).',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.error),
                          );
                        }
                        final estados = snapshot.data ?? const <Estado>[];
                        return DropdownButtonFormField<String>(
                          initialValue: _ufSelecionada,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Estado (UF)',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          items: estados
                              .map((e) => DropdownMenuItem(
                                    value: e.sigla,
                                    child: Text('${e.sigla} — ${e.nome}'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _ufSelecionada = v),
                          validator: (v) =>
                              v == null ? 'Selecione seu estado.' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        helperText:
                            'Mín. 8 caracteres, 1 maiúscula, 1 número e 1 especial',
                        helperMaxLines: 2,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: Validators.senhaCadastro,
                      onChanged: (_) {
                        if (_confirmController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: AppStrings.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (v) => Validators.confirmarSenhaForte(
                        v,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.onPrimary,
                                ),
                              )
                            : const Text(AppStrings.register),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.alreadyHaveAccount),
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
