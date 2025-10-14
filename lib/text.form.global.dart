import 'package:flutter/material.dart';

class TextFormGlobal extends StatelessWidget {
  TextFormGlobal({
    Key? key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscure,
    required this.prefixicon,
    required this.validator,
  }) : super(key: key);

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final IconData prefixicon;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: text,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(prefixicon),
          contentPadding: const EdgeInsets.only(top: 14),
          hintStyle: const TextStyle(height: 1),
        ),
        validator: validator,
      ),
    );
  }
}
