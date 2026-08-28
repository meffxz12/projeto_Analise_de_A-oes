import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:meu_apli/services/navigation_service.dart';
import 'package:meu_apli/services/notification_service.dart';
import 'package:meu_apli/telas/auth/login.dart';
import 'package:meu_apli/telas/onboarding/splashs_creen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // ENV
  // ============================================================

  await dotenv.load(
    fileName: "env",
  );

  // ============================================================
  // FIREBASE
  // ============================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // NOTIFICAÇÕES EM BACKGROUND
  // ============================================================

  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );

  // ============================================================
  // NOTIFICATION SERVICE
  // ============================================================

  await NotificationService.initialize();

  // ============================================================
  // APP
  // ============================================================

  runApp(const MyApp());

  // ============================================================
  // PROCESSAR NOTIFICAÇÃO QUE ABRIU O APP
  // ============================================================
  //
  // IMPORTANTE:
  //
  // O runApp() já foi executado.
  // Agora o MaterialApp/Navigator pode existir.
  //
  // ============================================================

  await NotificationService.processarInitialMessage();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ========================================================
      // NAVIGATOR GLOBAL
      // ========================================================

      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      title: 'InvestServ',

      // ========================================================
      // TEMA
      // ========================================================

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A5AE0),
        ),
        useMaterial3: true,
      ),

      // ========================================================
      // TELA INICIAL
      // ========================================================

      home: const SplashScreen(),
    );
  }
}