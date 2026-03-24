import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/componentes/opcaocard.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/telas/carteirasimulada.dart';
import 'package:meu_apli/telas/ensino.dart';
import 'package:meu_apli/telas/favoritos.dart';
import '../componentes/grafico.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
    body:  SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // TOPO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: CoresGlobais.backgrounder,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar ativos",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // GRÁFICO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gráfico de desempenho",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                 // const GraficoAcao(),
                ],
              ),
            ),

            // BOTÕES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OpcaoCard(
                      text: "Fundos",
                      onTap: () {},
                      color: CoresGlobais.botao2,
                      textColor: Colors.white,
                      icon: Icons.pie_chart,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OpcaoCard(
                      text: "Ações",
                      onTap: () {},
                      color: CoresGlobais.botao2,
                      textColor: Colors.white,
                      icon: Icons.show_chart,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // VÍDEOS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Vídeos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  VideoCard(
                    title: "Como analisar ações",
                    videoId: "bkcMlHEtXsI",
                    duration: "17:10",
                  ),
                  SizedBox(height: 10),
                  VideoCard(
                    title: "O que são fundos imobiliários?",
                    videoId: "vZ64S8dFpEM",
                    duration: "9:54",
                  ),
                  SizedBox(height: 10),
                  VideoCard(
                    title: "Análise Técnica para Iniciantes",
                    videoId: "1tbjXu6oHqI",
                    duration: "10:08",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}