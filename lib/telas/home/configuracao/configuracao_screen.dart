import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/telas/home/configuracao/editar_perfil_screen.dart';

// ─── Tela de Configurações ──────────────────────────────────────────────────
// Itens simples de configuração geral do app. "Tema escuro" aqui é só um
// toggle de estado local (sem persistência) — se você já tiver um sistema de
// temas no app (ex: Provider/Riverpod), troque o Switch para usar esse estado.
//
// nomeAtual/emailAtual: recebidos de quem navega para essa tela (ex: a
// PerfilScreen, que já tem esses dados carregados). São repassados para a
// EditarPerfilScreen para preencher o formulário.

class ConfiguracoesScreen extends StatefulWidget {
  final String nomeAtual;
  final String emailAtual;

  const ConfiguracoesScreen({
    super.key,
    required this.nomeAtual,
    required this.emailAtual,
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: CoresGlobais.backgrounder),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Configurações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _itemConfig(
            Icons.person_outline,
            'Editar perfil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditarPerfilScreen(),
              ),
            )
          ),
          _itemConfig(
            Icons.description_outlined,
            'Termos de uso e privacidade',
            onTap: () => _mostrarEmBreve(context),
          ),
          _itemConfig(
            Icons.info_outline,
            'Sobre o app',
            onTap: () => _mostrarSobre(context),
          ),
        ],
      ),
    );
  }

  void _mostrarEmBreve(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve')),
    );
  }

  void _mostrarSobre(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sobre o app'),
        content: const Text('Versão 1.0.0'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _itemConfig(
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _itemToggle({
    required IconData icon,
    required String text,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: valor,
            activeColor: const Color(0xFF6A5AE0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
