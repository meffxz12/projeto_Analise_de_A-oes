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
  Cadastro({Key? key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final TextEditingController confirmasenha = TextEditingController();

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

                      // NOME
                      TextFormGlobal(
                        controller: nome,
                        text: "Nome completo",
                        obscure: false,
                        textInputType: TextInputType.name,
                        prefixicon: Icons.person,
                        onChanged: (value) {
                          nome.text = formatarNome(value);
                          nome.selection = TextSelection.fromPosition(
                            TextPosition(offset: nome.text.length),
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
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Email inválido';
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
                          if (value.length < 8 ||
                              !RegExp(r'[A-Z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Mín. 8 caracteres, 1 maiúscula e 1 número';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // CONFIRMAR SENHA
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

                      // BOTÃO
                      ButtonGlobal(
                        text: "Cadastrar",
                        color: const Color(0xFF6A5AE0),
                        colortext: Colors.white,
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email.text,
                                password: senha.text,
                              );

                              logger.i("Conta criada com sucesso");

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Conta criada com sucesso')),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            } catch (error) {
                              logger.w("Erro ao criar conta: $error");

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Erro ao criar conta: $error')),
                              );
                            }
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
                              Navigator.push(
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