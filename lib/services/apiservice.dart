import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_apli/services/navigation_service.dart';

class ApiService {
  static const String baseUrl =
      "https://street-commotion-panther.ngrok-free.dev";

  // ── SESSÃO (TOKENS) ─────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> salvarRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  static Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Mantido por compatibilidade, caso algo no app ainda chame limparToken().
  static Future<void> limparToken() => limparSessao();

  static int? _usuarioIdFromToken(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;

      final payloadNormalizado = base64Url.normalize(partes[1]);
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(payloadNormalizado)),
      ) as Map<String, dynamic>;

      final sub = payload['sub'];
      if (sub == null) return null;

      return int.tryParse(sub.toString());
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getUsuarioId() async {
    final token = await getToken();
    if (token == null) return null;
    return _usuarioIdFromToken(token);
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Tenta trocar o refresh_token salvo por um access_token novo.
  /// Retorna true se conseguiu (e já salvou o novo token).
  static Future<bool> tentarRenovarToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    try {
      final url = Uri.parse('$baseUrl/auth/refresh');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refresh',
        },
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      final novoAccessToken = data['access_token'];
      if (novoAccessToken == null) return false;

      await salvarToken(novoAccessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Wrapper central de todas as chamadas HTTP. Quando uma rota autenticada
  /// (`auth: true`) responde 401, tenta renovar o access_token e refaz a
  /// chamada UMA vez. Se a renovação falhar, limpa a sessão e manda o
  /// usuário pro login.
  static Future<http.Response> _enviarRequisicao(
    String metodo,
    Uri url, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool tentandoNovamente = false,
  }) async {
    final headers = await _headers(auth: auth);
    final bodyJson = body != null ? jsonEncode(body) : null;

    http.Response response;
    switch (metodo) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(url, headers: headers, body: bodyJson);
        break;
      case 'PUT':
        response = await http.put(url, headers: headers, body: bodyJson);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Método HTTP não suportado: $metodo');
    }

    if (response.statusCode == 401 && auth && !tentandoNovamente) {
      final renovou = await tentarRenovarToken();

      if (renovou) {
        return _enviarRequisicao(
          metodo,
          url,
          body: body,
          auth: auth,
          tentandoNovamente: true,
        );
      } else {
        await limparSessao();
        redirecionarParaLogin();
      }
    }

    return response;
  }

  // ── AUTH ─────────────────────────────────────────────────

  static Future<String> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await _enviarRequisicao(
      'POST',
      url,
      body: {'email_institucional': email, 'senha': senha},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      await salvarToken(accessToken);
      if (refreshToken != null) await salvarRefreshToken(refreshToken);

      return accessToken;
    } else {
      throw Exception('Login falhou: ${response.statusCode}');
    }
  }

  static Future<void> criarConta(String nome, String email, String senha) async {
    final url = Uri.parse('$baseUrl/auth/criar_conta');
    final response = await _enviarRequisicao(
      'POST',
      url,
      body: {
        'nome': nome,
        'email_institucional': email,
        'senha': senha,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao criar conta');
    }
  }

  static Future<void> logout() async {
    final url = Uri.parse('$baseUrl/config/logout');
    try {
      await _enviarRequisicao('POST', url, auth: true);
    } catch (_) {
      // mesmo se a chamada falhar (sem internet, etc), limpa local de qualquer forma
    }
    await limparSessao();
  }

  // ── MERCADO ──────────────────────────────────────────────

  static Future<List<dynamic>> buscarAcoes() async {
    final url = Uri.parse('$baseUrl/mercado/acoes');
    final response = await _enviarRequisicao('GET', url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> buscarIndices() async {
    final url = Uri.parse('$baseUrl/mercado/indices');
    final response = await _enviarRequisicao('GET', url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> buscarGrafico(
    String simbolo,
    String periodo,
  ) async {
    final url = Uri.parse('$baseUrl/mercado/grafico/$simbolo?periodo=$periodo');
    final response = await _enviarRequisicao('GET', url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Erro: ${response.statusCode}');
  }

  // ── FAVORITOS ────────────────────────────────────────────

  static Future<List<dynamic>> listarFavoritosAcoes() async {
    final url = Uri.parse('$baseUrl/favoritos/acoes');
    final response = await _enviarRequisicao('GET', url, auth: true);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarFavoritoAcao(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/acoes');
    final response = await _enviarRequisicao(
      'POST',
      url,
      body: {'codigo': codigo},
      auth: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao favoritar: ${response.statusCode}');
    }
  }

  static Future<void> removerFavoritoAcao(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/acoes/$codigo');
    final response = await _enviarRequisicao('DELETE', url, auth: true);

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover favorito: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> listarFavoritosFundos() async {
    final url = Uri.parse('$baseUrl/favoritos/fundos');
    final response = await _enviarRequisicao('GET', url, auth: true);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarFavoritoFundo(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/fundos');
    final response = await _enviarRequisicao(
      'POST',
      url,
      body: {'codigo': codigo},
      auth: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao favoritar fundo: ${response.statusCode}');
    }
  }

  static Future<void> removerFavoritoFundo(String codigo) async {
    final url = Uri.parse('$baseUrl/favoritos/fundos/$codigo');
    final response = await _enviarRequisicao('DELETE', url, auth: true);

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover fundo favorito: ${response.statusCode}');
    }
  }

  // ── CARTEIRA ─────────────────────────────────────────────

  static Future<List<dynamic>> buscarCarteiraAtualizada() async {
    final url = Uri.parse('$baseUrl/carteira/simular/atualizado');
    final response = await _enviarRequisicao('GET', url, auth: true);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro: ${response.statusCode}');
  }

  static Future<void> adicionarAtivoCarteira(String codigo, int quantidade) async {
    final url = Uri.parse('$baseUrl/carteira/simular');
    final response = await _enviarRequisicao(
      'POST',
      url,
      body: {'codigo': codigo, 'quantidade': quantidade},
      auth: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao adicionar ativo');
    }
  }

  static Future<void> atualizarAtivoCarteira(int itemId, int quantidade) async {
    final url = Uri.parse('$baseUrl/carteira/simular/$itemId');
    final response = await _enviarRequisicao(
      'PUT',
      url,
      body: {'quantidade': quantidade},
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar ativo: ${response.statusCode}');
    }
  }

  static Future<void> removerAtivoCarteira(int itemId) async {
    final url = Uri.parse('$baseUrl/carteira/simular/$itemId');
    final response = await _enviarRequisicao('DELETE', url, auth: true);

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover ativo: ${response.statusCode}');
    }
  }

  // ── EDUCAÇÃO ─────────────────────────────────────────────

  static Future<List<dynamic>> listarVideos() async {
    final url = Uri.parse('$baseUrl/educacao/videos');
    final response = await _enviarRequisicao('GET', url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao carregar vídeos: ${response.statusCode}');
  }

  static Future<List<dynamic>> listarVideosPorTema(String tema) async {
    final url = Uri.parse('$baseUrl/educacao/videos/tema/$tema');
    final response = await _enviarRequisicao('GET', url);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Nenhum vídeo encontrado para esse tema');
  }
  // ── ONBOARDING ───────────────────────────────────────────

  static Future<bool> jaViuBoasVindas() async {
   final prefs = await SharedPreferences.getInstance();
   return prefs.getBool('ja_viu_boasvindas') ?? false;
  }

  static Future<void> marcarBoasVindasVistas() async {
    final prefs = await SharedPreferences.getInstance();
   await prefs.setBool('ja_viu_boasvindas', true);
  }
}
