import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/home/configuracao/alterar_senha_screen.dart';
import 'package:meu_apli/telas/home/configuracao/editar_nome_screen.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  Map<String, dynamic>? _perfil;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.buscarPerfil();

      if (!mounted) return;

      setState(() {
        _perfil = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Erro ao carregar perfil: '
            '${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirEditarNome() async {
    if (_perfil == null) return;

    final nomeAtual =
        _perfil!['name'] ??
        _perfil!['nome'] ??
        '';

    final atualizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarNomeScreen(
          nomeAtual: nomeAtual.toString(),
        ),
      ),
    );

    if (atualizou == true) {
      await _carregarPerfil();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              10,
              40,
              20,
              30,
            ),
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Editar perfil',
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

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _carregarPerfil,
                    child: const Text(
                      'Tentar novamente',
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _itemConfig(
              Icons.person_outline,
              'Alterar nome',
              onTap: _abrirEditarNome,
            ),

            _itemConfig(
              Icons.lock_outline,
              'Alterar senha',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AlterarSenhaScreen(),
                  ),
                );
              },
            ),
          ],
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
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
            ),
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
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}