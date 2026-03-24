import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
 static const String baseUrl = "http://10.0.2.2:8000";

  //açao do mercado
  static Future<List<dynamic>> buscarAcoes() async {
    final url = Uri.parse('$baseUrl/mercado/acoes');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro: ${response.statusCode}');
    }
  }

  // grafico da açao
  static Future<List<Map<String, dynamic>>> buscarGrafico(String simbolo) async {
  final url = Uri.parse('$baseUrl/mercado/grafico/$simbolo');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Erro: ${response.statusCode}');
  }
}

  // noticias
  static Future<List<dynamic>> buscarNoticias(String simbolo) async {
    final url = Uri.parse('$baseUrl/mercado/noticias/$simbolo');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro: ${response.statusCode}');
    }
  }
}