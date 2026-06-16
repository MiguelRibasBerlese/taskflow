// lib/models/estado.dart
// Modelo de dados para a API pública do IBGE (RF007).
// Mapeia o JSON de /localidades/estados em um objeto Dart tipado.

class Estado {
  final int id;
  final String sigla;
  final String nome;
  final String regiao;

  const Estado({
    required this.id,
    required this.sigla,
    required this.nome,
    required this.regiao,
  });

  // Construtor a partir do JSON da API do IBGE.
  // A região vem aninhada: { ..., "regiao": { "nome": "Sudeste" } }.
  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      id: json['id'] as int,
      sigla: json['sigla'] as String,
      nome: json['nome'] as String,
      regiao: (json['regiao']?['nome'] as String?) ?? '—',
    );
  }
}
