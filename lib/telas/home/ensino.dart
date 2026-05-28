import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/telas/perfilusuario.dart';

// ─── Model para Artigos/Leitura ────────────────────────────────────────────────
class ConteudoLeitura {
  final String titulo;
  final String descricao;
  final String tempoEstimado;
  final IconData icone;
  final Color cor;
  final String urlConteudo; // URL ou ID para o conteúdo completo

  const ConteudoLeitura(
    this.titulo,
    this.descricao,
    this.tempoEstimado,
    this.icone,
    this.cor,
    this.urlConteudo,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class EnsinoScreen extends StatefulWidget {
  const EnsinoScreen({super.key});

  @override
  State<EnsinoScreen> createState() => _EnsinoScreenState();
}

class _EnsinoScreenState extends State<EnsinoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Conteúdo de leitura (antigos artigos, agora mais genéricos)
  final _conteudosLeitura = const [
    ConteudoLeitura(
      'Noções Básicas de Investimentos',
      'Entenda os conceitos fundamentais antes de investir.',
      '5 min',
      Icons.lightbulb_rounded,
      Color(0xFF6A5AE0),
      'https://www.exemplo.com/nocoes-basicas', // Exemplo de URL
    ),
    ConteudoLeitura(
      'Como funciona o Mercado de Ações',
      'Da bolsa de valores ao home broker explicado de forma simples.',
      '7 min',
      Icons.show_chart_rounded,
      Color(0xFF1B8A5A),
      'https://www.exemplo.com/mercado-acoes', // Exemplo de URL
    ),
    ConteudoLeitura(
      'O que são Fundos Imobiliários?',
      'Invista em imóveis pagando poucos reais por cota.',
      '6 min',
      Icons.apartment_rounded,
      Colors.orange,
      'https://www.exemplo.com/fundos-imobiliarios', // Exemplo de URL
    ),
    ConteudoLeitura(
      'Renda Fixa vs Renda Variável',
      'Descubra as diferenças e quando usar cada uma.',
      '8 min',
      Icons.balance_rounded,
      Color(0xFFCC2929),
      'https://www.exemplo.com/renda-fixa-variavel', // Exemplo de URL
    ),
    ConteudoLeitura(
      'Diversificação de carteira',
      'Por que não colocar todos os ovos na mesma cesta.',
      '6 min',
      Icons.pie_chart_rounded,
      Colors.teal,
      'https://www.exemplo.com/diversificacao', // Exemplo de URL
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Apenas duas abas: Vídeos e Leitura
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    children: [
                      const Row(
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
                     InkWell(
            onTap: () {
              Navigator.push(
                context,
                 MaterialPageRoute(
                  builder: (context) => PerfilScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20), // Para o efeito de clique ser circular
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── ABAS ──────────────────────────────────
                  TabBar(
                    controller: _tab,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Vídeos'),
                      Tab(text: 'Leitura'), // Aba renomeada
                    ],
                  ),
                ],
              ),
            ),

            // ── CONTEÚDO ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _abaVideos(),
                  _abaLeitura(), // Conteúdo da aba de leitura
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ABA VÍDEOS ─────────────────────────────────────────────────────────────
  Widget _abaVideos() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: const [
        VideoCard(
            title: 'Como analisar ações',
            videoId: 'bkcMlHEtXsI',
            duration: '17:10'),
        SizedBox(height: 10),
        VideoCard(
            title: 'O que são fundos imobiliários?',
            videoId: 'vZ64S8dFpEM',
            duration: '9:54'),
        SizedBox(height: 10),
        VideoCard(
            title: 'Análise Técnica para Iniciantes',
            videoId: '1tbjXu6oHqI',
            duration: '10:08'),
        SizedBox(height: 10),
        VideoCard(
            title: 'Como montar uma carteira diversificada',
            videoId: 'bkcMlHEtXsI', // substituir pelo ID real
            duration: '14:22'),
      ],
    );
  }

  // ── ABA LEITURA (Antigos Artigos) ──────────────────────────────────────────
  Widget _abaLeitura() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: _conteudosLeitura.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _conteudoLeituraCard(_conteudosLeitura[i]),
    );
  }

  Widget _conteudoLeituraCard(ConteudoLeitura c) {
    return GestureDetector(
      onTap: () {
        // TODO: Implementar navegação para a URL do conteúdo completo
        // Por exemplo, usando url_launcher para abrir no navegador externo
        // ou navegando para uma tela interna que renderize o conteúdo.
        print('Abrir conteúdo: ${c.urlConteudo}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(c.icone, color: c.cor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(c.descricao,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(c.tempoEstimado,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
