import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

// ─── Tela de Editar Perfil ──────────────────────────────────────────────────
// NOTA: esta tela chama `ApiService.atualizarPerfil(nome, email)`.
// Se esse método ainda não existir no seu ApiService, adicione algo como:
//
// static Future<void> atualizarPerfil(String nome, String email) async {
//   final url = Uri.parse('$baseUrl/usuario/me');
//   final response = await _enviarRequisicao(
//     'PUT',
//     url,
//     body: {
//       'nome': nome,
//       'email_institucional': email,
//     },
//     auth: true,
//   );
//   if (response.statusCode != 200) {
//     try {
//       final data = jsonDecode(response.body);
//       throw Exception(data['detail'] ?? 'Erro ao atualizar perfil');
//     } catch (_) {
//       throw Exception('Erro ao atualizar perfil: ${response.statusCode}');
//     }
//   }
// }
//
// Ajuste o endpoint e os nomes dos campos ('nome' / 'email_institucional')
// conforme o que sua API realmente espera.

class EditarNomeScreen extends StatefulWidget {
  final String nomeAtual;

  const EditarNomeScreen({
    super.key,
    required this.nomeAtual,
  
  });

  @override
  State<EditarNomeScreen> createState() => _EditarNomeScreenState();
}

class _EditarNomeScreenState extends State<EditarNomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
 

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeAtual);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  bool get _houveAlteracao =>
      _nomeController.text.trim() != widget.nomeAtual;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_houveAlteracao) {
      Navigator.pop(context);
      return;
    }

    setState(() => _salvando = true);
    try {
      await ApiService.atualizarPerfil(
        _nomeController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      // Retorna true para a tela anterior saber que precisa recarregar o perfil.
      Navigator.pop(context, true);
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seus dados',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe seu nome';
                        }
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
                        onPressed: _salvando ? null : _salvar,
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
                                'Salvar alterações',
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
}