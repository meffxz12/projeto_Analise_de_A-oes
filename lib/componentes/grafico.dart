import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/apiservice.dart';

class GraficoAcao extends StatefulWidget {
  const GraficoAcao({super.key});

  @override
  State<GraficoAcao> createState() => _GraficoAcaoState();
}

class _GraficoAcaoState extends State<GraficoAcao> {
  List<FlSpot>? _dados;
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final resposta = await ApiService.buscarGrafico("PETR4");

      List<FlSpot> pontos = [];

      for (int i = 0; i < resposta.length; i++) {
        final preco = resposta[i]['close'];

        if (preco != null) {
          pontos.add(FlSpot(i.toDouble(), preco.toDouble()));
        }
      }

      setState(() {
        _dados = pontos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(child: Text("Erro: $_erro"));
    }

    if (_dados == null || _dados!.isEmpty) {
      return const Center(child: Text("Sem dados"));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _dados!,
              isCurved: true,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}