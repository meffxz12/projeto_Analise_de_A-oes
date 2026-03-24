import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/telas/carteirasimulada.dart';
import 'package:meu_apli/telas/ensino.dart';
import 'package:meu_apli/telas/favoritos.dart';
import 'package:meu_apli/telas/hometela.dart';

class Navegacaotelas extends StatefulWidget {
  const Navegacaotelas({super.key});

  @override
  State<Navegacaotelas> createState() => _NavegacaotelasState();
}

class _NavegacaotelasState extends State<Navegacaotelas> {
  int currentIndex = 0;


  static Function(int)? changePage;

  final List<Widget> pages = [
    const HomePage(),
    const Ensino(),
    const Carteirasimulada(),
    const Favoritos(),
  ];

  @override
  void initState() {
    super.initState();

    changePage = (index) {
      setState(() {
        currentIndex = index;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: CoresGlobais.botao,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Ensino'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Carteira'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }
}