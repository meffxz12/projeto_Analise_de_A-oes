import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/opcaocard.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/componentes/grafico.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/fundos_screen.dart';
import 'package:meu_apli/telas/home/acoes_screen.dart';
import 'package:meu_apli/telas/perfilusuario.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _buscaController = TextEditingController();

  List<dynamic> _acoes = [];
  List<dynamic> _fundos = [];
  List<dynamic> _videos = [];

  String _query = '';
  bool _carregandoDados = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosParaBusca();
    _buscaController.addListener(() {
      setState(() {
        _query = _buscaController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosParaBusca() async {
    try {
      final resultados = await Future.wait([
        ApiService.buscarAcoes(),
        ApiService.buscarFundos(), // ajuste o nome se for diferente
        ApiService.listarVideos(),
      ]);
      setState(() {
        _acoes = resultados[0];
        _fundos = resultados[1];
        _videos = resultados[2];
        _carregandoDados = false;
      });
    } catch (_) {
      setState(() => _carregandoDados = false);
    }
  }

  bool _bate(dynamic item, List<String> campos) {
    for (final campo in campos) {
      final valor = item[campo]?.toString().toLowerCase() ?? '';
      if (valor.contains(_query)) return true;
    }
    return false;
  }

  List<dynamic> get _acoesFiltradas =>
      _acoes.where((a) => _bate(a, ['codigo', 'nome'])).toList();

  List<dynamic> get _fundosFiltrados =>
      _fundos.where((f) => _bate(f, ['codigo', 'nome'])).toList();

  List<dynamic> get _videosFiltrados =>
      _videos.where((v) => _bate(v, ['title', 'titulo'])).toList();

  bool get _pesquisando => _query.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _pesquisando
                  ? _buildResultadosBusca()
                  : _buildConteudoPadrao(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudoPadrao() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _card(child: const GraficoAcao()),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: OpcaoCard(
                    text: 'Fundos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FundosScreen()),
                      );
                    },
                    color: CoresGlobais.botao2,
                    textColor: Colors.white,
                    icon: Icons.pie_chart_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OpcaoCard(
                    text: 'Ações',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AcoesScreen()),
                      );
                    },
                    color: CoresGlobais.botao2,
                    textColor: Colors.white,
                    icon: Icons.show_chart_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildResultadosBusca() {
    if (_carregandoDados) {
      return const Center(child: CircularProgressIndicator());
    }

    final semResultados = _acoesFiltradas.isEmpty &&
        _fundosFiltrados.isEmpty &&
        _videosFiltrados.isEmpty;

    if (semResultados) {
      return Center(
        child: Text(
          'Nenhum resultado para "$_query"',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        if (_acoesFiltradas.isNotEmpty) ...[
          _sectionLabel('Ações'),
          ..._acoesFiltradas.map((a) => ListTile(
                leading: const Icon(Icons.show_chart_rounded),
                title: Text(a['codigo'] ?? ''),
                subtitle: Text(a['nome'] ?? ''),
              )),
        ],
        if (_fundosFiltrados.isNotEmpty) ...[
          _sectionLabel('Fundos'),
          ..._fundosFiltrados.map((f) => ListTile(
                leading: const Icon(Icons.pie_chart_rounded),
                title: Text(f['codigo'] ?? ''),
                subtitle: Text(f['nome'] ?? ''),
              )),
        ],
        if (_videosFiltrados.isNotEmpty) ...[
          _sectionLabel('Vídeos'),
          ..._videosFiltrados.map((v) => ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: Text(v['title'] ?? v['titulo'] ?? ''),
              )),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              child: TextField(
                controller: _buscaController,
                decoration: InputDecoration(
                  hintText: 'Buscar ativos',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  suffixIcon: _pesquisando
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => _buscaController.clear(),
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PerfilScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
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