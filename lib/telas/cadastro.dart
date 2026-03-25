import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import 'package:meu_apli/telas/login.dart';
import '../componentes/text.form.global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

String formatarNome(String nome) {
  return nome
      .split(" ")
      .map((palavra) =>
          palavra[0].toUpperCase() + palavra.substring(1).toLowerCase())
      .join(" ");
}

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final TextEditingController confirmasenha = TextEditingController();

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    confirmasenha.dispose();
    super.dispose();
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
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Criar conta",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // nome completo do usuario
                      TextFormGlobal(
                        controller: nome,
                        text: "Nome completo",
                        obscure: false,
                        textInputType: TextInputType.name,
                        prefixicon: Icons.person,
                        onChanged: (value) {
                          final formatado = formatarNome(value);
                          nome.value = TextEditingValue(
                            text: formatado,
                            selection: TextSelection.collapsed(
                                offset: formatado.length),
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe seu nome completo';
                          }
                          if (value.trim().split(" ").length < 2) {
                            return 'Digite nome e sobrenome';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Apenas letras e espaços';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // o email do usuario
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
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // senha ne
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
                          if (value.length < 8 ||
                              !RegExp(r'[A-Z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Mín. 8 caracteres, 1 maiúscula e 1 número';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // confirmar senha
                      TextFormGlobal(
                        controller: confirmasenha,
                        text: "Confirmar senha",
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirme sua senha';
                          }
                          if (value != senha.text) {
                            return 'Senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // botao
                      ButtonGlobal(
                        text: "Cadastrar",
                        color: const Color(0xFF6A5AE0),
                        colortext: Colors.white,
                        icons: Icons.person_add,
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                           try {
                                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: email.text.trim(),
                                        password: senha.text.trim(),
                                      );

                                    } on FirebaseAuthException catch (e) {
                                      String mensagem = '';

                                      if (e.code == 'email-already-in-use') {
                                        mensagem = 'Esse email já está em uso';
                                      } else if (e.code == 'weak-password') {
                                        mensagem = 'Senha muito fraca';
                                      } else {
                                        mensagem = 'Erro: ${e.message}';
                                      }

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(mensagem)),
                                      );
                                    }

                           
                              Navigator.pushAndRemoveUntil(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => Login(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        final tween = Tween(
                                          begin: const Offset(0.0, 0.1), // vem levemente de baixo
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
                          }
                        },
                         ),
                      
                        
                                  

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Já tem conta? "),
                          GestureDetector(
                            onTap: () {
                            
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: const Text(
                              "Entrar",
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