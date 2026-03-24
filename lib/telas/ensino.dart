import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/telas/hometela.dart';
import 'package:meu_apli/telas/favoritos.dart';
import 'package:meu_apli/telas/carteirasimulada.dart';


class Ensino extends StatefulWidget {
  const Ensino({super.key});

  @override
  State<Ensino> createState() => _EnsinoState();
}

class _EnsinoState extends State<Ensino> {

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
                  Icon(Icons.school, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Ensino",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
                  ),
                  const SizedBox(width: 20),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),

            ),

          ],

        ),

      ),
           
    );
  
  }  
  
}