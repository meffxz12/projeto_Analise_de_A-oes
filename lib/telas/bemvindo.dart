import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:meu_apli/telas/login.dart';
import 'package:meu_apli/componentes/coresglobais.dart';

class BemVindo extends StatefulWidget {
  const BemVindo({super.key});

  @override
  State<BemVindo> createState() => _BemVindoState();
}

class _BemVindoState extends State<BemVindo> {

  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
           gradient: LinearGradient(
                  colors: CoresGlobais.backgrounder,
                ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

           
              PageView(
                controller: _controller,
                children: [
                  buildPage(
                    imagePath: "assets/images/undraw_savings_d97f.png",
                    title: "Aprenda do zero",
                    subtitle: "Entenda o mercado com conteúdos simples e diretos.",
                  ),
                  buildPage(
                    imagePath: "assets/images/undraw_visual-data_1eya.png",
                    title: "Evolua no mercado",
                    subtitle: "Acompanhe seu progresso e ganhe mais confiança ao investir.",
                  ),
                  buildPage(
                    imagePath: "assets/images/undraw_wallet_diag.png",
                    title: "Simule investimentos",
                    subtitle: "Teste estratégias e acompanhe ativos sem usar dinheiro real.",
                  ),
                ],
              ),

              // INDICADOR + BOTÃO
             Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // 🔹 PONTINHOS
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: const WormEffect(
                        dotColor: Colors.white54,
                        activeDotColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 60),
                    // 🔹 BOTÃO
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                      child: const Text(
                        "Começar",
                        style: TextStyle(
                          color: Color(0xFF6A5AE0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildPage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Image.asset(
                imagePath,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}