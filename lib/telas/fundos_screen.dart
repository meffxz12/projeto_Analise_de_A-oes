import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// ─── Model ────────────────────────────────────────────────────────────────────
class Fundo {
  final String codigo;
  final String nome;
  final double preco;
  final double variacao;
  final double dividendYield;
  final String setor;

  const Fundo({
    required this.codigo,
    required this.nome,
    required this.preco,
    required this.variacao,
    required this.dividendYield,
    required this.setor,
  });

  factory Fundo.fromJson(Map<String, dynamic> j) => Fundo(
        codigo: j['stock'] ?? j['symbol'] ?? '',
        nome: j['name'] ?? j['longName'] ?? '',
        preco: (j['close'] ?? j['regularMarketPrice'] ?? 0.0).toDouble(),
        variacao: (j['change'] ?? j['regularMarketChangePercent'] ?? 0.0).toDouble(),
        dividendYield: (j['dividendYield'] ?? 0.0).toDouble(),
        setor: j['sector'] ?? j['segment'] ?? '',
      );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class FundosScreen extends StatefulWidget {
  const FundosScreen({super.key});

  @override
  State<FundosScreen> createState() => _FundosScreenState();
}

class _FundosScreenState extends State<FundosScreen> {
  final _token = dotenv.env['BRAPI_TOKEN'];
  List<Fundo> _lista = [];
  List<Fundo> _filtrada = [];
  bool _loading = true;
  String? _erro;
  String _busca = '';
  String _ordenar = 'Padrão';

  // códigos já favoritados (pra estrela aparecer preenchida)
  final Set<String> _favoritos = {};

  final _buscaCtrl = TextEditingController();
  Timer? _debounce;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarFavoritos();
    _buscaCtrl.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _busca = _buscaCtrl.text.trim().toUpperCase();
          _aplicarFiltro();
        });
      });
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final url = Uri.parse(
        'https://brapi.dev/api/quote/list?limit=40&type=fund&sortBy=volume&sortOrder=desc&token=$_token',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) throw Exception('Erro ${resp.statusCode}');

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final fundos = (json['stocks'] as List? ?? [])
          .map((e) => Fundo.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _lista = fundos;
        _aplicarFiltro();
        _loading = false;
      });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Future<void> _carregarFavoritos() async {
    try {
      final favoritos = await ApiService.listarFavoritosFundos();
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
        await ApiService.removerFavoritoFundo(codigo);
      } else {
        await ApiService.adicionarFavoritoFundo(codigo);
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
    var lista = _lista.where((f) {
      if (_busca.isEmpty) return true;
      return f.codigo.contains(_busca) ||
          f.nome.toUpperCase().contains(_busca);
    }).toList();

    if (_ordenar == 'Maior DY') {
      lista.sort((a, b) => b.dividendYield.compareTo(a.dividendYield));
    } else if (_ordenar == 'Menor Preço') {
      lista.sort((a, b) => a.preco.compareTo(b.preco));
    }

    _filtrada = lista;
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
                          'Fundos Imobiliários',
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
                          hintText: 'Buscar fundo (ex: MXRF11)',
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Padrão', 'Maior DY', 'Menor Preço']
                            .map((o) => _chipOrdem(o))
                            .toList(),
                      ),
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
                                itemBuilder: (_, i) => _fundoCard(_filtrada[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipOrdem(String label) {
    final ativo = _ordenar == label;
    return GestureDetector(
      onTap: () {
        setState(() { _ordenar = label; _aplicarFiltro(); });
      },
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

  Widget _fundoCard(Fundo f) {
    final pos = f.variacao >= 0;
    final cor = pos ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);
    final corFundo = pos ? const Color(0xFFE6F4ED) : const Color(0xFFFFEBEB);
    final temDY = f.dividendYield > 0;
    final favoritado = _favoritos.contains(f.codigo);

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
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                f.codigo.length >= 2 ? f.codigo.substring(0, 2) : f.codigo,
                style: const TextStyle(
                  color: Colors.orange,
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
                Text(f.codigo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Row(
                  children: [
                    if (f.nome.isNotEmpty)
                      Flexible(
                        child: Text(
                          f.nome,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (temDY) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A5AE0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'DY ${f.dividendYield.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Color(0xFF6A5AE0),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(f.preco),
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
                  '${pos ? '+' : ''}${f.variacao.toStringAsFixed(2)}%',
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
            onTap: () => _toggleFavorito(f.codigo),
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
            Text('Nenhum fundo encontrado',
                style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          ],
        ),
      );
}