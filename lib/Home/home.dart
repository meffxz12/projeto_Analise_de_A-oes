import 'package:flutter/material.dart';
import 'package:meu_app/Home/pesquisar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Pesquisar(onChanged: (value) {}, backgroundColor: Colors.white),

      body: Column(),
    );
  }
}
