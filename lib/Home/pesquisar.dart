import 'package:flutter/material.dart';
import 'package:meu_app/home/home.dart';

class Pesquisar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onChanged;
  final Color backgroundColor;

  const Pesquisar({
    super.key,
    required this.onChanged,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: (const Color.fromARGB(255, 34, 66, 245)),
      shadowColor: Colors.black,
      elevation: 4.0,
      title: TextField(
        onChanged: onChanged,
        onTap: () {},
        onTapUpOutside: (_) {},
        decoration: InputDecoration(
          hintText: 'Pesquisar...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),

          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
