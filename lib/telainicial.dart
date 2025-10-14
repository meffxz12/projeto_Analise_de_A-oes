import 'package:flutter/material.dart';

class Telainicial extends StatefulWidget {
  const Telainicial({Key? key}) : super(key: key);

  @override
  TelainicialState createState() => TelainicialState();
}

class TelainicialState extends State<Telainicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Tela Inicial')));
  }
}
