import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/componentes/opcaocard.dart';
import 'package:meu_apli/componentes/videocard.dart';
import '../componentes/grafico.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Parte de cima
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: CoresGlobais.backgrounder,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),

                // Area de pesquisa
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Buscar ativos",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
             // grafico aqui
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Gráfico de desempenho",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 🔥 AQUI É O GRÁFICO REAL
                      const GraficoAcao(),
                    ],
                  ),
                ),

              // Ações e fundos aqui
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OpcaoCard(
                        text: "Fundos",
                        onTap: () {},
                        color: CoresGlobais.botao2,
                        textColor: Colors.white,
                        icon: Icons.pie_chart,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OpcaoCard(
                        text: "Ações",
                        onTap: () {},
                        color: CoresGlobais.botao2,
                        textColor: Colors.white,
                        icon: Icons.show_chart,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              // Vídeos
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Vídeos",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista dos vídeos
                    VideoCard(
                      title: "Como analisar ações",
                      videoId: "bkcMlHEtXsI",
                      duration: "17:10",
                    ),
                    const SizedBox(height: 10),
                    VideoCard(
                      title: "O que são fundos imobiliários?",
                      videoId: "vZ64S8dFpEM",
                      duration: "9:54",
                    ),
                    const SizedBox(height: 10),
                    VideoCard(
                      title: "Análise Técnica para Iniciantes",
                      videoId: "1tbjXu6oHqI",
                      duration: "10:08",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: CoresGlobais.botao,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
        ],
      ),
    );
  }

  // TITULO
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "$title  >",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 34, 66, 245),
          fontSize: 16,
        ),
      ),
    );
  }

  // LISTA
  Widget stockList(List<Stock> stocks) {
    return Column(
      children: stocks.map((stock) => stockCard(stock)).toList(),
    );
  }

  Widget stockCard(Stock stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stock.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: stock.isPositive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stock.value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

// INDICADOR (FORA DA CLASSE)
class IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;

  const IndicatorCard(this.title, this.value, this.change, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              change,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

// MODEL
class Stock {
  final String name;
  final String value;
  final bool isPositive;

  Stock(this.name, this.value, this.isPositive);
}