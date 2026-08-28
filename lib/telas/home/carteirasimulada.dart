import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/perfilusuario.dart';

class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  List<dynamic> _ativos = [];

  bool _loading = true;

  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // ============================================================
  // CARREGAR CARTEIRA
  // ============================================================

  Future<void> _carregar() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _erro = null;
      });
    }

    try {
      final data =
          await ApiService.buscarCarteiraAtualizada();

      if (!mounted) return;

      setState(() {
        _ativos = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _loading = false;
      });

      debugPrint(
        'Erro ao carregar carteira: $e',
      );
    }
  }

  // ============================================================
  // TOTAL INVESTIDO
  // ============================================================

  double get _totalInvestido {
    return _ativos.fold(
      0.0,
      (sum, ativo) {
        return sum +
            ((ativo['investido'] ?? 0) as num)
                .toDouble();
      },
    );
  }

  // ============================================================
  // VALOR ATUAL DA CARTEIRA
  // ============================================================

  double get _valorAtual {
    return _ativos.fold(
      0.0,
      (sum, ativo) {
        return sum +
            ((ativo['valor_atual'] ?? 0) as num)
                .toDouble();
      },
    );
  }

  // ============================================================
  // GANHO / PERDA
  // ============================================================

  double get _ganhoPerda {
    return _valorAtual - _totalInvestido;
  }

  // ============================================================
  // RENTABILIDADE TOTAL
  // ============================================================

  double get _rentabilidade {
    if (_totalInvestido <= 0) {
      return 0;
    }

    return (
      _ganhoPerda /
      _totalInvestido
    ) * 100;
  }

  // ============================================================
  // REMOVER ATIVO
  // ============================================================

  Future<void> _remover(int itemId) async {
    try {
      await ApiService.removerAtivoCarteira(
        itemId,
      );

      await _carregar();
    } catch (e) {
      debugPrint(
        'Erro ao remover ativo: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // MODAL ADICIONAR
  // ============================================================

  void _mostrarModalAdicionar() {
    final codigoCtrl =
        TextEditingController();

    final qtdCtrl =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx)
                  .viewInsets
                  .bottom +
              20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar ativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  codigoCtrl,
              textCapitalization:
                  TextCapitalization
                      .characters,
              decoration:
                  InputDecoration(
                labelText:
                    'Código (ex: PETR4)',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              controller:
                  qtdCtrl,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    'Quantidade de ações',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF6A5AE0,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),

                onPressed:
                    () async {
                  final codigo =
                      codigoCtrl
                          .text
                          .trim()
                          .toUpperCase();

                  final qtd =
                      double.tryParse(
                            qtdCtrl
                                .text
                                .trim()
                                .replaceAll(
                                  ',',
                                  '.',
                                ),
                          ) ??
                          0;

                  if (codigo.isEmpty ||
                      qtd <= 0) {
                    return;
                  }

                  Navigator.pop(
                    ctx,
                  );

                  try {
                    await ApiService
                        .adicionarAtivoCarteira(
                      codigo,
                      qtd,
                    );

                    await _carregar();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(
                            e
                                .toString()
                                .replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                          ),
                        ),
                      );
                    }
                  }
                },

                child:
                    const Text(
                  'Adicionar',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATAR DINHEIRO
  // ============================================================

  String _formatarDinheiro(
    double valor,
  ) {
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final positivo =
        _ganhoPerda >= 0;

    final corResultado =
        positivo
            ? const Color(
                0xFF1B8A5A,
              )
            : const Color(
                0xFFCC2929,
              );

    return Scaffold(
      backgroundColor:
          Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                20,
                20,
                28,
              ),

              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  colors:
                      CoresGlobais
                          .backgrounder,
                ),

                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    28,
                  ),
                  bottomRight:
                      Radius.circular(
                    28,
                  ),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // ==========================================
                  // TÍTULO + PERFIL
                  // ==========================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Row(
                        children: [
                          Icon(
                            Icons
                                .account_balance_wallet_rounded,
                            color:
                                Colors.white,
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          Text(
                            'Carteira Simulada',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PerfilScreen(),
                            ),
                          );
                        },

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),

                        child:
                            const CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Colors
                                  .white24,
                          child:
                              Icon(
                            Icons
                                .person_rounded,
                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==========================================
                  // RESUMO DA CARTEIRA
                  // ==========================================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child:
                        _loading
                            ? const Center(
                                child:
                                    CircularProgressIndicator(),
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    'Resumo da carteira',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[500],
                                      fontSize:
                                          13,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  // =================================
                                  // VALOR ATUAL
                                  // =================================

                                  Text(
                                    _formatarDinheiro(
                                      _valorAtual,
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          28,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      letterSpacing:
                                          -0.5,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  // =================================
                                  // INVESTIDO
                                  // =================================

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [

                                      Text(
                                        'Total investido',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey[500],
                                          fontSize:
                                              12,
                                        ),
                                      ),

                                      Text(
                                        _formatarDinheiro(
                                          _totalInvestido,
                                        ),
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize:
                                              13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  // =================================
                                  // GANHO / PERDA
                                  // =================================

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [

                                      Text(
                                        'Resultado',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey[500],
                                          fontSize:
                                              12,
                                        ),
                                      ),

                                      Text(
                                        '${positivo ? '+' : ''}${_formatarDinheiro(_ganhoPerda)} (${positivo ? '+' : ''}${_rentabilidade.toStringAsFixed(2)}%)',
                                        style:
                                            TextStyle(
                                          color:
                                              corResultado,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  // =================================
                                  // QUANTIDADE DE ATIVOS
                                  // =================================

                                  Text(
                                    '${_ativos.length} posição${_ativos.length != 1 ? 'ões' : ''}',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[400],
                                      fontSize:
                                          11,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // HEADER DA LISTA
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 15,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    'Meus ativos',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                      fontSize: 16,
                    ),
                  ),

                  TextButton.icon(
                    onPressed:
                        _mostrarModalAdicionar,

                    icon:
                        const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),

                    label:
                        const Text(
                      'Adicionar',
                    ),

                    style:
                        TextButton
                            .styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF6A5AE0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // DICA SWIPE
            // ==================================================

            if (!_loading &&
                _erro == null &&
                _ativos.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  15,
                  4,
                  15,
                  0,
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons
                          .swipe_left_rounded,
                      size: 14,
                      color:
                          Colors.grey[400],
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      'Arraste um ativo para o lado para removê-lo',
                      style:
                          TextStyle(
                        color:
                            Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // LISTA
            // ==================================================

            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : _erro != null
                      ? Center(
                          child:
                              Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [

                              Icon(
                                Icons
                                    .error_outline,
                                color:
                                    Colors.grey[400],
                                size: 40,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                'Erro ao carregar',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey[500],
                                ),
                              ),

                              TextButton(
                                onPressed:
                                    _carregar,
                                child:
                                    const Text(
                                  'Tentar novamente',
                                ),
                              ),
                            ],
                          ),
                        )

                      : _ativos.isEmpty
                          ? Center(
                              child:
                                  Column(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,

                                children: [

                                  Icon(
                                    Icons
                                        .account_balance_wallet_outlined,
                                    size: 56,
                                    color:
                                        Colors.grey[300],
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  Text(
                                    'Carteira vazia',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[400],
                                      fontSize:
                                          16,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Toque em Adicionar para começar',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[400],
                                      fontSize:
                                          13,
                                    ),
                                  ),
                                ],
                              ),
                            )

                          : RefreshIndicator(
                              onRefresh:
                                  _carregar,

                              child:
                                  ListView.builder(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      15,
                                ),

                                itemCount:
                                    _ativos.length,

                                itemBuilder:
                                    (
                                  context,
                                  i,
                                ) =>
                                        _ativoCard(
                                  _ativos[i],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD DO ATIVO
  // ============================================================

  Widget _ativoCard(
    dynamic ativo,
  ) {
    final codigo =
        ativo['codigo']
                ?.toString() ??
            '';

    final nome =
        ativo['nome']
                ?.toString() ??
            codigo;

    final quantidade =
        ((ativo['quantidade'] ?? 0)
                as num)
            .toDouble();

    final precoCompra =
        ((ativo['preco_compra'] ?? 0)
                as num)
            .toDouble();

    final investido =
        ((ativo['investido'] ?? 0)
                as num)
            .toDouble();

    final precoAtual =
        ((ativo['preco_atual'] ?? 0)
                as num)
            .toDouble();

    final valorAtual =
        ((ativo['valor_atual'] ?? 0)
                as num)
            .toDouble();

    final ganhoPerda =
        ((ativo['ganho_perda'] ?? 0)
                as num)
            .toDouble();

    final variacao =
        ((ativo['variacao'] ?? 0)
                as num)
            .toDouble();

    final positivo =
        ganhoPerda >= 0;

    final cor =
        positivo
            ? const Color(
                0xFF1B8A5A,
              )
            : const Color(
                0xFFCC2929,
              );

    final corFundo =
        positivo
            ? const Color(
                0xFFE6F4ED,
              )
            : const Color(
                0xFFFFEBEB,
              );

    final qtdFormatada =
        quantidade ==
                quantidade
                    .truncateToDouble()
            ? quantidade
                .toInt()
                .toString()
            : quantidade
                .toStringAsFixed(
                2,
              );

    return Dismissible(
      key: Key(
        '${codigo}_${ativo['id']}',
      ),

      direction:
          DismissDirection
              .endToStart,

      background:
          Container(
        margin:
            const EdgeInsets
                .only(
          bottom: 10,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.red[400],
          borderRadius:
              BorderRadius
                  .circular(
            16,
          ),
        ),

        alignment:
            Alignment.centerRight,

        padding:
            const EdgeInsets
                .only(
          right: 20,
        ),

        child:
            const Icon(
          Icons.delete_rounded,
          color:
              Colors.white,
        ),
      ),

      onDismissed: (_) {
        final itemId =
            ativo['id'];

        if (itemId != null) {
          _remover(
            itemId as int,
          );
        }
      },

      child:
          Container(
        margin:
            const EdgeInsets
                .only(
          bottom: 10,
        ),

        padding:
            const EdgeInsets
                .all(
          14,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius
                  .circular(
            16,
          ),

          boxShadow:
              const [
            BoxShadow(
              color:
                  Colors.black12,
              blurRadius:
                  5,
              offset:
                  Offset(
                0,
                2,
              ),
            ),
          ],
        ),

        child:
            Column(
          children: [

            // ==================================================
            // PRIMEIRA LINHA
            // ==================================================

            Row(
              children: [

                Container(
                  width: 44,
                  height: 44,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF6A5AE0,
                    ).withOpacity(
                      0.1,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),

                  child:
                      Center(
                    child:
                        Text(
                      codigo.length >=
                              2
                          ? codigo
                              .substring(
                              0,
                              2,
                            )
                          : codigo,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6A5AE0,
                        ),
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        codigo,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize:
                              15,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        nome,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color:
                              Colors.grey[500],
                          fontSize:
                              12,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        '$qtdFormatada ações',
                        style:
                            TextStyle(
                          color:
                              Colors.grey[400],
                          fontSize:
                              11,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,

                  children: [

                    Text(
                      _formatarDinheiro(
                        valorAtual,
                      ),

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            15,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            8,
                        vertical:
                            3,
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

                      child:
                          Text(
                        '${positivo ? '+' : ''}${_formatarDinheiro(ganhoPerda)}',

                        style:
                            TextStyle(
                          color:
                              cor,
                          fontSize:
                              12,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // DIVISÓRIA
            // ==================================================

            Divider(
              height: 1,
              color:
                  Colors.grey[200],
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // INFORMAÇÕES FINANCEIRAS
            // ==================================================

            Row(
              children: [

                Expanded(
                  child:
                      _infoFinanceira(
                    titulo:
                        'Investido',
                    valor:
                        _formatarDinheiro(
                      investido,
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _infoFinanceira(
                    titulo:
                        'Preço compra',
                    valor:
                        _formatarDinheiro(
                      precoCompra,
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _infoFinanceira(
                    titulo:
                        'Preço atual',
                    valor:
                        _formatarDinheiro(
                      precoAtual,
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _infoFinanceira(
                    titulo:
                        'Rentabilidade',
                    valor:
                        '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(2)}%',
                    valorCor:
                        cor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMAÇÃO FINANCEIRA
  // ============================================================

  Widget _infoFinanceira({
    required String titulo,
    required String valor,
    Color? valorCor,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          titulo,
          style:
              TextStyle(
            color:
                Colors.grey[400],
            fontSize:
                10,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          valor,
          style:
              TextStyle(
            color:
                valorCor ??
                    Colors.grey[700],
            fontSize:
                11,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

