import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/services/navigation_service.dart';
import 'package:meu_apli/telas/home/ensino.dart';

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
    description: 'Notificações do aplicativo InvestServ',
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

    print(
      'Título: ${message.notification?.title}',
    );

    print(
      'Mensagem: ${message.notification?.body}',
    );

    print(
      'Dados: ${message.data}',
    );

    print('====================================');
  }

  // ============================================================
  // PROCESSAR DADOS DA NOTIFICAÇÃO
  // ============================================================

  static void _processarDadosNotificacao(
    Map<String, dynamic> data,
  ) {
    print('====================================');
    print('PROCESSANDO NOTIFICAÇÃO');
    print('Dados recebidos: $data');
    print('====================================');

    final tipo = (
      data['tipo'] ??
      data['destino']
    )?.toString();

    print(
      'TIPO DA NOTIFICAÇÃO: $tipo',
    );

    // ==========================================================
    // MATERIAL
    // ==========================================================

    if (tipo == 'MATERIAL') {
      final materialIdString =
          data['material_id']?.toString();

      final url = (
        data['url'] ??
        data['arquivo']
      )?.toString();

      final materialId =
          int.tryParse(
        materialIdString ?? '',
      );

      print('====================================');
      print('TIPO: MATERIAL');
      print('MATERIAL ID: $materialId');
      print('URL: $url');
      print('====================================');

      if (materialId == null) {
        print(
          'ERRO: material_id inválido.',
        );
        return;
      }

      _abrirMaterial(
        materialId: materialId,
        url: url,
      );

      return;
    }

    print(
      'Notificação sem ação configurada.',
    );
  }

  // ============================================================
  // ABRIR MATERIAL
  // ============================================================

  static Future<void> _abrirMaterial({
    required int materialId,
    String? url,
  }) async {
    print('====================================');
    print('ABRINDO MATERIAL DA NOTIFICAÇÃO');
    print('ID: $materialId');
    print('URL: $url');
    print('====================================');

    // ==========================================================
    // TENTAR PEGAR O NAVIGATOR
    // ==========================================================

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      print(
        'Navigator ainda não está disponível.',
      );

      return;
    }

    try {
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => EnsinoScreen(
            materialIdInicial: materialId,
            urlMaterialInicial: url,
          ),
        ),
      );

      print(
        'MATERIAL ABERTO COM SUCESSO!',
      );
    } catch (e) {
      print(
        'ERRO AO ABRIR MATERIAL: $e',
      );
    }
  }

  // ============================================================
  // MOSTRAR NOTIFICAÇÃO LOCAL
  // ============================================================

  static Future<void> _mostrarNotificacaoLocal(
    String titulo,
    String mensagem,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails
        androidDetails =
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

    const NotificationDetails
        notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now()
              .millisecondsSinceEpoch ~/
          1000,
      titulo,
      mensagem,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  // ============================================================
  // CLIQUE NA NOTIFICAÇÃO LOCAL
  // ============================================================

  static void _aoClicarNotificacaoLocal(
    NotificationResponse response,
  ) {
    print('====================================');
    print(
      'USUÁRIO TOCOU NA NOTIFICAÇÃO LOCAL',
    );

    print(
      'Payload: ${response.payload}',
    );

    print('====================================');

    if (response.payload == null ||
        response.payload!.isEmpty) {
      print(
        'Payload vazio.',
      );
      return;
    }

    try {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        jsonDecode(
          response.payload!,
        ),
      );

      _processarDadosNotificacao(
        data,
      );
    } catch (e) {
      print(
        'Erro ao processar payload '
        'da notificação: $e',
      );
    }
  }

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  static Future<void> initialize() async {
    print(
      'INICIANDO NOTIFICATION SERVICE...',
    );

    // ==========================================================
    // NOTIFICAÇÕES LOCAIS
    // ==========================================================

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
        settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          _aoClicarNotificacaoLocal,
    );

    // ==========================================================
    // CANAL
    // ==========================================================

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          _channel,
        );

    // ==========================================================
    // PERMISSÃO FCM
    // ==========================================================

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

    // ==========================================================
    // PERMISSÃO ANDROID 13+
    // ==========================================================

    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin
        ?.requestNotificationsPermission();

    // ==========================================================
    // TOKEN
    // ==========================================================

    final String? token =
        await _messaging.getToken();

    print('====================================');
    print('FCM TOKEN:');
    print(token);
    print('====================================');

    // ==========================================================
    // TOKEN REFRESH
    // ==========================================================

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
          'Título: '
          '${message.notification?.title}',
        );

        print(
          'Mensagem: '
          '${message.notification?.body}',
        );

        print(
          'Dados: '
          '${message.data}',
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

        if (titulo.toString().isNotEmpty &&
            mensagem.toString().isNotEmpty) {
          await _mostrarNotificacaoLocal(
            titulo.toString(),
            mensagem.toString(),
            message.data,
          );
        }
      },
    );

    // ==========================================================
    // APP EM BACKGROUND
    // USUÁRIO CLICOU NA NOTIFICAÇÃO FCM
    // ==========================================================

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('====================================');
        print(
          'USUÁRIO CLICOU NA NOTIFICAÇÃO FCM',
        );

        print(
          'Título: '
          '${message.notification?.title}',
        );

        print(
          'Mensagem: '
          '${message.notification?.body}',
        );

        print(
          'Dados: '
          '${message.data}',
        );

        print('====================================');

        _processarDadosNotificacao(
          message.data,
        );
      },
    );

    // ==========================================================
    // NÃO PROCESSAR getInitialMessage AQUI
    // ==========================================================
    //
    // O app ainda não foi montado neste momento.
    //
    // O processamento será feito pelo main.dart depois
    // do runApp().
    //
    // ==========================================================

    print(
      'NOTIFICATION SERVICE INICIALIZADO!',
    );
  }

  // ============================================================
  // PROCESSAR NOTIFICAÇÃO QUE ABRIU O APP
  // ============================================================

  static Future<void> processarInitialMessage() async {
    print('====================================');
    print(
      'VERIFICANDO NOTIFICAÇÃO QUE ABRIU O APP',
    );
    print('====================================');

    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage == null) {
      print(
        'Nenhuma notificação abriu o aplicativo.',
      );
      return;
    }

    print('====================================');
    print(
      'APP FOI ABERTO ATRAVÉS DE UMA NOTIFICAÇÃO',
    );

    print(
      'Título: '
      '${initialMessage.notification?.title}',
    );

    print(
      'Mensagem: '
      '${initialMessage.notification?.body}',
    );

    print(
      'Dados: '
      '${initialMessage.data}',
    );

    print('====================================');

    // ==========================================================
    // ESPERAR O MATERIALAPP ESTAR MONTADO
    // ==========================================================

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          const Duration(
            milliseconds: 700,
          ),
          () {
            _processarDadosNotificacao(
              initialMessage.data,
            );
          },
        );
      },
    );
  }
}