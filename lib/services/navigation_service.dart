import 'package:flutter/material.dart';
import 'package:meu_apli/telas/auth/login.dart';

/// Key global do Navigator, registrada no MaterialApp (ver main.dart).
/// Permite navegar de dentro de um service (sem context), por exemplo
/// quando a sessão expira em qualquer chamada de API.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Manda o usuário de volta pro login e limpa todo o histórico de telas.
/// Chamado quando o access_token expira E o refresh_token também falha.
void redirecionarParaLogin() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}