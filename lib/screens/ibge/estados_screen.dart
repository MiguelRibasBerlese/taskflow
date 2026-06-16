// lib/screens/ibge/estados_screen.dart
// Consumo da API REST pública do IBGE (RF007).
// FutureBuilder é o padrão correto para chamadas HTTP únicas.
// Esta tela NÃO depende do Firebase — funciona em modo seguro.

import 'package:flutter/material.dart';

import '../../models/estado.dart';
import '../../services/ibge_service.dart';

class EstadosScreen extends StatefulWidget {
  const EstadosScreen({super.key});

  @override
  State<EstadosScreen> createState() => _EstadosScreenState();
}

class _EstadosScreenState extends State<EstadosScreen> {
  late Future<List<Estado>> _futureEstados;

  @override
  void initState() {
    super.initState();
    _futureEstados = IbgeService().listarEstados();
  }

  void _recarregar() {
    setState(() {
      _futureEstados = IbgeService().listarEstados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Estados do Brasil')),
      body: FutureBuilder<List<Estado>>(
        future: _futureEstados,
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Erro
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      'Falha ao carregar estados.\nVerifique sua conexão.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _recarregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          // Dados
          final estados = snapshot.data ?? const <Estado>[];
          if (estados.isEmpty) {
            return const Center(child: Text('Nenhum estado encontrado.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: estados.length,
            itemBuilder: (context, index) {
              final estado = estados[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      estado.sigla,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    estado.nome,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    estado.regiao,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
