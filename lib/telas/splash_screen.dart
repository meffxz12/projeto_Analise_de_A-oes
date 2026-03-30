import 'package:flutter/material.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/onboarding/bemvindo.dart';
import 'package:meu_apli/telas/onboarding/bemvindo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarLogin();
  }

  Future<void> _verificarLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Verifica se tem token JWT salvo (da sua API)
    final token = await ApiService.getToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null
            ? const MainNavegacao()
            : const BemVindoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF6A5AE0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Análise de Ações',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}