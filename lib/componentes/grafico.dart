import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/apiservice.dart';

class GraficoIbovespa extends StatefulWidget {
  const GraficoIbovespa({super.key});

  @override
  State<GraficoIbovespa> createState() => _GraficoIbovespaState();
}

class _GraficoIbovespaState extends State<GraficoIbovespa> {
  List<FlSpot>? _cachedData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final dados = await buscarGrafico("^BVSP");
      List<FlSpot> pontos = [];

      for (int i = 0; i < dados.length; i++) {
        final preco = dados[i]['close'];

        if (preco != null) {
          pontos.add(FlSpot(i.toDouble(), preco.toDouble()));
        }
      }

      setState(() {
        _cachedData = pontos;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      // 🔄 FALLBACK: Dados mock se a API falhar
      _loadMockData();
    }
  }

  // 📊 Dados mock para quando a API não estiver disponível
  void _loadMockData() {
    // Simula dados do IBOVESPA dos últimos 30 dias
    final mockData = [
      {'close': 125000.0}, // Dia 1
      {'close': 126500.0}, // Dia 2
      {'close': 124800.0}, // Dia 3
      {'close': 127200.0}, // Dia 4
      {'close': 128100.0}, // Dia 5
      {'close': 126900.0}, // Dia 6
      {'close': 129500.0}, // Dia 7
      {'close': 128700.0}, // Dia 8
      {'close': 130200.0}, // Dia 9
      {'close': 129800.0}, // Dia 10
      {'close': 131500.0}, // Dia 11
      {'close': 130900.0}, // Dia 12
      {'close': 132800.0}, // Dia 13
      {'close': 131700.0}, // Dia 14
      {'close': 133900.0}, // Dia 15
      {'close': 132600.0}, // Dia 16
      {'close': 134500.0}, // Dia 17
      {'close': 133800.0}, // Dia 18
      {'close': 135200.0}, // Dia 19
      {'close': 134700.0}, // Dia 20
      {'close': 136100.0}, // Dia 21
      {'close': 135500.0}, // Dia 22
      {'close': 137300.0}, // Dia 23
      {'close': 136800.0}, // Dia 24
      {'close': 138200.0}, // Dia 25
      {'close': 137600.0}, // Dia 26
      {'close': 139100.0}, // Dia 27
      {'close': 138500.0}, // Dia 28
      {'close': 139800.0}, // Dia 29
      {'close': 139200.0}, // Dia 30
    ];

    List<FlSpot> pontos = [];
    for (int i = 0; i < mockData.length; i++) {
      final preco = mockData[i]['close'];
      if (preco != null) {
        pontos.add(FlSpot(i.toDouble(), preco));
      }
    }

    setState(() {
      _cachedData = pontos;
      _isLoading = false;
      _error = 'Usando dados simulados (API indisponível)';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _cachedData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erro: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando gráfico do IBOVESPA...'),
          ],
        ),
      );
    }

    if (_cachedData == null || _cachedData!.isEmpty) {
      return const Center(
        child: Text('Nenhum dado disponível'),
      );
    }

    return Column(
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _cachedData!,
                  isCurved: true,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  color: _error != null ? Colors.orange : Colors.blue, // Cor diferente se for mock
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}