import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

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

  factory Acao.fromJson(Map<String, dynamic> j) {
    return Acao(
      codigo: (j['stock'] ?? j['symbol'] ?? '').toString(),
      nome: (j['name'] ??
              j['shortName'] ??
              j['longName'] ??
              j['symbol'] ??
              '')
          .toString(),
      preco: _toDouble(
        j['close'] ?? j['regularMarketPrice'],
      ),
      variacao: _toDouble(
        j['change'] ?? j['regularMarketChangePercent'],
      ),
      volume: _toDouble(
        j['volume'] ?? j['regularMarketVolume'],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(',', '.'),
        ) ??
        0.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AcoesScreen extends StatefulWidget {
  const AcoesScreen({super.key});

  @override
  State<AcoesScreen> createState() => _AcoesScreenState();
}

class _AcoesScreenState extends State<AcoesScreen> {
  final String? _token = dotenv.env['BRAPI_TOKEN'];

  final TextEditingController _buscaCtrl = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  // Lista acumulada de ações.
  final List<Acao> _lista = [];

  // Lista exibida depois dos filtros.
  List<Acao> _filtrada = [];

  // Favoritos vindos do backend.
  final Set<String> _favoritos = {};

  bool _loading = true;
  bool _carregandoMais = false;

  String? _erro;

  String _busca = '';
  String _filtro = 'Todos';

  // Paginação BRAPI.
  int _paginaAtual = 1;
  int _totalPaginas = 1;

  bool _temProximaPagina = false;

  // Evita requisições simultâneas.
  bool _requisicaoEmAndamento = false;

  // ───────────────────────────────────────────────────────────────────────────
  // INIT
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _buscaCtrl.addListener(_onBuscaAlterada);

    _scrollController.addListener(_onScroll);

    _carregarFavoritos();

    _carregarPrimeiraPagina();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUSCA
  // ───────────────────────────────────────────────────────────────────────────

  void _onBuscaAlterada() {
    final texto = _buscaCtrl.text.trim().toUpperCase();

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        if (texto == _busca) return;

        _busca = texto;

        _carregarPrimeiraPagina();
      },
    );

    setState(() {});
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SCROLL / PAGINAÇÃO
  // ───────────────────────────────────────────────────────────────────────────

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final posicao = _scrollController.position;

    // Começa a buscar a próxima página quando estiver
    // próximo do final da lista.
    if (posicao.pixels >= posicao.maxScrollExtent - 500) {
      _carregarProximaPagina();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARREGAR PRIMEIRA PÁGINA
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _carregarPrimeiraPagina() async {
    if (_requisicaoEmAndamento) return;

    if (!mounted) return;

    setState(() {
      _loading = true;
      _erro = null;

      _paginaAtual = 1;
      _totalPaginas = 1;
      _temProximaPagina = false;

      _lista.clear();
      _filtrada.clear();
    });

    await _buscarPagina(
      pagina: 1,
      substituir: true,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARREGAR PRÓXIMA PÁGINA
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _carregarProximaPagina() async {
    if (_requisicaoEmAndamento) return;

    if (!_temProximaPagina) return;

    final proximaPagina = _paginaAtual + 1;

    await _buscarPagina(
      pagina: proximaPagina,
      substituir: false,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUSCAR PÁGINA NA BRAPI
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _buscarPagina({
    required int pagina,
    required bool substituir,
  }) async {
    if (_requisicaoEmAndamento) return;

    _requisicaoEmAndamento = true;

    if (!substituir && mounted) {
      setState(() {
        _carregandoMais = true;
      });
    }

    try {
      final params = <String, String>{
        'type': 'stock',

        // 50 por página.
        'limit': '50',

        // Paginação.
        'page': pagina.toString(),

        // Mais negociadas primeiro.
        'sortBy': 'volume',
        'sortOrder': 'desc',
      };

      // Busca diretamente na BRAPI.
      if (_busca.isNotEmpty) {
        params['search'] = _busca;
      }

      // Token.
      if (_token != null && _token!.trim().isNotEmpty) {
        params['token'] = _token!.trim();
      }

      final uri = Uri.https(
        'brapi.dev',
        '/api/quote/list',
        params,
      );

      debugPrint('============================================');
      debugPrint('[BRAPI AÇÕES]');
      debugPrint('Página: $pagina');
      debugPrint('Busca: $_busca');
      debugPrint('URL: $uri');

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      debugPrint(
        '[BRAPI AÇÕES] Status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'BRAPI retornou status ${response.statusCode}',
        );
      }

      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      // ─────────────────────────────────────────────────────────
      // ATIVOS
      // ─────────────────────────────────────────────────────────

      final stocks = (data['stocks'] as List? ?? [])
          .whereType<Map>()
          .map(
            (item) => Acao.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (acao) => acao.codigo.isNotEmpty,
          )
          .toList();

      // ─────────────────────────────────────────────────────────
      // PAGINAÇÃO
      // ─────────────────────────────────────────────────────────

      final currentPage =
          _toInt(data['currentPage']) ?? pagina;

      final totalPages =
          _toInt(data['totalPages']) ?? 1;

      final hasNextPage =
          data['hasNextPage'] == true ||
          currentPage < totalPages;

      if (!mounted) return;

      setState(() {
        if (substituir) {
          _lista.clear();
        }

        // Evita duplicação de ações.
        for (final acao in stocks) {
          final existe = _lista.any(
            (item) => item.codigo == acao.codigo,
          );

          if (!existe) {
            _lista.add(acao);
          }
        }

        _paginaAtual = currentPage;
        _totalPaginas = totalPages;
        _temProximaPagina = hasNextPage;

        _aplicarFiltro();

        _loading = false;
        _carregandoMais = false;
      });

      debugPrint(
        '[BRAPI AÇÕES] Recebidas: ${stocks.length}',
      );

      debugPrint(
        '[BRAPI AÇÕES] Página: '
        '$_paginaAtual/$_totalPaginas',
      );

      debugPrint(
        '[BRAPI AÇÕES] Próxima página: '
        '$_temProximaPagina',
      );
    } catch (e) {
      debugPrint(
        '[BRAPI AÇÕES] ERRO: $e',
      );

      if (!mounted) return;

      setState(() {
        if (substituir) {
          _erro = e.toString();
          _loading = false;
        }

        _carregandoMais = false;
      });
    } finally {
      _requisicaoEmAndamento = false;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CONVERTER INT
  // ───────────────────────────────────────────────────────────────────────────

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FAVORITOS
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _carregarFavoritos() async {
    try {
      final favoritos =
          await ApiService.listarFavoritosAcoes();

      if (!mounted) return;

      setState(() {
        _favoritos
          ..clear()
          ..addAll(
            favoritos.map(
              (f) => (f['codigo'] ?? '').toString(),
            ),
          );
      });
    } catch (e) {
      debugPrint(
        '[FAVORITOS] Erro ao carregar ações: $e',
      );
    }
  }

  Future<void> _toggleFavorito(
    String codigo,
  ) async {
    final jaFavoritado =
        _favoritos.contains(codigo);

    // Atualização otimista.
    setState(() {
      if (jaFavoritado) {
        _favoritos.remove(codigo);
      } else {
        _favoritos.add(codigo);
      }
    });

    try {
      if (jaFavoritado) {
        await ApiService.removerFavoritoAcao(
          codigo,
        );
      } else {
        await ApiService.adicionarFavoritoAcao(
          codigo,
        );
      }
    } catch (e) {
      if (!mounted) return;

      final mensagem = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      // ========================================================
      // O backend recusou porque o estado real já é o mesmo que
      // a UI já está mostrando de forma otimista (ex: tentou
      // adicionar algo que já estava favoritado, ou remover algo
      // que já tinha sido removido). Isso normalmente acontece
      // quando _carregarFavoritos() ainda não tinha terminado
      // quando o usuário clicou. Nesse caso NÃO revertemos —
      // o estado otimista já está correto.
      // ========================================================

      final estadoJaEraOEsperado =
          mensagem.contains('já está nos favoritos') ||
          mensagem.contains('não encontrada nos favoritos') ||
          mensagem.contains('não encontrado nos favoritos');

      if (estadoJaEraOEsperado) {
        return;
      }

      // Reverte caso a API falhe de verdade.
      setState(() {
        if (jaFavoritado) {
          _favoritos.add(codigo);
        } else {
          _favoritos.remove(codigo);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FILTROS
  // ───────────────────────────────────────────────────────────────────────────

  void _aplicarFiltro() {
    var lista = List<Acao>.from(_lista);

    if (_filtro == 'Alta') {
      lista = lista
          .where(
            (a) => a.variacao > 0,
          )
          .toList();
    }

    if (_filtro == 'Baixa') {
      lista = lista
          .where(
            (a) => a.variacao < 0,
          )
          .toList();
    }

    _filtrada = lista;
  }

  void _setFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
      _aplicarFiltro();
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // REFRESH
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    await _carregarPrimeiraPagina();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _buildLista(),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HEADER
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: CoresGlobais.backgrounder,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(context),
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
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: TextField(
                controller: _buscaCtrl,

                textCapitalization:
                    TextCapitalization.characters,

                decoration:
                    InputDecoration(
                  hintText:
                      'Buscar ação (ex: PETR4)',

                  hintStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  border:
                      InputBorder.none,

                  icon:
                      const Icon(
                    Icons.search_rounded,
                    color:
                        Color(0xFF6A5AE0),
                  ),

                  suffixIcon:
                      _buscaCtrl.text.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                color:
                                    Colors.grey,
                              ),
                              onPressed: () {
                                _buscaCtrl.clear();
                              },
                            )
                          : null,
                ),

                onSubmitted: (_) {
                  if (_debounce?.isActive ??
                      false) {
                    _debounce!.cancel();
                  }

                  _busca = _buscaCtrl.text
                      .trim()
                      .toUpperCase();

                  _carregarPrimeiraPagina();
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),

            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,

              child: Row(
                children: [
                  'Todos',
                  'Alta',
                  'Baixa',
                ]
                    .map(_chipFiltro)
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LISTA
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildLista() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_erro != null &&
        _lista.isEmpty) {
      return _erroWidget();
    }

    if (_filtrada.isEmpty) {
      return _vazioWidget();
    }

    return RefreshIndicator(
      onRefresh: _refresh,

      child: ListView.builder(
        controller:
            _scrollController,

        padding:
            const EdgeInsets.fromLTRB(
          15,
          16,
          15,
          20,
        ),

        itemCount:
            _filtrada.length +
                (_carregandoMais ||
                        _temProximaPagina
                    ? 1
                    : 0),

        itemBuilder: (_, index) {
          if (index >=
              _filtrada.length) {
            return _buildIndicadorPagina();
          }

          return _acaoCard(
            _filtrada[index],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // INDICADOR DE PAGINAÇÃO
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildIndicadorPagina() {
    if (_carregandoMais) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_temProximaPagina) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Center(
          child: Text(
            'Role para carregar mais ações...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Center(
        child: Text(
          'Todas as ações carregadas',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CHIP
  // ───────────────────────────────────────────────────────────────────────────

  Widget _chipFiltro(
    String label,
  ) {
    final ativo =
        _filtro == label;

    return GestureDetector(
      onTap: () =>
          _setFiltro(label),

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        margin:
            const EdgeInsets.only(
          right: 8,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),

        decoration: BoxDecoration(
          color: ativo
              ? Colors.white
              : Colors.white24,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Text(
          label,

          style: TextStyle(
            color: ativo
                ? const Color(
                    0xFF6A5AE0,
                  )
                : Colors.white,

            fontWeight: ativo
                ? FontWeight.bold
                : FontWeight.normal,

            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD
  // ───────────────────────────────────────────────────────────────────────────

  Widget _acaoCard(
    Acao a,
  ) {
    final pos =
        a.variacao >= 0;

    final cor = pos
        ? const Color(0xFF1B8A5A)
        : const Color(0xFFCC2929);

    final corFundo = pos
        ? const Color(0xFFE6F4ED)
        : const Color(0xFFFFEBEB);

    final favoritado =
        _favoritos.contains(
      a.codigo,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset:
                Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF6A5AE0,
              ).withOpacity(0.1),

              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),

            child: Center(
              child: Text(
                a.codigo.length >= 2
                    ? a.codigo.substring(
                        0,
                        2,
                      )
                    : a.codigo,

                style:
                    const TextStyle(
                  color:
                      Color(0xFF6A5AE0),
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  a.codigo,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                if (a.nome.isNotEmpty)
                  Text(
                    a.nome,

                    style:
                        TextStyle(
                      color:
                          Colors.grey[500],
                      fontSize: 12,
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Text(
                'R\$ ${a.preco.toStringAsFixed(2)}',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),

                decoration:
                    BoxDecoration(
                  color: corFundo,

                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),

                child: Text(
                  '${pos ? '+' : ''}${a.variacao.toStringAsFixed(2)}%',

                  style: TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: () =>
                _toggleFavorito(
              a.codigo,
            ),

            child: Icon(
              favoritado
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,

              color: favoritado
                  ? Colors.amber
                  : Colors.grey[400],

              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ERRO
  // ───────────────────────────────────────────────────────────────────────────

  Widget _erroWidget() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            Icons.error_outline,
            color:
                Colors.grey[400],
            size: 40,
          ),

          const SizedBox(height: 8),

          Text(
            'Erro ao carregar ações',
            style: TextStyle(
              color:
                  Colors.grey[500],
            ),
          ),

          TextButton(
            onPressed:
                _carregarPrimeiraPagina,

            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // VAZIO
  // ───────────────────────────────────────────────────────────────────────────

  Widget _vazioWidget() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color:
                Colors.grey[300],
          ),

          const SizedBox(height: 12),

          Text(
            _busca.isEmpty
                ? 'Nenhuma ação encontrada'
                : 'Nenhuma ação encontrada para "$_busca"',

            style: TextStyle(
              color:
                  Colors.grey[400],
              fontSize: 15,
            ),

            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _debounce?.cancel();

    _buscaCtrl.dispose();

    _scrollController.dispose();

    super.dispose();
  }
}