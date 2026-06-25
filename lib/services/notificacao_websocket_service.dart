import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../models/notificacao_model.dart';

/// Serviço que conecta no `websocket_endpoint` do seu FastAPI
/// (o que faz `manager.conectar` / `manager.desconectar` no backend).
///
/// Responsabilidades:
/// - Conectar usando o `usuarioId` + um token JWT (`tokenProvider`), igual
///   à validação feita no backend antes de aceitar a conexão.
/// - Reconectar automaticamente com backoff exponencial se a rede cair.
/// - Se o servidor recusar por token inválido/expirado (close code 1008),
///   NÃO tenta reconectar sozinho — chama `onAuthFailure` pra quem estiver
///   usando o serviço decidir (ex: renovar o token e chamar `conectar()` de novo,
///   ou deslogar o usuário).
/// - Mandar "ping" periodicamente (o backend responde "pong" e ignora o resto).
/// - Expor um `Stream<NotificacaoModel>` com os eventos recebidos
///   (favorito_adicionado, favorito_removido, etc).
class NotificacaoWebSocketService {
  NotificacaoWebSocketService({
    required this.baseUrl,
    required this.usuarioId,
    required this.tokenProvider,
    this.path = '/ws', // bate com app.websocket("/ws/{usuario_id}") no main.py
    this.pingInterval = const Duration(seconds: 25),
    this.reconnectDelayInicial = const Duration(seconds: 3),
    this.reconnectDelayMaximo = const Duration(seconds: 30),
    this.onAuthFailure,
  });

  /// Ex: "wss://sua-api.com" ou "ws://192.168.0.10:8000"
  final String baseUrl;
  final int usuarioId;
  final String path;
  final Duration pingInterval;
  final Duration reconnectDelayInicial;
  final Duration reconnectDelayMaximo;

  /// Retorna o JWT atual (ex: lendo do flutter_secure_storage).
  /// Pode retornar `null` se não houver token (ex: usuário deslogado).
  final Future<String?> Function() tokenProvider;

  /// Chamado quando o backend recusa a conexão por token inválido/expirado
  /// ou por não bater com o `usuarioId`. Não tenta reconectar sozinho
  /// nesse caso — evita loop infinito batendo com token ruim.
  final void Function()? onAuthFailure;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Duration _delayAtual = const Duration(seconds: 3);

  bool _disposed = false;
  bool _conectado = false;

  final _controller = StreamController<NotificacaoModel>.broadcast();

  /// Stream com cada notificação recebida do backend (já decodificada).
  Stream<NotificacaoModel> get notificacoes => _controller.stream;

  bool get conectado => _conectado;

  void conectar() => _conectar();

  Future<void> _conectar() async {
    if (_disposed) return;

    final token = await tokenProvider();

    if (token == null || token.isEmpty) {
      onAuthFailure?.call();
      return;
    }

    final uri = Uri.parse('$baseUrl$path/$usuarioId').replace(
      queryParameters: {'token': token},
    );

    try {
      _channel = WebSocketChannel.connect(uri);
      _conectado = true;
      _delayAtual = reconnectDelayInicial;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
        cancelOnError: true,
      );

      _iniciarPing();
    } catch (_) {
      _agendarReconexao();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;

      // resposta do nosso próprio ping -> ignora
      if (data['event'] == 'pong') return;

      final notificacao = NotificacaoModel.fromJson(data);
      _controller.add(notificacao);
    } catch (_) {
      // payload inesperado, ignora silenciosamente
    }
  }

  void _onDisconnected() {
    _conectado = false;
    _pingTimer?.cancel();
    _subscription?.cancel();

    final codigoFechamento = _channel?.closeCode;

    // 1008 = "policy violation": é o que o backend manda quando o token
    // está ausente, inválido, expirado, ou não bate com o usuarioId.
    if (codigoFechamento == 1008) {
      onAuthFailure?.call();
      return;
    }

    if (!_disposed) _agendarReconexao();
  }

  void _agendarReconexao() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_delayAtual, () {
      if (_disposed) return;
      conectar();
    });

    final proximoSegundos = _delayAtual.inSeconds * 2;
    _delayAtual = Duration(
      seconds: proximoSegundos.clamp(
        reconnectDelayInicial.inSeconds,
        reconnectDelayMaximo.inSeconds,
      ),
    );
  }

  void _iniciarPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      _enviar({'event': 'ping'});
    });
  }

  void _enviar(Map<String, dynamic> payload) {
    if (_channel == null || !_conectado) return;
    try {
      _channel!.sink.add(jsonEncode(payload));
    } catch (_) {
      _onDisconnected();
    }
  }

  void desconectar() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close(ws_status.normalClosure);
    _conectado = false;
  }

  void dispose() {
    _disposed = true;
    desconectar();
    _controller.close();
  }
}