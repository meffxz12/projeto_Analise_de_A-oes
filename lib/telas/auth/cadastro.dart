import 'package:flutter/material.dart';

import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/componentes/text_form_global.dart';
import 'package:meu_apli/telas/auth/verificacao_email.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _senhaController =
      TextEditingController();

  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _carregando = false;

  static const Color roxo = Color(0xFF6A5AE0);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    final nome = valor?.trim() ?? '';

    if (nome.isEmpty) {
      return 'Informe seu nome.';
    }

    if (nome.length < 3) {
      return 'Digite seu nome completo.';
    }

    return null;
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim().toLowerCase() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail institucional.';
    }

    final formatoValido =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!formatoValido) {
      return 'Informe um e-mail válido.';
    }

    final dominioPermitido =
        email.endsWith('@ifma.edu.br') ||
        email.endsWith('@acad.ifma.edu.br');

    if (!dominioPermitido) {
      return 'Utilize seu e-mail institucional do IFMA.';
    }

    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Crie uma senha.';
    }

    if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  String? _validarConfirmacao(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme sua senha.';
    }

    if (valor != _senhaController.text) {
      return 'As senhas não coincidem.';
    }

    return null;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _carregando = true;
    });

    try {
      await ApiService.criarConta(
        _nomeController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _senhaController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro enviado. Confira as instruções de verificação '
            'do seu e-mail.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificacaoEmailScreen(
            nome: _nomeController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível concluir o cadastro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: roxo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Cadastre-se no InvestServ',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: roxo,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Crie sua conta para acessar as funcionalidades '
                      'do aplicativo.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Nome completo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _nomeController,
                      hintText: 'Digite seu nome completo',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: roxo,
                      ),
                      validator: _validarNome,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'E-mail institucional',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _emailController,
                      hintText: 'seuemail@ifma.edu.br',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: roxo,
                      ),
                      validator: _validarEmail,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Senha',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _senhaController,
                      hintText: 'Crie uma senha',
                      obscureText: true,
                      canToggleVisibility: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: roxo,
                      ),
                      validator: _validarSenha,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Confirmar senha',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _confirmarSenhaController,
                      hintText: 'Digite a senha novamente',
                      obscureText: true,
                      canToggleVisibility: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        color: roxo,
                      ),
                      validator: _validarConfirmacao,
                      onFieldSubmitted: (_) => _cadastrar(),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roxo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Criar conta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _carregando
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Já tenho uma conta',
                        style: TextStyle(
                          color: roxo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}