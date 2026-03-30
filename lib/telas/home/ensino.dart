import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';

class EnsinoScreen extends StatelessWidget {
  const EnsinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: CoresGlobais.backgrounder),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.school_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Centro de Ensino',
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
                          child: Icon(Icons.person_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── BOTÕES DE CATEGORIA ───────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _categoriaBtn('Aulas', Icons.play_circle_rounded, const Color(0xFF6A5AE0)),
                              const SizedBox(width: 10),
                              _categoriaBtn('Artigos', Icons.article_rounded, Colors.blueGrey),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _categoriaBtn('Glossário', Icons.menu_book_rounded, const Color(0xFF1B8A5A)),
                              const SizedBox(width: 10),
                              _categoriaBtn('Quiz', Icons.quiz_rounded, Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── VÍDEOS ────────────────────────────────────────
              _sectionCard(
                title: 'Vídeos',
                child: const Column(
                  children: [
                    VideoCard(title: 'Como analisar ações', videoId: 'bkcMlHEtXsI', duration: '17:10'),
                    SizedBox(height: 10),
                    VideoCard(title: 'O que são fundos imobiliários?', videoId: 'vZ64S8dFpEM', duration: '9:54'),
                    SizedBox(height: 10),
                    VideoCard(title: 'Análise Técnica para Iniciantes', videoId: '1tbjXu6oHqI', duration: '10:08'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── ARTIGOS ───────────────────────────────────────
              _sectionCard(
                title: 'Artigos',
                child: Column(
                  children: [
                    _artigoCard('Noções Básicas de Investimentos', Icons.lightbulb_rounded, const Color(0xFF6A5AE0)),
                    const SizedBox(height: 10),
                    _artigoCard('Entendendo o Mercado de Ações', Icons.show_chart_rounded, const Color(0xFF1B8A5A)),
                    const SizedBox(height: 10),
                    _artigoCard('O que são Fundos Imobiliários?', Icons.apartment_rounded, Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoriaBtn(String title, IconData icon, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: cor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: cor),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: cor.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _artigoCard(String title, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }
}