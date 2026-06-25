import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notificacao_model.dart';

/// Mostra as notificações recebidas via WebSocket como notificações
/// nativas do sistema (push local, não remoto).
class LocalNotificationHelper {
  LocalNotificationHelper._();
  static final LocalNotificationHelper instance = LocalNotificationHelper._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  int _idCounter = 0;

  /// Chame uma vez no início do app (ex: no main() ou initState do Splash).
  Future<void> inicializar() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Android 13+ exige permissão em tempo de execução.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> mostrar(NotificacaoModel notificacao) async {
    const androidDetails = AndroidNotificationDetails(
      'favoritos_channel',
      'Favoritos',
      channelDescription: 'Notificações sobre seus favoritos',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      _idCounter++,
      notificacao.title,
      notificacao.message,
      details,
      payload: notificacao.codigo,
    );
  }
}