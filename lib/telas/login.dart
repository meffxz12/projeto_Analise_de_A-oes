import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import '../text.form.global.dart';
import 'cadastro.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  final TextEditingController email = TextEditingController();
  final TextEditingController senha = TextEditingController();

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
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // EMAIL
                    TextFormGlobal(
                      controller: email,
                      text: "Email",
                      obscure: false,
                      textInputType: TextInputType.emailAddress,
                      prefixicon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe seu email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // SENHA
                    TextFormGlobal(
                      controller: senha,
                      text: "Senha",
                      obscure: true,
                      textInputType: TextInputType.visiblePassword,
                      prefixicon: Icons.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // BOTÃO LOGIN
                    ButtonGlobal(
  text: "Entrar",
  color: const Color(0xFF6A5AE0),
  colortext: Colors.white,
  icons: Icons.login,
  onTap: () async {
    if (email.text.isNotEmpty && senha.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: senha.text.trim(),
        );

        // ✅ LOGIN DEU CERTO → navega
        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Login(), // depois tu troca pela Home
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );

      } on FirebaseAuthException catch (e) {
        String mensagem = '';

        if (e.code == 'user-not-found') {
          mensagem = 'Usuário não encontrado';
        } else if (e.code == 'wrong-password') {
          mensagem = 'Senha incorreta';
        } else if (e.code == 'invalid-email') {
          mensagem = 'Email inválido';
        } else {
          mensagem = 'Erro: ${e.message}';
        }

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha')),
      );
    }
  },
),
                    const SizedBox(height: 15),

                    // ESQUECEU SENHA
                    TextButton(
                      onPressed: () {
                        // Pode navegar pra tela de reset de senha
                        print('Esqueceu senha');
                      },
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CADASTRO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Não tem conta? "),
                        GestureDetector(
                          onTap: () {
                            // Navegação substituindo a tela de login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Cadastro()),
                            );
                          },
                          child: const Text(
                            "Criar conta",
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