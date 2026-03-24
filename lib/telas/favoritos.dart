import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/componentes/coresglobais.dart';


class Favoritos extends StatelessWidget {
  const Favoritos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
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

              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      
                         decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Favoritos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
            ),
             

            const SizedBox(height: 10),

            // Lista
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: const [
                  StockTile(
                    name: "Petrobras PN",
                    code: "PETR4",
                    price: "R\$ 34,89",
                    change: "+1,95%  +0,67",
                  ),
                  StockTile(
                    name: "Vale ON",
                    code: "VALE3",
                    price: "R\$ 66,72",
                    change: "+1,82%  +1,19",
                  ),
                  StockTile(
                    name: "BOVA11",
                    code: "BOVA11",
                    price: "R\$ 98,35",
                    change: "+1,29%  +1,25",
                  ),
                  StockTile(
                    name: "Itaú Unibanco PN",
                    code: "ITUB4",
                    price: "R\$ 29,97",
                    change: "+1,60%  +0,47",
                  ),
                  StockTile(
                    name: "Magazine Luiza ON",
                    code: "MGLU3",
                    price: "R\$ 10,45",
                    change: "+2,25%  +0,23",
                  ),
                ],
              ),
            )
          ]
        ),
      ),
          bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: CoresGlobais.botao,
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
}

class StockTile extends StatelessWidget {
  final String name;
  final String code;
  final String price;
  final String change;

  const StockTile({
    super.key,
    required this.name,
    required this.code,
    required this.price,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone fake
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(width: 12),

          // Nome + código
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                code,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),

          const Spacer(),

          // Preço + variação
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          const Icon(Icons.star, color: Colors.amber),
        ],
      ),
    );
  }
}
    

