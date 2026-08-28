import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

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

  factory Fundo.fromJson(
    Map<String, dynamic> json,
  ) {
    double toDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
            value?.toString() ?? '',
          ) ??
          0.0;
    }

    return Fundo(
      codigo: (
        json['stock'] ??
        json['symbol'] ??
        ''
      ).toString(),
      nome: (
        json['name'] ??
        json['shortName'] ??
        json['longName'] ??
        ''
      ).toString(),
      preco: toDouble(
        json['close'] ??
            json['regularMarketPrice'],
      ),
      variacao: toDouble(
        json['change'] ??
            json['regularMarketChangePercent'],
      ),
      dividendYield: toDouble(
        json['dividendYield'],
      ),
      setor: (
        json['sector'] ??
        json['segment'] ??
        ''
      ).toString(),
    );
  }
}

class FundosScreen extends StatefulWidget {
  const FundosScreen({
    super.key,
  });

  @override
  State<FundosScreen> createState() =>
      _FundosScreenState();
}

class _FundosScreenState
    extends State<FundosScreen> {

  final TextEditingController _buscaCtrl =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  Timer? _debounce;

  final NumberFormat _currencyFormat =
      NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final Set<String> _favoritos = {};

  List<Fundo> _fundos = [];

  bool _loading = true;
  bool _carregandoMais = false;
  bool _temMais = true;

  String? _erro;

  int _pagina = 1;

  final int _limite = 50;

  String _busca = '';

  String _ordenar = 'Padrão';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _verificarScroll,
    );

    _buscaCtrl.addListener(
      _quandoBuscar,
    );

    _carregarFavoritos();

    _carregarFundos(
      primeiraCarga: true,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _buscaCtrl.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // SCROLL / PAGINAÇÃO
  // ============================================================

  void _verificarScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
            position.maxScrollExtent - 500 &&
        !_carregandoMais &&
        _temMais &&
        !_loading) {
      _carregarProximaPagina();
    }
  }

  // ============================================================
  // BUSCA
  // ============================================================

  void _quandoBuscar() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        final novaBusca =
            _buscaCtrl.text.trim();

        if (novaBusca == _busca) {
          return;
        }

        _busca = novaBusca;

        _carregarFundos(
          primeiraCarga: true,
        );
      },
    );
  }

  // ============================================================
  // CARREGAR FUNDOS
  // ============================================================

  Future<void> _carregarFundos({
    bool primeiraCarga = false,
  }) async {
    if (primeiraCarga) {
      setState(() {
        _loading = true;
        _erro = null;
        _pagina = 1;
        _temMais = true;
        _fundos = [];
      });
    }

    try {
      final data =
          await ApiService.buscarFundos(
        page: _pagina,
        limit: _limite,
        search: _busca,
        sortBy:
            _ordenar == 'Maior DY'
                ? 'change'
                : _ordenar == 'Menor Preço'
                    ? 'close'
                    : 'volume',
        sortOrder:
            _ordenar == 'Menor Preço'
                ? 'asc'
                : 'desc',
      );

      final stocks =
          data['stocks'] as List? ?? [];

      final novosFundos = stocks
          .whereType<Map>()
          .map(
            (item) => Fundo.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();

      final hasNext =
          data['hasNextPage'] == true;

      if (!mounted) return;

      setState(() {
        if (_pagina == 1) {
          _fundos = novosFundos;
        } else {
          _fundos.addAll(
            novosFundos,
          );
        }

        _temMais = hasNext;

        _loading = false;

        _carregandoMais = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _carregandoMais = false;
        _erro = e.toString();
      });
    }
  }

  // ============================================================
  // PRÓXIMA PÁGINA
  // ============================================================

  Future<void> _carregarProximaPagina() async {
    if (!_temMais ||
        _carregandoMais ||
        _loading) {
      return;
    }

    setState(() {
      _carregandoMais = true;
      _pagina++;
    });

    await _carregarFundos();
  }

  // ============================================================
  // FAVORITOS
  // ============================================================

  Future<void> _carregarFavoritos() async {
    try {
      final favoritos =
          await ApiService
              .listarFavoritosFundos();

      if (!mounted) return;

      setState(() {
        _favoritos
          ..clear()
          ..addAll(
            favoritos.map(
              (f) => (
                f['codigo'] ?? ''
              ).toString(),
            ),
          );
      });
    } catch (e) {
      debugPrint(
        '[FAVORITOS] Erro ao carregar fundos: $e',
      );
    }
  }

  Future<void> _toggleFavorito(
    String codigo,
  ) async {
    final jaFavoritado =
        _favoritos.contains(codigo);

    setState(() {
      if (jaFavoritado) {
        _favoritos.remove(codigo);
      } else {
        _favoritos.add(codigo);
      }
    });

    try {
      if (jaFavoritado) {
        await ApiService
            .removerFavoritoFundo(
          codigo,
        );
      } else {
        await ApiService
            .adicionarFavoritoFundo(
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
      // a UI já está mostrando de forma otimista. Não reverte
      // nesse caso — só reverte em erro de verdade (rede, 401
      // sem sessão válida, etc).
      // ========================================================

      final estadoJaEraOEsperado =
          mensagem.contains('já está nos favoritos') ||
          mensagem.contains('não encontrado nos favoritos') ||
          mensagem.contains('não encontrada nos favoritos');

      if (estadoJaEraOEsperado) {
        return;
      }

      setState(() {
        if (jaFavoritado) {
          _favoritos.add(codigo);
        } else {
          _favoritos.remove(codigo);
        }
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.grey[100],
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        10,
        10,
        20,
        24,
      ),
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          colors:
              CoresGlobais.backgrounder,
        ),
        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(28),
          bottomRight:
              Radius.circular(28),
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
                  Icons
                      .arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Fundos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
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
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: TextField(
                controller: _buscaCtrl,
                textCapitalization:
                    TextCapitalization
                        .characters,
                decoration:
                    InputDecoration(
                  hintText:
                      'Buscar fundo (ex: MXRF11)',
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
                      _busca.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                color:
                                    Colors.grey,
                              ),
                              onPressed: () {
                                _buscaCtrl
                                    .clear();
                              },
                            )
                          : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child:
                SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children: [
                  'Padrão',
                  'Maior DY',
                  'Menor Preço',
                ]
                    .map(
                      _chipOrdem,
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHIPS
  // ============================================================

  Widget _chipOrdem(
    String label,
  ) {
    final ativo =
        _ordenar == label;

    return GestureDetector(
      onTap: () {
        if (_ordenar == label) {
          return;
        }

        setState(() {
          _ordenar = label;
        });

        _carregarFundos(
          primeiraCarga: true,
        );
      },
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
        decoration:
            BoxDecoration(
          color: ativo
              ? Colors.white
              : Colors.white24,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
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

  // ============================================================
  // LISTA
  // ============================================================

  Widget _buildLista() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_erro != null &&
        _fundos.isEmpty) {
      return _erroWidget();
    }

    if (_fundos.isEmpty) {
      return _vazioWidget();
    }

    return RefreshIndicator(
      onRefresh: () =>
          _carregarFundos(
        primeiraCarga: true,
      ),
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
            _fundos.length +
                (_carregandoMais
                    ? 1
                    : 0),
        itemBuilder:
            (context, index) {
          if (index ==
              _fundos.length) {
            return const Padding(
              padding:
                  EdgeInsets.all(20),
              child: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          return _fundoCard(
            _fundos[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _fundoCard(
    Fundo f,
  ) {
    final positivo =
        f.variacao >= 0;

    final cor = positivo
        ? const Color(0xFF1B8A5A)
        : const Color(0xFFCC2929);

    final corFundo = positivo
        ? const Color(0xFFE6F4ED)
        : const Color(0xFFFFEBEB);

    final favoritado =
        _favoritos.contains(
      f.codigo,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
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
              color: Colors.orange
                  .withOpacity(
                0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Center(
              child: Text(
                f.codigo.length >= 2
                    ? f.codigo.substring(
                        0,
                        2,
                      )
                    : f.codigo,
                style:
                    const TextStyle(
                  color:
                      Colors.orange,
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
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  f.codigo,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                if (f.nome
                    .isNotEmpty)
                  Text(
                    f.nome,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      color:
                          Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat
                    .format(
                  f.preco,
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      corFundo,
                  borderRadius:
                      BorderRadius
                          .circular(
                    8,
                  ),
                ),
                child: Text(
                  '${positivo ? '+' : ''}${f.variacao.toStringAsFixed(2)}%',
                  style:
                      TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            width: 8,
          ),

          GestureDetector(
            onTap: () =>
                _toggleFavorito(
              f.codigo,
            ),
            child: Icon(
              favoritado
                  ? Icons
                      .star_rounded
                  : Icons
                      .star_outline_rounded,
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

  // ============================================================
  // ERRO
  // ============================================================

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
          const SizedBox(
            height: 8,
          ),
          Text(
            'Erro ao carregar fundos',
            style: TextStyle(
              color:
                  Colors.grey[500],
            ),
          ),
          TextButton(
            onPressed: () =>
                _carregarFundos(
              primeiraCarga: true,
            ),
            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VAZIO
  // ============================================================

  Widget _vazioWidget() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons
                .search_off_rounded,
            size: 56,
            color:
                Colors.grey[300],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            _busca.isEmpty
                ? 'Nenhum fundo encontrado'
                : 'Nenhum fundo encontrado para "$_busca"',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey[400],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}