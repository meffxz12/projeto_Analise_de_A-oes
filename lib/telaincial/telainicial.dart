import 'package:flutter/material.dart';
import 'package:meu_app/login/login.dart';
import 'package:meu_app/telaincial/pages/pagina1.dart';
import 'package:meu_app/telaincial/pages/pagina2.dart';
import 'package:meu_app/telaincial/pages/pagina3.dart';
import 'package:meu_app/telaincial/pages/pagina4.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Telainicial extends StatefulWidget {
  Telainicial({Key? key}) : super(key: key);
  @override
  _TelainicialState createState() => _TelainicialState();
}

class _TelainicialState extends State<Telainicial> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              'Bem-vindo!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 450,
            child: PageView(
              controller: _pageController,
              children: const [Pagina1(), Pagina2(), Pagina3(), Pagina4()],
            ),
          ),

          SizedBox(height: 20),

          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 4,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.white,
                dotColor: Colors.white54,
                dotHeight: 12,
                dotWidth: 12,
                expansionFactor: 3,
                spacing: 6,
              ),
            ),
          ),

          SizedBox(height: 80),

          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navegar para a tela de login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 34, 66, 245),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Começar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
