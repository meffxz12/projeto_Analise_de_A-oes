import 'package:flutter/material.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/auth/login.dart';
import 'package:meu_apli/telas/auth/cadastro.dart';
import 'package:meu_apli/telas/onboarding/bemvindo.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decidirRota();
  }

  Future<void> _decidirRota() async {
    final token = await ApiService.getToken();

    bool logado = false;
    if (token != null) {
      logado = await ApiService.tentarRenovarToken();
    }

    if (!mounted) return;

    Widget destino;

    if (logado) {
      destino = const MainNavegacao();
    } else {
      final jaViuBoasVindas = await ApiService.jaViuBoasVindas();
      destino = jaViuBoasVindas ? const LoginScreen() : const BemVindoScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8E7CFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}