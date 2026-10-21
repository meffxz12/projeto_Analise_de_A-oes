import 'package:flutter/material.dart';

import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/telas/auth/cadastro.dart';
import 'package:meu_apli/componentes/text_form_global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _senhaController =
      TextEditingController();

  bool _carregando = false;

  static const Color roxo = Color(0xFF6A5AE0);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }

    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe sua senha.';
    }

    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _carregando = true;
    });

    try {
      final resultado = await ApiService.login(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      if (resultado.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavegacao(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível entrar. Verifique suas credenciais '
              'e a confirmação do e-mail.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
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

  Future<void> _recuperarSenha() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Digite seu e-mail no campo acima para recuperar a senha.',
          ),
        ),
      );
      return;
    }

    final emailValido = _validarEmail(email);

    if (emailValido != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailValido)),
      );
      return;
    }

    try {
      await ApiService.recuperarSenha(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se o e-mail estiver cadastrado, você receberá as '
            'instruções para redefinir sua senha.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível solicitar a recuperação: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: roxo.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: roxo,
                          size: 52,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'InvestServ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: roxo,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Acesse sua conta e acompanhe seus investimentos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'E-mail institucional',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _emailController,
                      hintText: 'Digite seu e-mail',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: roxo,
                      ),
                      validator: _validarEmail,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Senha',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormGlobal(
                      controller: _senhaController,
                      hintText: 'Digite sua senha',
                      obscureText: true,
                      canToggleVisibility: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: roxo,
                      ),
                      validator: _validarSenha,
                      onFieldSubmitted: (_) => _login(),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _carregando ? null : _recuperarSenha,
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(color: roxo),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _login,
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
                                'Entrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Ainda não tem uma conta?',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        TextButton(
                          onPressed: _carregando
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CadastroScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: roxo,
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
    );
  }
}