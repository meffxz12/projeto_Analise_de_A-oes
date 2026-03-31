import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      "https://lanuginose-unsyllogistically-dianna.ngrok-free.dev";

  // ── TOKEN ────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> limparToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── AUTH ─────────────────────────────────────────────────

  static Future<String> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'email_institucional': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await salvarToken(token);
      return token;
    } else {
      throw Exception('Login falhou: ${response.statusCode}');
    }
  }

static Future<void> criarConta(String nome, String email, String senha) async {
  final url = Uri.parse('$baseUrl/auth/criar_conta');
  final response = await http.post(
    url,
    headers: await _headers(),
    body: jsonEncode({
      'nome': nome,
      'email_institucional': email, // ← era 'email', campo errado
      'senha': senha,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    final data = jsonDecode(response.body);
    throw Exception(data['detail'] ?? 'Erro ao criar conta');
  }
}

  static Future<void> logout() async {
    final url = Uri.parse('$baseUrl/config/logout');
    await http.post(url, headers: await _headers(auth: true));
    await limparToken();
  }

  // ── MERCADO ──────────────────────────────────────────────

  static Future<List<dynamic>> buscarAcoes() async {
    final url = Uri.parse('$baseUrl/mercado/acoes');
    final response = await http.get(url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> buscarIndices() async {
    final url = Uri.parse('$baseUrl/mercado/indices');
    final response = await http.get(url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> buscarGrafico(
    String simbolo,
    String periodo,
  ) async {
    final url = Uri.parse('$baseUrl/mercado/grafico/$simbolo?periodo=$periodo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Erro: ${response.statusCode}');
  }

  // ── FAVORITOS ────────────────────────────────────────────

  static Future<List<dynamic>> listarFavoritosAcoes() async {
    final url = Uri.parse('$baseUrl/favoritos/acoes');
    final response = await http.get(url, headers: await _headers(auth: true));

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarFavoritoAcao(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/acoes');
    final response = await http.post(
      url,
      headers: await _headers(auth: true),
      body: jsonEncode({'codigo': codigo}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao favoritar: ${response.statusCode}');
    }
  }

  static Future<void> removerFavoritoAcao(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/acoes/$codigo');
    final response = await http.delete(url, headers: await _headers(auth: true));

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover favorito: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> listarFavoritosFundos() async {
    final url = Uri.parse('$baseUrl/favoritos/fundos');
    final response = await http.get(url, headers: await _headers(auth: true));

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarFavoritoFundo(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/fundos');
    final response = await http.post(
      url,
      headers: await _headers(auth: true),
      body: jsonEncode({'codigo': codigo}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao favoritar fundo: ${response.statusCode}');
    }
  }

  static Future<void> removerFavoritoFundo(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/fundos/$codigo');
    final response = await http.delete(url, headers: await _headers(auth: true));

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover fundo favorito: ${response.statusCode}');
    }
  }

  // ── CARTEIRA ─────────────────────────────────────────────

  static Future<List<dynamic>> buscarCarteiraAtualizada() async {
    final url = Uri.parse('$baseUrl/carteira/simular/atualizado');
    final response = await http.get(url, headers: await _headers(auth: true));

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarAtivoCarteira(String codigo, int quantidade) async {
    final url = Uri.parse('$baseUrl/carteira/simular');
    final response = await http.post(
      url,
      headers: await _headers(auth: true),
      body: jsonEncode({'codigo': codigo, 'quantidade': quantidade}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao adicionar ativo');
    }
  }

  static Future<void> atualizarAtivoCarteira(int itemId, int quantidade) async {
    final url = Uri.parse('$baseUrl/carteira/simular/$itemId');
    final response = await http.put(
      url,
      headers: await _headers(auth: true),
      body: jsonEncode({'quantidade': quantidade}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar ativo: ${response.statusCode}');
    }
  }

  static Future<void> removerAtivoCarteira(int itemId) async {
    final url = Uri.parse('$baseUrl/carteira/simular/$itemId');
    final response = await http.delete(url, headers: await _headers(auth: true));

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover ativo: ${response.statusCode}');
    }
  }
}