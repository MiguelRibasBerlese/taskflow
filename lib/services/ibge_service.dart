// lib/services/ibge_service.dart
// Consumo da API REST pública do IBGE (RF007).
// NÃO depende do Firebase — funciona em modo seguro e em modo Firebase.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estado.dart';

class IbgeService {
  static const String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  // Listar todos os estados ordenados por nome.
  Future<List<Estado>> listarEstados() async {
    final resposta = await http.get(
      Uri.parse('$_baseUrl/estados/?orderby=nome'),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = json.decode(resposta.body) as List<dynamic>;
      return lista
          .map((item) => Estado.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Falha ao carregar estados: ${resposta.statusCode}');
  }

  // Listar municípios de um estado (bônus — usado opcionalmente).
  Future<List<String>> listarMunicipios(String sigla) async {
    final resposta = await http.get(
      Uri.parse('$_baseUrl/estados/$sigla/municipios?orderby=nome'),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = json.decode(resposta.body) as List<dynamic>;
      return lista.map<String>((item) => item['nome'] as String).toList();
    }
    throw Exception('Falha ao carregar municípios: ${resposta.statusCode}');
  }
}
