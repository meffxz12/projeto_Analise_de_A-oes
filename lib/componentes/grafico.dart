import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

// ─── Períodos disponíveis ─────────────────────────────────────────────────────

enum Periodo {
  semana('1 sem', '1wk'),
  mes('1 mês', '1mo'),
  tresMeses('3 meses', '3mo'),
  ano('1 ano', '1y');

  const Periodo(this.label, this.apiPeriodo);

  final String label;
  final String apiPeriodo;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class GraficoAcao extends StatefulWidget {
  final String ticker;

  const GraficoAcao({
    super.key,
    this.ticker = 'PETR4',
  });

  @override
  State<GraficoAcao> createState() => _GraficoAcaoState();
}

class _GraficoAcaoState extends State<GraficoAcao> {
  // ==========================================================
  // TICKERS
  // ==========================================================

  final _tickers = [
  'PETR4',
  'VALE3',
  'ITUB4',
  'BBDC4',
  'BBAS3',
  'ABEV3',
  'WEGE3',
  'MGLU3',
  'RENT3',
  'MXRF11',
];

  // ==========================================================
  // ESTADO
  // ==========================================================

  late String _ticker;

  Periodo _periodo = Periodo.mes;

  List<FlSpot> _pontos = [];

  bool _loading = false;

  String? _erro;

  // ==========================================================
  // INFORMAÇÕES
  // ==========================================================

  double _precoAtual = 0;

  double _variacao = 0;

  double _minPeriodo = 0;

  double _maxPeriodo = 0;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _ticker = widget.ticker;

    _buscar();
  }

  // ==========================================================
  // BUSCAR DADOS
  // ==========================================================

  Future<void> _buscar() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _erro = null;
      _pontos = [];
    });

    try {
      // ========================================================
      // FASTAPI
      // ========================================================

      final dados = await ApiService.buscarGrafico(
        _ticker,
        _periodo.apiPeriodo,
      );

      if (!mounted) return;

      if (dados.isEmpty) {
        throw Exception(
          'Nenhum dado encontrado para $_ticker.',
        );
      }

      // ========================================================
      // TRANSFORMAR DADOS EM FLSPOT
      //
      // API:
      //
      // {
      //   "x": 0,
      //   "price": 42,
      //   "volume": 31465400,
      //   "date": 1785294000
      // }
      //
      // ========================================================

      final pontos = <FlSpot>[];

      for (final item in dados) {
        final x = item['x'];

        final price = item['price'];

        if (x == null || price == null) {
          continue;
        }

        final xNumero = double.tryParse(
          x.toString(),
        );

        final preco = double.tryParse(
          price.toString(),
        );

        if (xNumero == null ||
            preco == null ||
            preco <= 0) {
          continue;
        }

        pontos.add(
          FlSpot(
            xNumero,
            preco,
          ),
        );
      }

      if (pontos.isEmpty) {
        throw Exception(
          'Não foi possível montar o gráfico.',
        );
      }

      // ========================================================
      // PREÇOS
      // ========================================================

      final precos = pontos
          .map((ponto) => ponto.y)
          .toList();

      // ========================================================
      // PREÇO ATUAL
      // ========================================================

      final precoAtual = precos.last;

      // ========================================================
      // VARIAÇÃO DO PERÍODO
      // ========================================================

      final primeiroPreco = precos.first;

      double variacao = 0;

      if (primeiroPreco > 0) {
        variacao =
            ((precoAtual - primeiroPreco) /
                    primeiroPreco) *
                100;
      }

      // ========================================================
      // MÍNIMO
      // ========================================================

      final minimo = precos.reduce(
        (a, b) => a < b ? a : b,
      );

      // ========================================================
      // MÁXIMO
      // ========================================================

      final maximo = precos.reduce(
        (a, b) => a > b ? a : b,
      );

      // ========================================================
      // ATUALIZAR
      // ========================================================

      setState(() {
        _pontos = pontos;

        _precoAtual = precoAtual;

        _variacao = variacao;

        _minPeriodo = minimo;

        _maxPeriodo = maximo;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      print('====================================');
      print('ERRO NO GRÁFICO');
      print('ATIVO: $_ticker');
      print('PERÍODO: ${_periodo.apiPeriodo}');
      print('ERRO: $e');
      print('====================================');

      setState(() {
        _loading = false;

        _erro = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ==========================================================
  // COR
  // ==========================================================

  Color get _cor {
    return _variacao >= 0
        ? const Color(0xFF1B8A5A)
        : const Color(0xFFCC2929);
  }

  Color get _corFundo {
    return _variacao >= 0
        ? const Color(0xFFE6F4ED)
        : const Color(0xFFFFEBEB);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // SELETOR DE ATIVOS
        // ======================================================

        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tickers.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final ticker = _tickers[index];

              final selecionado =
                  ticker == _ticker;

              return GestureDetector(
                onTap: () {
                  if (_ticker == ticker) {
                    return;
                  }

                  setState(() {
                    _ticker = ticker;
                  });

                  _buscar();
                },
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selecionado
                        ? CoresGlobais.botao2
                        : Colors.grey[100],
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      ticker,
                      style: TextStyle(
                        color: selecionado
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: selecionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ======================================================
        // PREÇO
        // ======================================================

        if (!_loading && _erro == null)
          ...[
            Row(
              children: [
                Text(
                  'R\$ ${_precoAtual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _corFundo,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_variacao >= 0 ? '+' : ''}'
                    '${_variacao.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: _cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              'Mín: R\$ ${_minPeriodo.toStringAsFixed(2)}'
              '  ·  '
              'Máx: R\$ ${_maxPeriodo.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),
          ],

        // ======================================================
        // GRÁFICO
        // ======================================================

        SizedBox(
          height: 150,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _erro != null
                  ? _buildErro()
                  : _pontos.isEmpty
                      ? _buildSemDados()
                      : _buildGrafico(),
        ),

        const SizedBox(height: 14),

        // ======================================================
        // PERÍODOS
        // ======================================================

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: Periodo.values
              .map(
                (periodo) =>
                    _btnPeriodo(periodo),
              )
              .toList(),
        ),
      ],
    );
  }

  // ==========================================================
  // GRÁFICO
  // ==========================================================

  Widget _buildGrafico() {
    final precos = _pontos
        .map((ponto) => ponto.y)
        .toList();

    final menor = precos.reduce(
      (a, b) => a < b ? a : b,
    );

    final maior = precos.reduce(
      (a, b) => a > b ? a : b,
    );

    double margem =
        (maior - menor) * 0.15;

    // Evita problema quando os preços são praticamente iguais.
    if (margem == 0) {
      margem = maior * 0.02;
    }

    return LineChart(
      LineChartData(
        minY: menor - margem,

        maxY: maior + margem,

        gridData: const FlGridData(
          show: false,
        ),

        borderData: FlBorderData(
          show: false,
        ),

        titlesData: const FlTitlesData(
          show: false,
        ),

        lineTouchData: LineTouchData(
          touchTooltipData:
              LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map(
                (spot) {
                  return LineTooltipItem(
                    'R\$ ${spot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ).toList();
            },
          ),

          handleBuiltInTouches: true,
        ),

        lineBarsData: [
          LineChartBarData(
            spots: _pontos,

            isCurved: true,

            curveSmoothness: 0.25,

            color: _cor,

            barWidth: 2.2,

            dotData: const FlDotData(
              show: false,
            ),

            belowBarData: BarAreaData(
              show: true,

              gradient: LinearGradient(
                begin:
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
                colors: [
                  _cor.withOpacity(0.3),
                  _cor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERRO
  // ==========================================================

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[300],
            size: 36,
          ),

          const SizedBox(height: 6),

          Text(
            _erro ?? 'Sem dados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          TextButton(
            onPressed: _buscar,
            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEM DADOS
  // ==========================================================

  Widget _buildSemDados() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart,
            color: Colors.grey[300],
            size: 36,
          ),

          const SizedBox(height: 6),

          Text(
            'Sem dados',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTÃO DE PERÍODO
  // ==========================================================

  Widget _btnPeriodo(Periodo periodo) {
    final ativo = _periodo == periodo;

    return GestureDetector(
      onTap: () {
        if (_periodo == periodo) {
          return;
        }

        setState(() {
          _periodo = periodo;
        });

        _buscar();
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: ativo
              ? CoresGlobais.botao2
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Text(
          periodo.label,
          style: TextStyle(
            color: ativo
                ? Colors.white
                : Colors.grey[500],
            fontWeight: ativo
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

