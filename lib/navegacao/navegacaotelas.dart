import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/telas/home/hometela.dart';
import 'package:meu_apli/telas/home/ensino.dart';
import 'package:meu_apli/telas/home/carteirasimulada.dart';
import 'package:meu_apli/telas/home/favoritos.dart';

class MainNavegacao extends StatefulWidget {
  const MainNavegacao({super.key});

  @override
  State<MainNavegacao> createState() => _MainNavegacaoState();
}

class _MainNavegacaoState extends State<MainNavegacao> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    EnsinoScreen(),
    CarteiraScreen(),
    FavoritosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A5AE0),
              );
            }
            return TextStyle(fontSize: 12, color: Colors.grey[500]);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF6A5AE0).withOpacity(0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6A5AE0)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded, color: Color(0xFF6A5AE0)),
              label: 'Ensino',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6A5AE0)),
              label: 'Carteira',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite_rounded, color: Color(0xFF6A5AE0)),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}