import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meu_apli/services/navigation_service.dart';

class ApiService {
  static const String baseUrl =
      "https://lanuginose-unsyllogistically-dianna.ngrok-free.dev";

  // ============================================================
  // SESSÃO (TOKENS)
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('refresh_token');
  }

  static Future<void> salvarToken(
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'access_token',
      token,
    );
  }

  static Future<void> salvarRefreshToken(
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'refresh_token',
      token,
    );
  }

  // ============================================================
  // ADMIN
  // ============================================================

  static Future<void> salvarAdmin(
    bool admin,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'is_admin',
      admin,
    );
  }

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('is_admin') ?? false;
  }

  static Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('is_admin');
  }

  static Future<void> limparToken() async {
    await limparSessao();
  }

  // ============================================================
  // USUÁRIO ID PELO TOKEN
  // ============================================================

  static int? _usuarioIdFromToken(
    String token,
  ) {
    try {
      final partes = token.split('.');

      if (partes.length != 3) {
        return null;
      }

      final payloadNormalizado =
          base64Url.normalize(
        partes[1],
      );

      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(
            payloadNormalizado,
          ),
        ),
      ) as Map<String, dynamic>;

      final sub = payload['sub'];

      if (sub == null) {
        return null;
      }

      return int.tryParse(
        sub.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getUsuarioId() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    return _usuarioIdFromToken(
      token,
    );
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Future<Map<String, String>> _headers({
    bool auth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await getToken();

      if (token != null) {
        headers['Authorization'] =
            'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================
  // RENOVAÇÃO DO TOKEN
  // ============================================================

  static Future<bool> tentarRenovarToken() async {
    final refresh = await getRefreshToken();

    if (refresh == null) {
      return false;
    }

    try {
      final url = Uri.parse(
        '$baseUrl/auth/refresh',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $refresh',
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(
        response.body,
      );

      final novoAccessToken =
          data['access_token'];

      if (novoAccessToken == null) {
        return false;
      }

      await salvarToken(
        novoAccessToken,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // REQUISIÇÃO CENTRAL
  // ============================================================

  static Future<http.Response>
      _enviarRequisicao(
    String metodo,
    Uri url, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool tentandoNovamente = false,
  }) async {
    final headers =
        await _headers(
      auth: auth,
    );

    final bodyJson =
        body != null
            ? jsonEncode(body)
            : null;

    http.Response response;

    switch (metodo) {
      case 'GET':
        response = await http.get(
          url,
          headers: headers,
        );
        break;

      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: bodyJson,
        );
        break;

      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: bodyJson,
        );
        break;

      case 'DELETE':
        response = await http.delete(
          url,
          headers: headers,
        );
        break;

      default:
        throw Exception(
          'Método HTTP não suportado: $metodo',
        );
    }

    // ==========================================================
    // TOKEN EXPIRADO
    // ==========================================================

    if (response.statusCode == 401 &&
        auth &&
        !tentandoNovamente) {
      final renovou =
          await tentarRenovarToken();

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

  // ============================================================
  // AUTH - LOGIN
  // ============================================================

  static Future<String> login(
    String email,
    String senha,
  ) async {
    final url = Uri.parse(
      '$baseUrl/auth/login',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'email_institucional': email,
        'senha': senha,
      },
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      final accessToken =
          data['access_token'];

      final refreshToken =
          data['refresh_token'];

      final admin =
          data['admin'] ?? false;

      if (accessToken == null) {
        throw Exception(
          'Token de acesso não recebido.',
        );
      }

      await salvarToken(
        accessToken,
      );

      if (refreshToken != null) {
        await salvarRefreshToken(
          refreshToken,
        );
      }

      await salvarAdmin(
        admin == true,
      );

      print('====================================');
      print('LOGIN REALIZADO');
      print('ADMIN: ${admin == true}');
      print('====================================');

      // ========================================================
      // SALVAR TOKEN FCM
      // ========================================================

      try {
        final fcmToken =
            await FirebaseMessaging
                .instance
                .getToken();

        if (fcmToken != null) {
          await salvarFCMToken(
            fcmToken,
          );

          print(
            'FCM TOKEN VINCULADO AO USUÁRIO COM SUCESSO!',
          );
        }
      } catch (e) {
        print(
          'ERRO AO VINCULAR FCM TOKEN: $e',
        );
      }

      return accessToken;
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Login falhou: '
                '${response.statusCode}',
      );
    } catch (_) {
      throw Exception(
        'Login falhou: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // CRIAR CONTA
  // ============================================================

  static Future<void> criarConta(
    String nome,
    String email,
    String senha,
  ) async {
    final url = Uri.parse(
      '$baseUrl/auth/criar_conta',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'nome': nome,
        'email_institucional': email,
        'senha': senha,
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      try {
        final data =
            jsonDecode(response.body);

        throw Exception(
          data['detail'] ??
              'Erro ao criar conta',
        );
      } catch (_) {
        throw Exception(
          'Erro ao criar conta: '
          '${response.statusCode}',
        );
      }
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final url = Uri.parse(
      '$baseUrl/config/logout',
    );

    try {
      await _enviarRequisicao(
        'POST',
        url,
        auth: true,
      );
    } catch (_) {
      // Mesmo se falhar, limpa a sessão local.
    }

    await limparSessao();
  }

  // ============================================================
  // MERCADO - AÇÕES
  // ============================================================

  static Future<List<dynamic>>
      buscarAcoes() async {
    final url = Uri.parse(
      '$baseUrl/mercado/acoes',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // MERCADO - FUNDOS
  // ============================================================

  static Future<List<dynamic>>
      buscarFundos() async {
    final url = Uri.parse(
      '$baseUrl/mercado/fundos',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // MERCADO - ÍNDICES
  // ============================================================

  static Future<Map<String, dynamic>>
      buscarIndices() async {
    final url = Uri.parse(
      '$baseUrl/mercado/indices',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // MERCADO - GRÁFICO
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      buscarGrafico(
    String simbolo,
    String periodo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/mercado/grafico/'
      '$simbolo?periodo=$periodo',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(
          response.body,
        ),
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // FAVORITOS - AÇÕES
  // ============================================================

  static Future<List<dynamic>>
      listarFavoritosAcoes() async {
    final url = Uri.parse(
      '$baseUrl/favoritos/acoes',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  static Future<void>
      adicionarFavoritoAcao(
    String codigo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/favoritos/acoes',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'codigo': codigo,
      },
      auth: true,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Erro ao favoritar: '
        '${response.statusCode}',
      );
    }
  }

  static Future<void>
      removerFavoritoAcao(
    String codigo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/favoritos/acoes/$codigo',
    );

    final response =
        await _enviarRequisicao(
      'DELETE',
      url,
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao remover favorito: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // FAVORITOS - FUNDOS
  // ============================================================

  static Future<List<dynamic>>
      listarFavoritosFundos() async {
    final url = Uri.parse(
      '$baseUrl/favoritos/fundos',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  static Future<void>
      adicionarFavoritoFundo(
    String codigo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/favoritos/fundos',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'codigo': codigo,
      },
      auth: true,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Erro ao favoritar fundo: '
        '${response.statusCode}',
      );
    }
  }

  static Future<void>
      removerFavoritoFundo(
    String codigo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/favoritos/fundos/$codigo',
    );

    final response =
        await _enviarRequisicao(
      'DELETE',
      url,
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao remover fundo favorito: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // CARTEIRA
  // ============================================================

  static Future<List<dynamic>>
      buscarCarteiraAtualizada() async {
    final url = Uri.parse(
      '$baseUrl/carteira/simular/atualizado',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  static Future<void>
      adicionarAtivoCarteira(
    String codigo,
    int quantidade,
  ) async {
    final url = Uri.parse(
      '$baseUrl/carteira/simular',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'codigo': codigo,
        'quantidade': quantidade,
      },
      auth: true,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      try {
        final data =
            jsonDecode(response.body);

        throw Exception(
          data['detail'] ??
              'Erro ao adicionar ativo',
        );
      } catch (_) {
        throw Exception(
          'Erro ao adicionar ativo: '
          '${response.statusCode}',
        );
      }
    }
  }

  static Future<void>
      atualizarAtivoCarteira(
    int itemId,
    int quantidade,
  ) async {
    final url = Uri.parse(
      '$baseUrl/carteira/simular/$itemId',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      body: {
        'quantidade': quantidade,
      },
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao atualizar ativo: '
        '${response.statusCode}',
      );
    }
  }

  static Future<void>
      removerAtivoCarteira(
    int itemId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/carteira/simular/$itemId',
    );

    final response =
        await _enviarRequisicao(
      'DELETE',
      url,
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao remover ativo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // EDUCAÇÃO - VÍDEOS
  // ============================================================

  static Future<List<dynamic>>
      listarVideos() async {
    final url = Uri.parse(
      '$baseUrl/educacao/videos',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro ao carregar vídeos: '
      '${response.statusCode}',
    );
  }

  static Future<List<dynamic>>
      listarVideosPorTema(
    String tema,
  ) async {
    final url = Uri.parse(
      '$baseUrl/educacao/videos/tema/$tema',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Nenhum vídeo encontrado para esse tema',
    );
  }

  // ============================================================
  // EDUCAÇÃO - MATERIAIS
  // ============================================================

  static Future<List<dynamic>>
      listarMateriais() async {
    final url = Uri.parse(
      '$baseUrl/educacao/materiais',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      final dados =
          jsonDecode(response.body);

      if (dados is! List) {
        throw Exception(
          'Formato inválido retornado '
          'pela API de materiais.',
        );
      }

      final materiais =
          List<dynamic>.from(dados);

      // ========================================================
      // CORRIGE A URL DO ARQUIVO
      // ========================================================

      for (final material in materiais) {
        if (material is! Map) {
          continue;
        }

        final caminho =
            material['url'];

        if (caminho == null) {
          continue;
        }

        final caminhoString =
            caminho.toString().trim();

        if (caminhoString.isEmpty) {
          continue;
        }

        if (caminhoString.startsWith(
              'http://',
            ) ||
            caminhoString.startsWith(
              'https://',
            )) {
          material['url'] =
              caminhoString;
        } else if (caminhoString.startsWith(
          '/',
        )) {
          material['url'] =
              '$baseUrl$caminhoString';
        } else {
          material['url'] =
              '$baseUrl/$caminhoString';
        }

        print('====================================');
        print('MATERIAL CARREGADO');
        print('ID: ${material['id']}');
        print('TÍTULO: ${material['titulo']}');
        print('URL FINAL: ${material['url']}');
        print('====================================');
      }

      return materiais;
    }

    throw Exception(
      'Erro ao carregar materiais: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // ADMIN - ADICIONAR MATERIAL
  // UPLOAD DE PDF / EPUB / MOBI
  // ============================================================

  static Future<void> adicionarMaterial({
    required String titulo,
    String? descricao,
    String? tema,
    required String caminhoArquivo,
  }) async {
    final url = Uri.parse(
      '$baseUrl/educacao/materiais',
    );

    final token = await getToken();

    final request =
        http.MultipartRequest(
      'POST',
      url,
    );

    // ==========================================================
    // AUTHORIZATION
    // ==========================================================

    if (token != null) {
      request.headers['Authorization'] =
          'Bearer $token';
    }

    // ==========================================================
    // CAMPOS
    // ==========================================================

    request.fields['titulo'] = titulo;

    if (descricao != null &&
        descricao.trim().isNotEmpty) {
      request.fields['descricao'] =
          descricao.trim();
    }

    if (tema != null &&
        tema.trim().isNotEmpty) {
      request.fields['tema'] =
          tema.trim();
    }

    // ==========================================================
    // ARQUIVO
    // ==========================================================

    final arquivo = File(
      caminhoArquivo,
    );

    if (!await arquivo.exists()) {
      throw Exception(
        'Arquivo não encontrado.',
      );
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'arquivo',
        caminhoArquivo,
      ),
    );

    print('====================================');
    print('ENVIANDO MATERIAL');
    print('TÍTULO: $titulo');
    print('ARQUIVO: $caminhoArquivo');
    print('====================================');

    // ==========================================================
    // ENVIAR
    // ==========================================================

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    print('====================================');
    print('RESPOSTA DO UPLOAD');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('====================================');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 401) {
      final renovou =
          await tentarRenovarToken();

      if (renovou) {
        return adicionarMaterial(
          titulo: titulo,
          descricao: descricao,
          tema: tema,
          caminhoArquivo: caminhoArquivo,
        );
      }

      await limparSessao();

      redirecionarParaLogin();

      throw Exception(
        'Sessão expirada.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'adicionar materiais.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao adicionar material.',
      );
    } catch (_) {
      throw Exception(
        'Erro ao adicionar material: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - EXCLUIR MATERIAL
  // ============================================================

  static Future<void> excluirMaterial(
    int materialId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/educacao/materiais/'
      '$materialId',
    );

    final response =
        await _enviarRequisicao(
      'DELETE',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'excluir materiais.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        'Material não encontrado.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao excluir material.',
      );
    } catch (_) {
      throw Exception(
        'Erro ao excluir material: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - VÍDEOS
  // ============================================================

  static Future<List<dynamic>>
      listarVideosAdmin() async {
    final url = Uri.parse(
      '$baseUrl/admin/videos/',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'acessar esta área.',
      );
    }

    throw Exception(
      'Erro ao carregar vídeos: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // ADMIN - ADICIONAR VÍDEO
  // ============================================================

  static Future<void>
      adicionarVideoAdmin({
    required String titulo,
    String? descricao,
    required String url,
    String? tema,
    String? duracao,
  }) async {
    final endpoint = Uri.parse(
      '$baseUrl/admin/videos/',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      endpoint,
      body: {
        'titulo': titulo,
        'descricao': descricao,
        'url': url,
        'tema': tema,
        'duracao': duracao,
      },
      auth: true,
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'adicionar vídeos.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao adicionar vídeo.',
      );
    } catch (_) {
      throw Exception(
        'Erro ao adicionar vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - EDITAR VÍDEO
  // ============================================================

  static Future<void>
      editarVideoAdmin({
    required int videoId,
    String? titulo,
    String? descricao,
    String? url,
    String? tema,
    String? duracao,
  }) async {
    final endpoint = Uri.parse(
      '$baseUrl/admin/videos/$videoId',
    );

    final Map<String, dynamic> dados = {};

    if (titulo != null) {
      dados['titulo'] = titulo;
    }

    if (descricao != null) {
      dados['descricao'] = descricao;
    }

    if (url != null) {
      dados['url'] = url;
    }

    if (tema != null) {
      dados['tema'] = tema;
    }

    if (duracao != null) {
      dados['duracao'] = duracao;
    }

    final response =
        await _enviarRequisicao(
      'PUT',
      endpoint,
      body: dados,
      auth: true,
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'editar vídeos.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao editar vídeo.',
      );
    } catch (_) {
      throw Exception(
        'Erro ao editar vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - EXCLUIR VÍDEO
  // ============================================================

  static Future<void>
      excluirVideoAdmin(
    int videoId,
  ) async {
    final endpoint = Uri.parse(
      '$baseUrl/admin/videos/$videoId',
    );

    final response =
        await _enviarRequisicao(
      'DELETE',
      endpoint,
      auth: true,
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Acesso negado. '
        'Apenas administradores podem '
        'excluir vídeos.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao excluir vídeo.',
      );
    } catch (_) {
      throw Exception(
        'Erro ao excluir vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // USUÁRIO - FCM TOKEN
  // ============================================================

  static Future<void>
      salvarFCMToken(
    String fcmToken,
  ) async {
    final url = Uri.parse(
      '$baseUrl/usuario/fcm-token',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      body: {
        'fcm_token': fcmToken,
      },
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao salvar token FCM: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // USUÁRIO - PERFIL
  // ============================================================

  static Future<Map<String, dynamic>>
      buscarPerfil() async {
    final url = Uri.parse(
      '$baseUrl/usuario/me',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // USUÁRIO - AVATAR
  // ============================================================

  static Future<void>
      atualizarAvatar(
    String avatar,
  ) async {
    final url = Uri.parse(
      '$baseUrl/usuario/avatar',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      body: {
        'avatar': avatar,
      },
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao atualizar avatar: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // NOTIFICAÇÕES - ENVIAR
  // ============================================================

  static Future<void>
      enviarNotificacao(
    String titulo,
    String mensagem, {
    String tipo = 'SISTEMA',
  }) async {
    final url = Uri.parse(
      '$baseUrl/notificacoes/enviar',
    );

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {
        'titulo': titulo,
        'mensagem': mensagem,
        'tipo': tipo,
      },
      auth: true,
    );

    if (response.statusCode != 200) {
      try {
        final data =
            jsonDecode(response.body);

        throw Exception(
          data['detail'] ??
              'Erro ao enviar notificação',
        );
      } catch (_) {
        throw Exception(
          'Erro ao enviar notificação: '
          '${response.statusCode}',
        );
      }
    }
  }

  // ============================================================
  // NOTIFICAÇÕES - LISTAR
  // ============================================================

  static Future<List<dynamic>>
      listarNotificacoes() async {
    final url = Uri.parse(
      '$baseUrl/notificacoes',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Erro ao carregar notificações: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // NOTIFICAÇÕES - CONTAR NÃO LIDAS
  // ============================================================

  static Future<int>
      contarNotificacoesNaoLidas() async {
    final url = Uri.parse(
      '$baseUrl/notificacoes/nao-lidas',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      return data['nao_lidas'] ?? 0;
    }

    throw Exception(
      'Erro ao contar notificações: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // NOTIFICAÇÕES - MARCAR COMO LIDA
  // ============================================================

  static Future<void>
      marcarNotificacaoComoLida(
    int notificacaoId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/notificacoes/'
      '$notificacaoId/ler',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      auth: true,
    );

    if (response.statusCode != 200) {
      try {
        final data =
            jsonDecode(response.body);

        throw Exception(
          data['detail'] ??
              'Erro ao marcar notificação como lida',
        );
      } catch (_) {
        throw Exception(
          'Erro ao marcar notificação como lida: '
          '${response.statusCode}',
        );
      }
    }
  }
}