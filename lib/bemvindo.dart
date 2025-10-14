import 'package:flutter/material.dart';
import 'package:meu_app/login/login.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class Telainicial extends StatefulWidget {
  Telainicial({Key? key}) : super(key: key);
  @override
  _TelainicialState createState() => _TelainicialState();
}

class _TelainicialState extends State<Telainicial> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> textos = [
    "Analise suas ações com facilidade",
    "Aprenda sobre o mercado financeiro",
    "Crie sua conta e comece agora",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: textos.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            textos[index],
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(textos.length, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                width: _currentPage == index ? 9 : 8,
                                height: _currentPage == index ? 9 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),

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
      ),
    );
  }
}
