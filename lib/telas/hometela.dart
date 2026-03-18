import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // TOPO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 34, 66, 245),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
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
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // INDICADORES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                IndicatorCard("IBOV", "158.104", "+0.60%"),
                IndicatorCard("IFIX", "3.612", "+0.58%"),
                IndicatorCard("SPX", "6.748", "+0.15%"),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: [
                    sectionTitle("Ações"),
                    stockList([
                      Stock("PETR4", "+1,75%", true),
                      Stock("ITUB4", "+0,17%", true),
                      Stock("BBDC4", "+0,56%", true),
                      Stock("LREN3", "+3,10%", true),
                      Stock("BHIA3", "-1,80%", false),
                    ]),

                    sectionTitle("Fundos"),
                    stockList([
                      Stock("BOVV11", "+0,74%", true),
                      Stock("HGLG11", "+0,32%", true),
                      Stock("XPML11", "+0,41%", true),
                      Stock("KNRI11", "+0,28%", true),
                      Stock("MXRF11", "+0,19%", true),
                    ]),

                    sectionTitle("Últimos vídeos"),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(child: videoCard("O que são investimentos?")),
                        const SizedBox(width: 10),
                        Expanded(child: videoCard("O que são ações?")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 34, 66, 245),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: ""),
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
          Text(stock.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // ✅ VIDEO CARD (AGORA DENTRO DA CLASSE)
  Widget videoCard(String title) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
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