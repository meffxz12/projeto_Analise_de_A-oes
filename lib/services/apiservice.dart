import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meu_apli/services/navigation_service.dart';

class ApiService {
  static const String baseUrl =
      'https://lanuginose-unsyllogistically-dianna.ngrok-free.dev';

  // ============================================================
  // FIREBASE AUTH
  // ============================================================

  static final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance;

  // ============================================================
  // DOMÍNIOS PERMITIDOS
  // ============================================================

  static const List<String> dominiosIfmaPermitidos = [
    '@ifma.edu.br',
    '@acad.ifma.edu.br',
  ];

  // ============================================================
  // VALIDAR E-MAIL INSTITUCIONAL
  // ============================================================

  static bool emailInstitucionalValido(String email) {
    final emailNormalizado = email.trim().toLowerCase();

    return dominiosIfmaPermitidos.any(
      (dominio) => emailNormalizado.endsWith(dominio),
    );
  }

  // ============================================================
  // SESSÃO
  // ============================================================

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

  // ============================================================
  // ADMIN
  // ============================================================

  static Future<void> salvarAdmin(bool admin) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_admin', admin);
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

  static int? _usuarioIdFromToken(String token) {
    try {
      final partes = token.split('.');

      if (partes.length != 3) {
        return null;
      }

      final payloadNormalizado =
          base64Url.normalize(partes[1]);

      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(payloadNormalizado),
        ),
      ) as Map<String, dynamic>;

      final sub = payload['sub'];

      if (sub == null) {
        return null;
      }

      return int.tryParse(sub.toString());
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getUsuarioId() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    return _usuarioIdFromToken(token);
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
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================
  // RENOVAÇÃO DO TOKEN
  // ============================================================

  static Future<bool> tentarRenovarToken() async {
    final refresh = await getRefreshToken();

    print('REFRESH TOKEN SALVO: $refresh');

    if (refresh == null) {
      print('SEM REFRESH TOKEN -> logout forçado');
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/auth/refresh');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refresh',
        },
      );

      print('REFRESH STATUS: ${response.statusCode}');
      print('REFRESH BODY: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      final novoAccessToken = data['access_token'];

      if (novoAccessToken == null) {
        return false;
      }

      await salvarToken(novoAccessToken);

      return true;
    } catch (e) {
      print('ERRO NO REFRESH: $e');

      return false;
    }
  }

  // ============================================================
  // REQUISIÇÃO CENTRAL
  // ============================================================

  static Future<http.Response> _enviarRequisicao(
    String metodo,
    Uri url, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool tentandoNovamente = false,
  }) async {
    final headers = await _headers(auth: auth);

    final bodyJson =
        body != null ? jsonEncode(body) : null;

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

  // ============================================================
  // FIREBASE - CRIAR CONTA
  // ============================================================

  static Future<String> criarUsuarioFirebase(
    String email,
    String senha,
  ) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: senha,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Não foi possível criar o usuário no Firebase.',
        );
      }

      return user.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception(
            'Este e-mail já está cadastrado.',
          );

        case 'invalid-email':
          throw Exception(
            'O e-mail informado é inválido.',
          );

        case 'weak-password':
          throw Exception(
            'A senha é muito fraca.',
          );

        case 'operation-not-allowed':
          throw Exception(
            'Cadastro por e-mail e senha não está '
            'habilitado no Firebase.',
          );

        default:
          throw Exception(
            'Erro ao criar conta no Firebase: ${e.message}',
          );
      }
    }
  }

  // ============================================================
  // FIREBASE - ENVIAR VERIFICAÇÃO
  // ============================================================

  static Future<void> enviarEmailVerificacao() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'Nenhum usuário do Firebase está conectado.',
      );
    }

    await user.sendEmailVerification();
  }

  // ============================================================
  // FIREBASE - VERIFICAR E-MAIL
  // ============================================================

  static Future<bool> verificarEmailFirebase() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final usuarioAtualizado =
        _firebaseAuth.currentUser;

    return usuarioAtualizado?.emailVerified ?? false;
  }

  // ============================================================
  // FIREBASE - RECARREGAR
  // ============================================================

  static Future<void> recarregarUsuarioFirebase() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return;
    }

    await user.reload();
  }

  // ============================================================
  // FIREBASE - UID
  // ============================================================

  static String? getFirebaseUid() {
    return _firebaseAuth.currentUser?.uid;
  }

  // ============================================================
  // FIREBASE - LOGOUT
  // ============================================================

  static Future<void> logoutFirebase() async {
    await _firebaseAuth.signOut();
  }

  // ============================================================
  // AUTH - CRIAR CONTA
  // ============================================================

  static Future<void> criarConta(
    String nome,
    String email,
    String senha,
  ) async {
    User? firebaseUser;

    try {
      final emailNormalizado =
          email.trim().toLowerCase();

      // ========================================================
      // VALIDAR DOMÍNIO
      // ========================================================

      if (!emailInstitucionalValido(emailNormalizado)) {
        throw Exception(
          'Use um e-mail institucional. '
          'Permitidos: @ifma.edu.br ou @acad.ifma.edu.br',
        );
      }

      // ========================================================
      // CRIAR NO FIREBASE
      // ========================================================

      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailNormalizado,
        password: senha,
      );

      firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Não foi possível criar a conta no Firebase.',
        );
      }

      final firebaseUid = firebaseUser.uid;

      print('====================================');
      print('USUÁRIO FIREBASE CRIADO');
      print('UID: $firebaseUid');
      print('EMAIL: $emailNormalizado');
      print('====================================');

      // ========================================================
      // ENVIAR VERIFICAÇÃO
      // ========================================================

      await firebaseUser.sendEmailVerification();

      print('====================================');
      print('E-MAIL DE VERIFICAÇÃO ENVIADO');
      print('PARA: $emailNormalizado');
      print('====================================');

      // ========================================================
      // CADASTRAR NO FASTAPI
      // ========================================================

      final url =
          Uri.parse('$baseUrl/auth/criar_conta');

      final response = await _enviarRequisicao(
        'POST',
        url,
        body: {
          'nome': nome.trim(),
          'email_institucional': emailNormalizado,
          'firebase_uid': firebaseUid,
        },
      );

      // ========================================================
      // ERRO FASTAPI
      // ========================================================

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        try {
          final data = jsonDecode(response.body);

          throw Exception(
            data['detail'] ??
                'Erro ao criar conta no servidor.',
          );
        } catch (e) {
          if (e is Exception) {
            rethrow;
          }

          throw Exception(
            'Erro ao criar conta: '
            '${response.statusCode}',
          );
        }
      }

      print('====================================');
      print('CADASTRO CONCLUÍDO');
      print('FIREBASE UID: $firebaseUid');
      print('FASTAPI: OK');
      print('VERIFICAÇÃO: E-MAIL ENVIADO');
      print('====================================');

      // ========================================================
      // NÃO DEIXAR LOGADO
      // ========================================================

      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      print(
        'ERRO FIREBASE CADASTRO: '
        '${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'email-already-in-use':
          throw Exception(
            'Este e-mail já possui uma conta.',
          );

        case 'invalid-email':
          throw Exception(
            'O e-mail informado é inválido.',
          );

        case 'weak-password':
          throw Exception(
            'A senha deve possuir pelo menos 6 caracteres.',
          );

        case 'operation-not-allowed':
          throw Exception(
            'O cadastro por e-mail e senha não está '
            'habilitado no Firebase.',
          );

        default:
          throw Exception(
            'Erro ao criar conta: ${e.message}',
          );
      }
    } catch (e) {
      print('ERRO NO CADASTRO: $e');

      // ========================================================
      // APAGAR FIREBASE SE FASTAPI FALHAR
      // ========================================================

      try {
        if (firebaseUser != null) {
          await firebaseUser.delete();

          print(
            'Usuário Firebase removido após falha no cadastro.',
          );
        }
      } catch (erroDelete) {
        print(
          'Não foi possível remover usuário Firebase: '
          '$erroDelete',
        );
      }

      rethrow;
    }
  }

  // ============================================================
  // AUTH - REENVIAR VERIFICAÇÃO
  // ============================================================

  static Future<void> reenviarEmailVerificacao(
    String email,
    String senha,
  ) async {
    try {
      final emailNormalizado =
          email.trim().toLowerCase();

      if (!emailInstitucionalValido(emailNormalizado)) {
        throw Exception(
          'Use um e-mail institucional.',
        );
      }

      final credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: emailNormalizado,
        password: senha,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Usuário não encontrado.',
        );
      }

      await user.sendEmailVerification();

      await _firebaseAuth.signOut();

      print(
        'E-mail de verificação reenviado.',
      );
    } on FirebaseAuthException catch (e) {
      print(
        'ERRO AO REENVIAR VERIFICAÇÃO: '
        '${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            'Usuário não encontrado.',
          );

        case 'wrong-password':
        case 'invalid-credential':
          throw Exception(
            'E-mail ou senha incorretos.',
          );

        case 'invalid-email':
          throw Exception(
            'E-mail inválido.',
          );

        default:
          throw Exception(
            'Erro ao reenviar e-mail: ${e.message}',
          );
      }
    }
  }

  // ============================================================
  // AUTH - LOGIN
  //
  // 1. Firebase autentica e-mail/senha
  // 2. Firebase fornece ID Token
  // 3. ID Token é enviado ao FastAPI
  // 4. FastAPI valida o token
  // 5. FastAPI devolve seus JWTs
  // ============================================================

  static Future<String> login(
    String email,
    String senha,
  ) async {
    try {
      final emailNormalizado =
          email.trim().toLowerCase();

      // ========================================================
      // VALIDAR DOMÍNIO
      // ========================================================

      if (!emailInstitucionalValido(emailNormalizado)) {
        throw Exception(
          'Use um e-mail institucional.',
        );
      }

      // ========================================================
      // LOGIN FIREBASE
      // ========================================================

      final credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: emailNormalizado,
        password: senha,
      );

      User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Não foi possível autenticar no Firebase.',
        );
      }

      print('====================================');
      print('LOGIN FIREBASE REALIZADO');
      print('UID: ${firebaseUser.uid}');
      print('EMAIL: ${firebaseUser.email}');
      print('====================================');

      // ========================================================
      // RECARREGAR USUÁRIO
      // ========================================================

      await firebaseUser.reload();

      firebaseUser =
          _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        throw Exception(
          'Usuário Firebase não encontrado.',
        );
      }

      // ========================================================
      // VERIFICAR E-MAIL
      // ========================================================

      if (!firebaseUser.emailVerified) {
        await _firebaseAuth.signOut();

        throw Exception(
          'Seu e-mail ainda não foi verificado. '
          'Verifique sua caixa de entrada antes de entrar.',
        );
      }

      // ========================================================
      // PEGAR ID TOKEN DO FIREBASE
      // ========================================================

      final firebaseIdToken =
          await firebaseUser.getIdToken(true);

      if (firebaseIdToken == null ||
          firebaseIdToken.isEmpty) {
        await _firebaseAuth.signOut();

        throw Exception(
          'Não foi possível obter o token do Firebase.',
        );
      }

      print('====================================');
      print('FIREBASE ID TOKEN OBTIDO');
      print('TOKEN PRESENTE: SIM');
      print('====================================');

      // ========================================================
      // ENVIAR TOKEN PARA FASTAPI
      // ========================================================

      final url =
          Uri.parse('$baseUrl/auth/login');

      final response = await _enviarRequisicao(
        'POST',
        url,
        body: {
          'firebase_id_token': firebaseIdToken,
        },
      );

      print('====================================');
      print('RESPOSTA FASTAPI LOGIN');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('====================================');

      // ========================================================
      // ERRO FASTAPI
      // ========================================================

      if (response.statusCode != 200) {
        await _firebaseAuth.signOut();

        try {
          final data =
              jsonDecode(response.body);

          throw Exception(
            data['detail'] ??
                'Login falhou: '
                    '${response.statusCode}',
          );
        } catch (e) {
          if (e is Exception) {
            rethrow;
          }

          throw Exception(
            'Login falhou: '
            '${response.statusCode}',
          );
        }
      }

      // ========================================================
      // LER RESPOSTA
      // ========================================================

      final data =
          jsonDecode(response.body);

      final accessToken =
          data['access_token'];

      final refreshToken =
          data['refresh_token'];

      final admin =
          data['admin'] ?? false;

      if (accessToken == null) {
        await _firebaseAuth.signOut();

        throw Exception(
          'Token de acesso não recebido.',
        );
      }

      // ========================================================
      // SALVAR TOKENS FASTAPI
      // ========================================================

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
      print('LOGIN COMPLETO');
      print('FIREBASE UID: ${firebaseUser.uid}');
      print(
        'EMAIL VERIFICADO: '
        '${firebaseUser.emailVerified}',
      );
      print('ADMIN: ${admin == true}');
      print('====================================');

      // ========================================================
      // SALVAR TOKEN FCM
      // ========================================================

      try {
        final fcmToken =
            await FirebaseMessaging.instance.getToken();

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
    } on FirebaseAuthException catch (e) {
      print(
        'ERRO FIREBASE LOGIN: '
        '${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            'Usuário não encontrado.',
          );

        case 'wrong-password':
        case 'invalid-credential':
          throw Exception(
            'E-mail ou senha incorretos.',
          );

        case 'invalid-email':
          throw Exception(
            'E-mail inválido.',
          );

        case 'user-disabled':
          throw Exception(
            'Esta conta foi desativada.',
          );

        case 'too-many-requests':
          throw Exception(
            'Muitas tentativas. '
            'Tente novamente mais tarde.',
          );

        default:
          throw Exception(
            'Erro ao fazer login: ${e.message}',
          );
      }
    } catch (e) {
      print('ERRO NO LOGIN: $e');
      rethrow;
    }
  }

  // ============================================================
  // AUTH - RECUPERAR SENHA
  // ============================================================

  static Future<void> recuperarSenha(
    String email,
  ) async {
    try {
      final emailNormalizado =
          email.trim().toLowerCase();

      if (emailNormalizado.isEmpty) {
        throw Exception(
          'Informe seu e-mail.',
        );
      }

      if (!emailInstitucionalValido(
        emailNormalizado,
      )) {
        throw Exception(
          'Use um e-mail institucional.',
        );
      }

      await _firebaseAuth.sendPasswordResetEmail(
        email: emailNormalizado,
      );

      print('====================================');
      print('RECUPERAÇÃO DE SENHA');
      print('E-MAIL: $emailNormalizado');
      print('LINK ENVIADO PELO FIREBASE');
      print('====================================');
    } on FirebaseAuthException catch (e) {
      print(
        'ERRO RECUPERAÇÃO: '
        '${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'invalid-email':
          throw Exception(
            'E-mail inválido.',
          );

        case 'user-not-found':
          throw Exception(
            'Não encontramos uma conta com este e-mail.',
          );

        case 'too-many-requests':
          throw Exception(
            'Muitas solicitações. '
            'Tente novamente mais tarde.',
          );

        default:
          throw Exception(
            'Não foi possível enviar o e-mail de recuperação: '
            '${e.message}',
          );
      }
    }
  }

  // ============================================================
  // AUTH - LOGIN FORM SWAGGER
  // ============================================================

  static Future<String> loginForm(
    String email,
    String senha,
  ) async {
    return login(email, senha);
  }

  // ============================================================
  // AUTH - LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final url =
        Uri.parse('$baseUrl/config/logout');

    try {
      await _enviarRequisicao(
        'POST',
        url,
        auth: true,
      );
    } catch (_) {}

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

    await limparSessao();
  }

  // ============================================================
  // MERCADO - AÇÕES
  // ============================================================

  static Future<Map<String, dynamic>> buscarAcoes({
    int page = 1,
    int limit = 50,
    String search = '',
    String sortBy = 'volume',
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final url = Uri.parse(
      '$baseUrl/mercado/acoes',
    ).replace(
      queryParameters: query,
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception(
        'Formato inválido retornado pela API de ações.',
      );
    }

    throw Exception(
      'Erro ao carregar ações: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // MERCADO - FUNDOS
  // ============================================================

  static Future<Map<String, dynamic>> buscarFundos({
    int page = 1,
    int limit = 50,
    String search = '',
    String sortBy = 'volume',
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final url = Uri.parse(
      '$baseUrl/mercado/fundos',
    ).replace(
      queryParameters: query,
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception(
        'Formato inválido retornado pela API de fundos.',
      );
    }

    throw Exception(
      'Erro ao carregar fundos: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // MERCADO - PESQUISAR ATIVOS
  // ============================================================

  static Future<List<dynamic>> pesquisarAtivos(
    String busca, {
    String tipo = 'todos',
    int limit = 20,
  }) async {
    final query =
        Uri.encodeQueryComponent(
      busca.trim(),
    );

    final url = Uri.parse(
      '$baseUrl/mercado/buscar'
      '?q=$query'
      '&tipo=$tipo'
      '&limit=$limit',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    print('====================================');
    print('PESQUISA DE ATIVOS');
    print('BUSCA: $busca');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('====================================');

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final ativos = data['ativos'];

        if (ativos is List) {
          return ativos;
        }
      }

      throw Exception(
        'Formato inválido retornado pela API.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao pesquisar ativos.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao pesquisar ativos: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // MERCADO - ÍNDICES
  // ============================================================

  static Future<Map<String, dynamic>>
      buscarIndices() async {
    final url =
        Uri.parse('$baseUrl/mercado/indices');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
        jsonDecode(response.body),
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
    final url =
        Uri.parse('$baseUrl/favoritos/acoes');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  static Future<void> adicionarFavoritoAcao(
    String codigo,
  ) async {
    final url =
        Uri.parse('$baseUrl/favoritos/acoes');

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {'codigo': codigo},
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

  static Future<void> removerFavoritoAcao(
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
    final url =
        Uri.parse('$baseUrl/favoritos/fundos');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  static Future<void> adicionarFavoritoFundo(
    String codigo,
  ) async {
    final url =
        Uri.parse('$baseUrl/favoritos/fundos');

    final response =
        await _enviarRequisicao(
      'POST',
      url,
      body: {'codigo': codigo},
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

  static Future<void> removerFavoritoFundo(
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
  // CARTEIRA - RESUMO
  // ============================================================

  static Future<List<dynamic>>
      buscarCarteira() async {
    final url = Uri.parse(
      '$baseUrl/carteira/simular/agrupado',
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

      if (data is List) {
        return data;
      }

      throw Exception(
        'Formato inválido retornado pela API da carteira.',
      );
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao carregar carteira.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao carregar carteira: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // CARTEIRA - ATUALIZADA
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
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro ao carregar carteira: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // CARTEIRA - ADICIONAR
  // ============================================================

  static Future<void> adicionarAtivoCarteira(
    String codigo,
    double quantidade,
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
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }

        throw Exception(
          'Erro ao adicionar ativo: '
          '${response.statusCode}',
        );
      }
    }
  }

  // ============================================================
  // CARTEIRA - ATUALIZAR
  // ============================================================

  static Future<void> atualizarAtivoCarteira(
    int itemId,
    double quantidade,
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

  // ============================================================
  // CARTEIRA - REMOVER
  // ============================================================

  static Future<void> removerAtivoCarteira(
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
    final url =
        Uri.parse('$baseUrl/educacao/videos');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
    final url =
        Uri.parse(
      '$baseUrl/educacao/videos/tema/$tema',
    );

    final response =
        await _enviarRequisicao(
      'GET',
      url,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
    final url =
        Uri.parse('$baseUrl/educacao/materiais');

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

      for (final material in materiais) {
        if (material is! Map) {
          continue;
        }

        final caminho = material['url'];

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
  // ============================================================

  static Future<void> adicionarMaterial({
    required String titulo,
    String? descricao,
    String? tema,
    required String caminhoArquivo,
  }) async {
    final url =
        Uri.parse('$baseUrl/educacao/materiais');

    final token = await getToken();

    final request =
        http.MultipartRequest(
      'POST',
      url,
    );

    if (token != null) {
      request.headers['Authorization'] =
          'Bearer $token';
    }

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

    final arquivo =
        File(caminhoArquivo);

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

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

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
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

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
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

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
    final url =
        Uri.parse('$baseUrl/admin/videos/');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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

  static Future<void> adicionarVideoAdmin({
    required String titulo,
    String? descricao,
    required String url,
    String? tema,
    String? duracao,
  }) async {
    final endpoint =
        Uri.parse('$baseUrl/admin/videos/');

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
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao adicionar vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - EDITAR VÍDEO
  // ============================================================

  static Future<void> editarVideoAdmin({
    required int videoId,
    String? titulo,
    String? descricao,
    String? url,
    String? tema,
    String? duracao,
  }) async {
    final endpoint =
        Uri.parse(
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
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao editar vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // ADMIN - EXCLUIR VÍDEO
  // ============================================================

  static Future<void> excluirVideoAdmin(
    int videoId,
  ) async {
    final endpoint =
        Uri.parse(
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
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao excluir vídeo: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // USUÁRIO - FCM TOKEN
  // ============================================================

  static Future<void> salvarFCMToken(
    String fcmToken,
  ) async {
    final url =
        Uri.parse('$baseUrl/usuario/fcm-token');

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
    final url =
        Uri.parse('$baseUrl/usuario/me');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro: ${response.statusCode}',
    );
  }

  // ============================================================
  // USUÁRIO - ATUALIZAR PERFIL (NOME)
  // (trazido da versão sem Firebase)
  // ============================================================

  static Future<void> atualizarPerfil(
    String nome,
  ) async {
    final url = Uri.parse(
      '$baseUrl/usuario/me',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      body: {
        'nome': nome,
      },
      auth: true,
    );

    if (response.statusCode == 200) {
      return;
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao atualizar perfil',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao atualizar perfil: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // USUÁRIO - AVATAR
  // ============================================================

  static Future<void> atualizarAvatar(
    String avatar,
  ) async {
    final url =
        Uri.parse('$baseUrl/usuario/avatar');

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
  // USUÁRIO - SENHA
  // (trazido da versão sem Firebase — atenção: se a senha é
  // gerenciada pelo Firebase, avalie se este endpoint ainda
  // faz sentido no backend, ou se a troca de senha deveria
  // usar _firebaseAuth.currentUser?.updatePassword(...))
  // ============================================================

  static Future<void> alterarSenha(
    String senhaAtual,
    String novaSenha,
  ) async {
    final url = Uri.parse(
      '$baseUrl/usuario/senha',
    );

    final response =
        await _enviarRequisicao(
      'PUT',
      url,
      body: {
        'senha_atual': senhaAtual,
        'nova_senha': novaSenha,
      },
      auth: true,
    );

    if (response.statusCode == 200) {
      return;
    }

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['detail'] ??
            'Erro ao alterar senha',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Erro ao alterar senha: '
        '${response.statusCode}',
      );
    }
  }

  // ============================================================
  // NOTIFICAÇÕES - ENVIAR
  // ============================================================

  static Future<void> enviarNotificacao(
    String titulo,
    String mensagem, {
    String tipo = 'SISTEMA',
  }) async {
    final url =
        Uri.parse('$baseUrl/notificacoes/enviar');

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
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }

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
    final url =
        Uri.parse('$baseUrl/notificacoes');

    final response =
        await _enviarRequisicao(
      'GET',
      url,
      auth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
    final url =
        Uri.parse(
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
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }

        throw Exception(
          'Erro ao marcar notificação como lida: '
          '${response.statusCode}',
        );
      }
    }
  }

  // ============================================================
  // ONBOARDING
  // ============================================================

  static Future<bool>
      jaViuBoasVindas() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          'ja_viu_boasvindas',
        ) ??
        false;
  }

  static Future<void>
      marcarBoasVindasVistas() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'ja_viu_boasvindas',
      true,
    );
  }
}