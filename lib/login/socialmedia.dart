import 'package:flutter/material.dart';

class Socialmedia extends StatelessWidget {
  const Socialmedia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            'Entrar com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }
}
