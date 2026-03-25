import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/navegacaotelas.dart';
import 'package:meu_apli/telas/bemvindo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_apli/telas/carteirasimulada.dart';
import 'package:meu_apli/telas/ensino.dart';
import 'package:meu_apli/telas/favoritos.dart';
import 'package:meu_apli/telas/hometela.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Navegacaotelas(),
    );
  }
}