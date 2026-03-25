import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';

class Ensino extends StatefulWidget {
  const Ensino({super.key});

  @override
  State<Ensino> createState() => _EnsinoState();
}

class _EnsinoState extends State<Ensino> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

            // 🔝 HEADER
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
              child: Column(
                children: [

                
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.school, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "Centro de Ensino",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🟪 BOTÕES
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        Row(
                          children: [
                            _card("Aulas", Icons.play_arrow, Colors.purple),
                            const SizedBox(width: 10),
                            _card("Artigos", Icons.article, Colors.grey),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _card("Glossário", Icons.menu_book, Colors.green),
                            const SizedBox(width: 10),
                            _card("Quiz", Icons.quiz, Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎥 VÍDEOS
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

            const SizedBox(height: 20),

            // 📄 ARTIGOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(child: _artigo("Noções Básicas de Investimentos")),
                  const SizedBox(width: 10),
                  Expanded(child: _artigo("Entendendo o Mercado de Ações")),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔹 BOTÕES
  Widget _card(String title, IconData icon, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: cor),
            const SizedBox(width: 10),
            Text(title),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  // 🔹 ARTIGOS
  Widget _artigo(String title) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(title),
    );
  }
}