import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Bemvindo extends StatefulWidget {
  Bemvindo({Key? key}) : super(key: key);
  @override
  _BemvindoState createState() => _BemvindoState();
}

class _BemvindoState extends State<Bemvindo> {
  

  List<String> textos = [
    "Analise suas ações com facilidade",
    "Aprenda sobre o mercado financeiro",
    "Crie sua conta e comece agora",
  ];
  final PageController _Controlar = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
    body: Stack(
     children: [ 
      PageView(
        controller: _Controlar,
        children: [
         Container(
        width: 70,
    height: 190,
    decoration: BoxDecoration(
       color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      )
         ),
       Container(
        color: Colors.green
      ),
       Container(
        color: Colors.blue
      ),
        ],
      ),

     
      Container( 
        alignment: Alignment(0, 0.5),
      child: SmoothPageIndicator(controller: _Controlar, count: 3),
      )
     ]
      
      

    
     
     
          ),
        );
     
}
}