import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/opcaocard.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/componentes/grafico.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── TOPO ─────────────────────────────────────────
              _buildHeader(),

              const SizedBox(height: 12),

              // ── GRÁFICO ───────────────────────────────────────
              _card(
                child: const GraficoAcao(),
              ),

              const SizedBox(height: 12),

              // ── CATEGORIAS ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: OpcaoCard(
                        text: 'Fundos',
                        onTap: () {},
                        color: CoresGlobais.botao2,
                        textColor: Colors.white,
                        icon: Icons.pie_chart_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OpcaoCard(
                        text: 'Ações',
                        onTap: () {},
                        color: CoresGlobais.botao2,
                        textColor: Colors.white,
                        icon: Icons.show_chart_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── VÍDEOS ────────────────────────────────────────
              _card(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vídeos em destaque',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 14),
                    VideoCard(title: 'Como analisar ações', videoId: 'bkcMlHEtXsI', duration: '17:10'),
                    SizedBox(height: 10),
                    VideoCard(title: 'O que são fundos imobiliários?', videoId: 'vZ64S8dFpEM', duration: '9:54'),
                    SizedBox(height: 10),
                    VideoCard(title: 'Análise Técnica para Iniciantes', videoId: '1tbjXu6oHqI', duration: '10:08'),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: CoresGlobais.backgrounder),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar ativos',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}