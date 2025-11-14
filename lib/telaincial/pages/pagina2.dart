import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Pagina2 extends StatelessWidget {
  const Pagina2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(25),

              child: SizedBox(
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/undraw_online-learning_tgmv.svg',
                      height: 250,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      "Aprenda sobre o mercado financeiro e descubra como investir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Color.fromARGB(232, 38, 70, 252),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
