import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:meu_apli/services/apiservice.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _localNotifications =
          FlutterLocalNotificationsPlugin();

  // ============================================================
  // CANAL
  // ============================================================

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'investserv_notifications',
    'InvestServ',
    description:
        'Notificações do aplicativo InvestServ',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ============================================================
  // BACKGROUND
  // ============================================================

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('====================================');
    print('NOTIFICAÇÃO RECEBIDA EM BACKGROUND');
    print('Título: ${message.notification?.title}');
    print('Mensagem: ${message.notification?.body}');
    print('====================================');

    // IMPORTANTE:
    // Se o Firebase já recebeu uma mensagem do tipo
    // "notification", o próprio Android mostra a
    // notificação quando o app está em background.
    //
    // Portanto, não mostramos outra local aqui.
  }

  // ============================================================
  // NOTIFICAÇÃO LOCAL
  // ============================================================

  static Future<void> _mostrarNotificacaoLocal(
    String titulo,
    String mensagem,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'investserv_notifications',
      'InvestServ',
      channelDescription:
          'Notificações do aplicativo InvestServ',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      mensagem,
      notificationDetails,
    );
  }

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  static Future<void> initialize() async {
    print('INICIANDO NOTIFICATION SERVICE...');

    // ----------------------------------------------------------
    // LOCAL NOTIFICATIONS
    // ----------------------------------------------------------

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        print(
          'USUÁRIO TOCOU NA NOTIFICAÇÃO',
        );
      },
    );

    // ----------------------------------------------------------
    // CRIA CANAL
    // ----------------------------------------------------------

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ----------------------------------------------------------
    // PERMISSÃO FCM
    // ----------------------------------------------------------

    final NotificationSettings permission =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print(
      'Permissão para notificações: '
      '${permission.authorizationStatus}',
    );

    // ----------------------------------------------------------
    // PERMISSÃO ANDROID 13+
    // ----------------------------------------------------------

    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // ----------------------------------------------------------
    // TOKEN
    // ----------------------------------------------------------

    final String? token =
        await _messaging.getToken();

    print('====================================');
    print('FCM TOKEN:');
    print(token);
    print('====================================');

    // ----------------------------------------------------------
    // TOKEN REFRESH
    // ----------------------------------------------------------

    _messaging.onTokenRefresh.listen(
      (newToken) async {
        print('====================================');
        print('NOVO FCM TOKEN:');
        print(newToken);
        print('====================================');

        try {
          final jwt =
              await ApiService.getToken();

          if (jwt != null) {
            await ApiService.salvarFCMToken(
              newToken,
            );

            print(
              'NOVO FCM TOKEN ATUALIZADO NO BANCO!',
            );
          } else {
            print(
              'Usuário não está logado.',
            );
          }
        } catch (e) {
          print(
            'ERRO AO ATUALIZAR FCM TOKEN: $e',
          );
        }
      },
    );

    // ==========================================================
    // APP ABERTO
    // ==========================================================

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print('====================================');
        print(
          'NOTIFICAÇÃO RECEBIDA COM APP ABERTO',
        );
        print(
          'Título: ${message.notification?.title}',
        );
        print(
          'Mensagem: ${message.notification?.body}',
        );
        print('====================================');

        final titulo =
            message.notification?.title ??
                message.data['titulo'] ??
                'InvestServ';

        final mensagem =
            message.notification?.body ??
                message.data['mensagem'] ??
                '';

        if (titulo.isNotEmpty &&
            mensagem.isNotEmpty) {
          await _mostrarNotificacaoLocal(
            titulo,
            mensagem,
          );
        }
      },
    );

    // ==========================================================
    // USUÁRIO CLICOU
    // ==========================================================

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('====================================');
        print(
          'USUÁRIO CLICOU NA NOTIFICAÇÃO',
        );
        print(
          'Título: ${message.notification?.title}',
        );
        print(
          'Mensagem: ${message.notification?.body}',
        );
        print('====================================');
      },
    );

    // ==========================================================
    // APP ABERTO ATRAVÉS DA NOTIFICAÇÃO
    // ==========================================================

    final RemoteMessage? initialMessage =
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

    print('NOTIFICATION SERVICE INICIALIZADO!');
  }
}