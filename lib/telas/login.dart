import 'package:flutter/material.dart';
import 'package:meu_apli/componentes/button.dart';
import '../text.form.global.dart';
import 'package:meu_apli/telas/cadastro.dart';

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

                    // BOTÃO
                    ButtonGlobal(
                      color: const Color(0xFF6A5AE0),
                      text: 'Entrar',
                      colortext: Colors.white,
                      onTap: () {
                        print('login');
                      },
                    ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Não tem conta? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Cadastro()),
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