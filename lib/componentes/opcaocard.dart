import 'package:flutter/material.dart';

class OpcaoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const OpcaoCard({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 28),   
            const SizedBox(width: 12),                
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor, size: 18), // ">" à direita
          ],
        ),
      ),
    );
  }
}