import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/coresglobais.dart';
import 'package:meu_apli/telas/hometela.dart';
import 'package:meu_apli/telas/favoritos.dart';
import 'package:meu_apli/telas/ensino.dart';
import 'package:meu_apli/telas/carteirasimulada.dart';

class Carteirasimulada extends StatefulWidget {
  const Carteirasimulada({super.key});

  @override
  State<Carteirasimulada> createState() => _CarteirasimuladaState();
}

class _CarteirasimuladaState extends State<Carteirasimulada> {

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
                  Icon(Icons.account_balance_wallet, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Carteira Simulada",
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