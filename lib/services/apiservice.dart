import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> buscarAcoes() async {
  final url = Uri.parse('http://10.0.2.2:8000/favoritos/acoes');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erro: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> buscarGrafico(String simbolo) async {
  final url = Uri.parse('http://10.0.2.2:8000/grafico/$simbolo');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Formato de dados inesperado');
    }
  } else {
    throw Exception('Erro: ${response.statusCode}');
  }
}
