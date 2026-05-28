import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/telas/auth/cadastro.dart';
import 'package:meu_apli/telas/home/ensino.dart';
import 'package:meu_apli/telas/home/hometela.dart';
import 'package:meu_apli/telas/perfilusuario.dart';
import 'package:meu_apli/telas/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Análise de Ações',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A5AE0),
        ),
        useMaterial3: true,
      ),
      home: const MainNavegacao(),
    );
  }
}