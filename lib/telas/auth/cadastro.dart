
import 'package:flutter/material.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/componentes/text_form_global.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/telas/auth/login.dart';

const _baseUrl = 'https://lanuginose-unsyllogistically-dianna.ngrok-free.dev'; // Android emulator → localhost

String _formatarNome(String nome) {
  return nome
      .split(' ')
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join(' ');
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmaSenha = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmaSenha.dispose();
    super.dispose();
  }

Future<void> _cadastrar() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    await ApiService.criarConta(
      _nome.text.trim(),
      _email.text.trim(),
      _senha.text.trim(),
    );

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8E7CFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Criar conta',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      TextFormGlobal(
                        controller: _nome,
                        text: 'Nome completo',
                        obscure: false,
                        textInputType: TextInputType.name,
                        prefixicon: Icons.person,
                        onChanged: (v) {
                          final fmt = _formatarNome(v);
                          _nome.value = TextEditingValue(
                            text: fmt,
                            selection: TextSelection.collapsed(offset: fmt.length),
                          );
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu nome completo';
                          if (v.trim().split(' ').length < 2) return 'Digite nome e sobrenome';
                          if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(v)) return 'Apenas letras';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormGlobal(
                        controller: _email,
                        text: 'Email institucional',
                        obscure: false,
                        textInputType: TextInputType.emailAddress,
                        prefixicon: Icons.email,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu email';
                          if (!v.endsWith('@aluno.unb.br')) return 'Use email institucional';
        
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormGlobal(
                        controller: _senha,
                        text: 'Senha',
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe sua senha';
                          if (v.length < 6) {
                            return 'Mín. 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormGlobal(
                        controller: _confirmaSenha,
                        text: 'Confirmar senha',
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme sua senha';
                          if (v != _senha.text) return 'Senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      _loading
                          ? const CircularProgressIndicator(color: Color(0xFF6A5AE0))
                          : ButtonGlobal(
                              text: 'Cadastrar',
                              color: const Color(0xFF6A5AE0),
                              colortext: Colors.white,
                              icons: Icons.person_add,
                              onTap: _cadastrar,
                            ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Já tem conta? '),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Color(0xFF6A5AE0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}