import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ─── Períodos disponíveis ─────────────────────────────────────────────────────
enum Periodo {
  semana('1wk', '1 sem', '5d', '1d'),
  mes('1mo', '1 mês', '1mo', '1d'),
  tresMeses('3mo', '3 meses', '3mo', '1d'),
  ano('1y', '1 ano', '1y', '1wk');

  const Periodo(this.range, this.label, this.apiRange, this.interval);
  final String range;
  final String label;
  final String apiRange;
  final String interval;
}

// ─── Widget ───────────────────────────────────────────────────────────────────
class GraficoAcao extends StatefulWidget {
  
  final String ticker;

  const GraficoAcao({super.key, this.ticker = 'PETR4'});

  @override
  State<GraficoAcao> createState() => _GraficoAcaoState();
}

class _GraficoAcaoState extends State<GraficoAcao> {
final _token = dotenv.env['BRAPI_TOKEN'];

  // Tickers rápidos no topo
  final _tickers = ['PETR4', 'VALE3', 'ITUB4', 'BBDC4', 'WEGE3', 'MXRF11'];

  late String _ticker;
  Periodo _periodo = Periodo.mes;

  List<FlSpot> _pontos = [];
  bool _loading = false;
  String? _erro;

  // Info do ativo
  double _precoAtual = 0;
  double _variacao = 0;
  double _minPeriodo = 0;
  double _maxPeriodo = 0;

  // Tooltip
  int? _tocandoIndex;

  @override
  void initState() {
    super.initState();
    _ticker = widget.ticker;
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() { _loading = true; _erro = null; _tocandoIndex = null; });
    try {
      final url = Uri.parse(
        'https://brapi.dev/api/quote/$_ticker'
        '?range=${_periodo.apiRange}&interval=${_periodo.interval}&token=$_token',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) throw Exception('Status ${resp.statusCode}');

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final result = (body['results'] as List?)?.first as Map<String, dynamic>?;
      if (result == null) throw Exception('Sem dados');

      final historico = result['historicalDataPrice'] as List? ?? [];

      final spots = <FlSpot>[];
      for (int i = 0; i < historico.length; i++) {
        final close = (historico[i]['close'] ?? historico[i]['open'] ?? 0).toDouble();
        if (close > 0) spots.add(FlSpot(i.toDouble(), close));
      }

      if (spots.isEmpty) throw Exception('Histórico vazio');

      final precos = spots.map((s) => s.y).toList();

      setState(() {
        _pontos = spots;
        _precoAtual = (result['regularMarketPrice'] ?? precos.last).toDouble();
        _variacao = (result['regularMarketChangePercent'] ?? 0).toDouble();
        _minPeriodo = precos.reduce((a, b) => a < b ? a : b);
        _maxPeriodo = precos.reduce((a, b) => a > b ? a : b);
        _loading = false;
      });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Color get _cor => _variacao >= 0 ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);
  Color get _corFundo => _variacao >= 0 ? const Color(0xFFE6F4ED) : const Color(0xFFFFEBEB);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SELETOR DE TICKER ──────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tickers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = _tickers[i];
              final ativo = t == _ticker;
              return GestureDetector(
                onTap: () { setState(() => _ticker = t); _buscar(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: ativo ? const Color(0xFF6A5AE0) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      t,
                      style: TextStyle(
                        color: ativo ? Colors.white : Colors.grey[600],
                        fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
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

        // ── PREÇO E VARIAÇÃO ──────────────────────────────
        if (!_loading && _erro == null) ...[
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _corFundo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_variacao >= 0 ? '+' : ''}${_variacao.toStringAsFixed(2)}%',
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
            'Mín: R\$ ${_minPeriodo.toStringAsFixed(2)}  ·  Máx: R\$ ${_maxPeriodo.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 14),
        ],

        // ── GRÁFICO ───────────────────────────────────────
        SizedBox(
          height: 150,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _erro != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart, color: Colors.grey[300], size: 36),
                          const SizedBox(height: 6),
                          Text('Sem dados', style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots
                                .map((s) => LineTooltipItem(
                                      'R\$ ${s.y.toStringAsFixed(2)}',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ))
                                .toList(),
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
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _cor.withOpacity(0.3),
                                  _cor.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),

        const SizedBox(height: 14),

        // ── SELETOR DE PERÍODO ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Periodo.values
              .map((p) => _btnPeriodo(p))
              .toList(),
        ),
      ],
    );
  }

  Widget _btnPeriodo(Periodo p) {
    final ativo = _periodo == p;
    return GestureDetector(
      onTap: () { setState(() => _periodo = p); _buscar(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF6A5AE0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          p.label,
          style: TextStyle(
            color: ativo ? Colors.white : Colors.grey[500],
            fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}