import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/login/login.dart';
import 'package:meu_apli/telaincial/pages/Pagina1.dart';
import 'package:meu_apli/telaincial/pages/Pagina2.dart';
import 'package:meu_apli/telaincial/pages/pagina3.dart';
import 'package:meu_apli/telaincial/pages/pagina4.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Bemvindo extends StatefulWidget {
  Bemvindo({Key? key}) : super(key: key);
  @override
  _BemvindoState createState() => _BemvindoState();
}

class _BemvindoState extends State<Bemvindo> {

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
        Pagina1(),
        Pagina2(),
        Pagina3(),
        Pagina4()
        ],
      ),

     
      Container( 
        alignment: Alignment(0, 0.55),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SmoothPageIndicator(controller: _Controlar, count: 3),
         ButtonGlobal(text: 'começar',
          onTap: (){
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => Login())
              );
          },
           color: Colors.white,
           colortext: const Color.fromARGB(255, 110, 80, 41),
         )
        ],
      ),
      )
     ]
      
      

    
     
     
          ),
        );
     
}
}