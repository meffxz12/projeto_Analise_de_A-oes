import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/apiservice.dart';

class GraficoAcao extends StatefulWidget {
  const GraficoAcao({super.key});

  @override
  State<GraficoAcao> createState() => _GraficoAcaoState();
}

class _GraficoAcaoState extends State<GraficoAcao> {
  List<FlSpot> _dados = [];
  List<FlSpot> _dadosVolume = [];
  bool _loading = true;
  String? _erro;
  String _periodoSelecionado = '1D';
  double _variacaoPercent = 0;
  double _variacaoValor = 0;
  double _precoAtual = 0;
  double _fechamentoAnterior = 0;
  List<String> _labels = [];

  final List<String> _periodos = ['1D', '1S', '1M', '3M', '1A'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  String _formatarLabel(dynamic item, String periodo) {
    try {
      final epoch = item['date'];
      if (epoch == null) return '';
      final dt = DateTime.fromMillisecondsSinceEpoch(
  (epoch as int) * 1000,
  isUtc: true,
).toLocal();
      if (periodo == '1D') {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
      // Limpa os dados anteriores para evitar render com estado inconsistente
      _dados = [];
      _dadosVolume = [];
      _labels = [];
    });

    try {
      final resposta = await ApiService.buscarGrafico("PETR4", _periodoSelecionado);

      if (resposta.isEmpty) {
        setState(() {
          _loading = false;
          _erro = 'Sem dados retornados';
        });
        return;
      }

      List<FlSpot> pontos = [];
      List<FlSpot> volume = [];
      List<String> labels = [];

      // Calcula volume máximo para normalizar
      double maxVol = 0;
      for (var item in resposta) {
        final vol = (item['volume'] as num?)?.toDouble() ?? 0;
        if (vol > maxVol) maxVol = vol;
      }

      final agora = DateTime.now();

          for (int i = 0; i < resposta.length; i++) {
            final item = resposta[i];

            final epoch = item['date'];
            if (epoch == null) continue;

            final dt = DateTime.fromMillisecondsSinceEpoch(
              (epoch as int) * 1000,
              isUtc: true,
            ).toLocal();

            
            if (dt.isAfter(agora)) continue;

            final preco = (item['price'] as num?)?.toDouble();
            if (preco == null || preco == 0) continue;

            final vol = (item['volume'] as num?)?.toDouble() ?? 0;
            final x = (item['x'] as num?)?.toDouble() ?? i.toDouble();

            pontos.add(FlSpot(x, preco));
            volume.add(FlSpot(x, maxVol > 0 ? vol / maxVol : 0));
            labels.add(_formatarLabel(item, _periodoSelecionado));
          }

      if (pontos.length < 2) {
        setState(() {
          _loading = false;
          _erro = 'Dados insuficientes';
        });
        return;
      }

      final inicio = pontos.first.y;
      final fim = pontos.last.y;

      setState(() {
        _dados = pontos;
        _dadosVolume = volume;
        _labels = labels;
        _variacaoPercent = ((fim - inicio) / inicio) * 100;
        _variacaoValor = fim - inicio;
        _fechamentoAnterior = inicio;
        _precoAtual = fim;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  Color get _cor =>
      _variacaoPercent >= 0 ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
              "Gráfico PETR4",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
        // ── Preço + variação ──────────────────────────────────
        if (!_loading && _erro == null && _precoAtual > 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _precoAtual.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'BRL',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _variacaoPercent >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: _cor,
                size: 20,
              ),
              Text(
                '${_variacaoValor >= 0 ? '+' : ''}${_variacaoValor.toStringAsFixed(2)} '
                '(${_variacaoPercent >= 0 ? '+' : ''}${_variacaoPercent.toStringAsFixed(2)}%) hoje',
                style: TextStyle(
                  color: _cor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // ── Gráfico ───────────────────────────────────────────
        if (_loading)
          const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_erro != null)
          SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _carregarDados,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          )
        else if (_dados.isEmpty)
          const SizedBox(
            height: 220,
            child: Center(child: Text('Sem dados')),
          )
        else
          Column(
            children: [
              // Gráfico de linha
              SizedBox(
                height: 170,
                child: LineChart(
                  LineChartData(
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.withOpacity(0.12),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.min || value == meta.max) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[400],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: _fechamentoAnterior,
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 48, bottom: 2),
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                            labelResolver: (_) =>
                                'Fechamento anterior: ${_fechamentoAnterior.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _dados,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: _cor,
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, _) =>
                              spot.x == _dados.last.x && spot.y == _dados.last.y,
                          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                            radius: 4,
                            color: _cor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              _cor.withOpacity(0.25),
                              _cor.withOpacity(0.02),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.black87,
                        getTooltipItems: (spots) => spots.map((spot) {
                          final idx = spot.x.toInt();
                          final label =
                              idx >= 0 && idx < _labels.length ? _labels[idx] : '';
                          return LineTooltipItem(
                            '$label\nR\$ ${spot.y.toStringAsFixed(2)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Barras de volume — só renderiza se tiver dados
              if (_dadosVolume.isNotEmpty)
                SizedBox(
                  height: 36,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 46,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: _dadosVolume.map((spot) {
                        return BarChartGroupData(
                          x: spot.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: spot.y,
                              color: _cor.withOpacity(0.35),
                              width: _dadosVolume.length > 60 ? 1.5 : 3,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 6),

              _buildEixoX(),
            ],
          ),

        const SizedBox(height: 16),

        // ── Seletor de período ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _periodos.map((periodo) {
            final sel = periodo == _periodoSelecionado;
            return GestureDetector(
              onTap: () {
                setState(() => _periodoSelecionado = periodo);
                _carregarDados();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF7B5EA7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periodo,
                  style: TextStyle(
                    color: sel ? Colors.white : Colors.grey[500],
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEixoX() {
    if (_labels.isEmpty) return const SizedBox();

    final total = _labels.length;
    final indices = [0, total ~/ 3, (total * 2) ~/ 3, total - 1];

    return Padding(
      padding: const EdgeInsets.only(right: 46),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: indices.map((i) {
          return Text(
            i < _labels.length ? _labels[i] : '',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          );
        }).toList(),
      ),
    );
  }
}