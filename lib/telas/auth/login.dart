import 'package:flutter/material.dart';

import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/telas/auth/cadastro.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _senha.text.isEmpty) {
      setState(() => _erro = 'Preencha email e senha');
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      await ApiService.login(
        _email.text.trim(),
        _senha.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        _fadeRoute(const MainNavegacao()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ==========================================================
  // RECUPERAR SENHA
  // ==========================================================

  Future<void> _mostrarRecuperacaoSenha() async {
    final controller = TextEditingController(text: _email.text.trim());
    final formKey = GlobalKey<FormState>();
    bool enviando = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Recuperar senha'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Digite seu e-mail institucional. '
                      'Enviaremos um link para você criar uma nova senha.',
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail institucional',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }

                        if (!value.trim().toLowerCase().endsWith('@ifma.edu.br')) {
                          return 'Use seu e-mail institucional';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: enviando ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: enviando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => enviando = true);

                          try {
                            await ApiService.recuperarSenha(controller.text.trim());

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'E-mail de recuperação enviado! '
                                  'Verifique sua caixa de entrada.',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => enviando = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                        },
                  child: enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // ==========================================================
  // ANIMAÇÃO
  // ==========================================================

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
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
                child: Column(
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),

                    // E-MAIL
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email institucional',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // SENHA
                    TextFormField(
                      controller: _senha,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                    ),

                    // ERRO INLINE
                    if (_erro != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _erro!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 25),

                    // BOTÃO LOGIN
                    _loading
                        ? const CircularProgressIndicator(color: Color(0xFF6A5AE0))
                        : ButtonGlobal(
                            text: 'Entrar',
                            color: const Color(0xFF6A5AE0),
                            colortext: Colors.white,
                            icons: Icons.login,
                            onTap: _login,
                          ),

                    // ESQUECEU A SENHA
                    TextButton(
                      onPressed: _mostrarRecuperacaoSenha,
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    // CADASTRO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta? '),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const CadastroScreen()),
                          ),
                          child: const Text(
                            'Criar conta',
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
    );
  }
}