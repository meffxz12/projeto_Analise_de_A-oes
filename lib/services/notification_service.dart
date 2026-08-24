import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meu_apli/services/apiservice.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // ─────────────────────────────────────────────────────────
  // BACKGROUND
  // ─────────────────────────────────────────────────────────

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('====================================');
    print('NOTIFICAÇÃO RECEBIDA EM BACKGROUND');
    print('Título: ${message.notification?.title}');
    print('Mensagem: ${message.notification?.body}');
    print('====================================');
  }

  // ─────────────────────────────────────────────────────────
  // INICIALIZAÇÃO
  // ─────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    // Solicita permissão
    NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
      'Permissão para notificações: '
      '${settings.authorizationStatus}',
    );

    // Obtém FCM Token
    String? token = await _messaging.getToken();

    print('====================================');
    print('FCM TOKEN:');
    print(token);
    print('====================================');

    // IMPORTANTE:
    // Não tentamos salvar o token no backend aqui,
    // porque nesse momento o usuário pode ainda não
    // estar logado.
    //
    // O token será salvo no momento do login através
    // do ApiService.login().

    // ─────────────────────────────────────────────────────
    // TOKEN REFRESH
    // ─────────────────────────────────────────────────────

    _messaging.onTokenRefresh.listen(
      (newToken) async {
        print('====================================');
        print('NOVO FCM TOKEN:');
        print(newToken);
        print('====================================');

        try {
          // Se houver usuário logado, salva o novo token.
          final jwt = await ApiService.getToken();

          if (jwt != null) {
            await ApiService.salvarFCMToken(
              newToken,
            );

            print(
              'NOVO FCM TOKEN ATUALIZADO NO BANCO!',
            );
          } else {
            print(
              'Usuário não está logado. '
              'Token será salvo no próximo login.',
            );
          }
        } catch (e) {
          print(
            'ERRO AO ATUALIZAR FCM TOKEN: $e',
          );
        }
      },
    );

    // ─────────────────────────────────────────────────────
    // APP ABERTO
    // ─────────────────────────────────────────────────────

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('====================================');
        print('NOTIFICAÇÃO RECEBIDA COM APP ABERTO');
        print(
          'Título: ${message.notification?.title}',
        );
        print(
          'Mensagem: ${message.notification?.body}',
        );
        print('====================================');
      },
    );

    // ─────────────────────────────────────────────────────
    // USUÁRIO CLICOU NA NOTIFICAÇÃO
    // ─────────────────────────────────────────────────────

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('====================================');
        print('USUÁRIO CLICOU NA NOTIFICAÇÃO');
        print(
          'Título: ${message.notification?.title}',
        );
        print(
          'Mensagem: ${message.notification?.body}',
        );
        print('====================================');
      },
    );

    // ─────────────────────────────────────────────────────
    // APP ABERTO ATRAVÉS DE NOTIFICAÇÃO
    // ─────────────────────────────────────────────────────

    RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('====================================');
      print(
        'APP ABERTO ATRAVÉS DE UMA NOTIFICAÇÃO',
      );
      print(
        'Título: '
        '${initialMessage.notification?.title}',
      );
      print(
        'Mensagem: '
        '${initialMessage.notification?.body}',
      );
      print('====================================');
    }
  }
}