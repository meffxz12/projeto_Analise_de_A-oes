import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class Acao {
  final String codigo;
  final String nome;
  final double preco;
  final double variacao;
  final double volume;

  const Acao({
    required this.codigo,
    required this.nome,
    required this.preco,
    required this.variacao,
    required this.volume,
  });

  factory Acao.fromJson(Map<String, dynamic> j) => Acao(
        codigo: j['stock'] ?? j['symbol'] ?? '',
        nome: j['name'] ?? j['longName'] ?? '',
        preco: (j['close'] ?? j['regularMarketPrice'] ?? 0).toDouble(),
        variacao: (j['change'] ?? j['regularMarketChangePercent'] ?? 0).toDouble(),
        volume: (j['volume'] ?? j['regularMarketVolume'] ?? 0).toDouble(),
      );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class AcoesScreen extends StatefulWidget {
  const AcoesScreen({super.key});

  @override
  State<AcoesScreen> createState() => _AcoesScreenState();
}

class _AcoesScreenState extends State<AcoesScreen> {
  final _token = dotenv.env['BRAPI_TOKEN'];

  List<Acao> _lista = [];
  List<Acao> _filtrada = [];
  bool _loading = true;
  String? _erro;
  String _busca = '';
  String _filtro = 'Todos';

  // códigos já favoritados (pra estrela aparecer preenchida)
  final Set<String> _favoritos = {};

  final _buscaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarFavoritos();
    _buscaCtrl.addListener(() {
      setState(() {
        _busca = _buscaCtrl.text.trim().toUpperCase();
        _aplicarFiltro();
      });
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final url = Uri.parse(
        'https://brapi.dev/api/quote/list?limit=40&sortBy=volume&sortOrder=desc&token=$_token',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) throw Exception('Erro ${resp.statusCode}');

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final stocks = (json['stocks'] as List? ?? [])
          .map((e) => Acao.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _lista = stocks;
        _aplicarFiltro();
        _loading = false;
      });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Future<void> _carregarFavoritos() async {
    try {
      final favoritos = await ApiService.listarFavoritosAcoes();
      if (!mounted) return;
      setState(() {
        _favoritos
          ..clear()
          ..addAll(favoritos.map((f) => (f['codigo'] ?? '').toString()));
      });
    } catch (_) {
      // se falhar, só não mostra estrela preenchida — não bloqueia a tela
    }
  }

  Future<void> _toggleFavorito(String codigo) async {
    final jaFavoritado = _favoritos.contains(codigo);

    // atualização otimista — já reflete na UI antes da resposta da API
    setState(() {
      if (jaFavoritado) {
        _favoritos.remove(codigo);
      } else {
        _favoritos.add(codigo);
      }
    });

    try {
      if (jaFavoritado) {
        await ApiService.removerFavoritoAcao(codigo);
      } else {
        await ApiService.adicionarFavoritoAcao(codigo);
      }
    } catch (e) {
      // reverte se a API falhar
      if (!mounted) return;
      setState(() {
        if (jaFavoritado) {
          _favoritos.add(codigo);
        } else {
          _favoritos.remove(codigo);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _aplicarFiltro() {
    var lista = _lista.where((a) {
      if (_busca.isEmpty) return true;
      return a.codigo.contains(_busca) ||
          a.nome.toUpperCase().contains(_busca);
    }).toList();

    if (_filtro == 'Alta') lista = lista.where((a) => a.variacao > 0).toList();
    if (_filtro == 'Baixa') lista = lista.where((a) => a.variacao < 0).toList();

    _filtrada = lista;
  }

  void _setFiltro(String f) {
    setState(() { _filtro = f; _aplicarFiltro(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER COM SETA DE VOLTAR ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 20, 24),
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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Ações',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _buscaCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Buscar ação (ex: PETR4)',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          icon: Icon(Icons.search_rounded, color: Color(0xFF6A5AE0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: ['Todos', 'Alta', 'Baixa']
                          .map((f) => _chipFiltro(f))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── LISTA ─────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? _erroWidget()
                      : _filtrada.isEmpty
                          ? _vazioWidget()
                          : RefreshIndicator(
                              onRefresh: _carregar,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(15, 16, 15, 20),
                                itemCount: _filtrada.length,
                                itemBuilder: (_, i) => _acaoCard(_filtrada[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipFiltro(String label) {
    final ativo = _filtro == label;
    return GestureDetector(
      onTap: () => _setFiltro(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? const Color(0xFF6A5AE0) : Colors.white,
            fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _acaoCard(Acao a) {
    final pos = a.variacao >= 0;
    final cor = pos ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);
    final corFundo = pos ? const Color(0xFFE6F4ED) : const Color(0xFFFFEBEB);
    final favoritado = _favoritos.contains(a.codigo);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF6A5AE0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                a.codigo.length >= 2 ? a.codigo.substring(0, 2) : a.codigo,
                style: const TextStyle(
                  color: Color(0xFF6A5AE0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.codigo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (a.nome.isNotEmpty)
                  Text(
                    a.nome,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${a.preco.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: corFundo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pos ? '+' : ''}${a.variacao.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _toggleFavorito(a.codigo),
            child: Icon(
              favoritado ? Icons.star_rounded : Icons.star_outline_rounded,
              color: favoritado ? Colors.amber : Colors.grey[400],
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _erroWidget() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
            const SizedBox(height: 8),
            Text('Erro ao carregar',
                style: TextStyle(color: Colors.grey[500])),
            TextButton(
                onPressed: _carregar, child: const Text('Tentar novamente')),
          ],
        ),
      );

  Widget _vazioWidget() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Nenhuma ação encontrada',
                style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          ],
        ),
      );
}