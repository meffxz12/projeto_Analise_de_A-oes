import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

// ─── Tela de Segurança ──────────────────────────────────────────────────────
// NOTA: esta tela chama `ApiService.alterarSenha(senhaAtual, novaSenha)`.
// Se esse método ainda não existir no seu ApiService, adicione algo como:
//
// static Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/usuario/alterar-senha'),
//     headers: await _headersComToken(),
//     body: jsonEncode({
//       'senha_atual': senhaAtual,
//       'nova_senha': novaSenha,
//     }),
//   );
//   if (response.statusCode != 200) {
//     final erro = jsonDecode(response.body)['message'] ?? 'Erro ao alterar senha';
//     throw Exception(erro);
//   }
// }

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({super.key});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _ocultarSenhaAtual = true;
  bool _ocultarNovaSenha = true;
  bool _ocultarConfirmarSenha = true;
  bool _salvando = false;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarNovaSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await ApiService.alterarSenha(
        _senhaAtualController.text,
        _novaSenhaController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
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
                  'Segurança',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trocar senha',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _campoSenha(
                      controller: _senhaAtualController,
                      label: 'Senha atual',
                      ocultar: _ocultarSenhaAtual,
                      onToggle: () => setState(() => _ocultarSenhaAtual = !_ocultarSenhaAtual),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe sua senha atual';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _campoSenha(
                      controller: _novaSenhaController,
                      label: 'Nova senha',
                      ocultar: _ocultarNovaSenha,
                      onToggle: () => setState(() => _ocultarNovaSenha = !_ocultarNovaSenha),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a nova senha';
                        if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _campoSenha(
                      controller: _confirmarSenhaController,
                      label: 'Confirmar nova senha',
                      ocultar: _ocultarConfirmarSenha,
                      onToggle: () => setState(() => _ocultarConfirmarSenha = !_ocultarConfirmarSenha),
                      validator: (v) {
                        if (v != _novaSenhaController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A5AE0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _salvando ? null : _salvarNovaSenha,
                        child: _salvando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Salvar nova senha',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoSenha({
    required TextEditingController controller,
    required String label,
    required bool ocultar,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: ocultar,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }
}