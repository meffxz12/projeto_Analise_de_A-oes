import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/componentes/text_form_global.dart';
import 'package:meu_apli/navegacao/navegacaotelas.dart';
import 'package:meu_apli/telas/auth/cadastro.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_email.text.isEmpty || _senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _senha.text.trim(),
      );

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        _fadeRoute(const MainNavegacao()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado',
        'wrong-password' => 'Senha incorreta',
        'invalid-email' => 'Email inválido',
        _ => 'Erro: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
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
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Informe seu email' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _senha,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v == null || v.isEmpty ? 'Informe sua senha' : null,
                    ),
                    const SizedBox(height: 25),
                    ButtonGlobal(
                      text: 'Entrar',
                      color: const Color(0xFF6A5AE0),
                      colortext: Colors.white,
                      icons: Icons.login,
                      onTap: () => _login(context),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {}, // TODO: reset de senha
                      child: const Text('Esqueceu a senha?', style: TextStyle(color: Colors.grey)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta? '),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => CadastroScreen()),
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