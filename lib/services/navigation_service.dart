import 'package:flutter/material.dart';

import 'package:meu_apli/telas/auth/login.dart';
import 'package:meu_apli/telas/home/ensino.dart';

/// Key global do Navigator.
///
/// É registrada no MaterialApp no main.dart.
/// Permite navegar a partir de services sem precisar de BuildContext.
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

// ============================================================
// REDIRECIONAR PARA LOGIN
// ============================================================

void redirecionarParaLogin() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}

// ============================================================
// ABRIR MATERIAL
// ============================================================

void abrirMaterial(int materialId) {
  final navigator =
      navigatorKey.currentState;

  if (navigator == null) {
    debugPrint(
      'Não foi possível navegar: '
      'Navigator ainda não está disponível.',
    );

    return;
  }

  navigator.push(
    MaterialPageRoute(
      builder: (_) => EnsinoScreen(
        materialIdInicial: materialId,
      ),
    ),
  );
}