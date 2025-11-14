import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:meu_app/login/button.dart';
import 'package:meu_app/login/login.dart';
import '../text.form.global.dart';
=======
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../text.form.global.dart';
import '../login/login.dart';
import '../login/button.dart';
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)

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

<<<<<<< HEAD
=======
  Future<void> criarConta() async {
    final url = Uri.parse(
      'https://donnette-unaided-noncryptically.ngrok-free.dev/auth/criar_conta',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome.text,
        "email_institucional": email.text,
        "senha": senha.text,
        "ativo": true,
        "admin": false,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Cadastro bem-sucedido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      // Erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar: ${response.body}")),
      );
    }
  }

>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            color: Color.fromARGB(255, 34, 66, 245),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                const Text(
                  'Cadastro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Cadastre-se e comece a usar!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 50,
                ),
                child: Form(
                  key: formKey,
<<<<<<< HEAD

                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      // Nome
=======
                  child: Column(
                    children: [
                      SizedBox(height: 15),
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      TextFormGlobal(
                        controller: nome,
                        text: "Nome Completo",
                        obscure: false,
                        textInputType: TextInputType.name,
                        prefixicon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira Nome Completo';
                          }
                          return null;
                        },
                      ),
<<<<<<< HEAD

                      SizedBox(height: 15),

                      // email
=======
                      SizedBox(height: 15),
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      TextFormGlobal(
                        controller: email,
                        text: "Email",
                        obscure: false,
                        textInputType: TextInputType.emailAddress,
                        prefixicon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira Email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
<<<<<<< HEAD
                      //senha
=======
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      TextFormGlobal(
                        controller: senha,
                        text: "Senha",
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira Senha';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
<<<<<<< HEAD
                      //confirmar senha
=======
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      TextFormGlobal(
                        controller: confirmasenha,
                        text: "Confirmar Senha",
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme Senha';
                          }
                          if (value != senha.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
<<<<<<< HEAD
                      //botão de entrar
=======
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      ButtonGlobal(
                        color: Color.fromARGB(255, 34, 66, 245),
                        text: 'Cadastrar',
                        onTap: () {
                          if (formKey.currentState!.validate()) {
<<<<<<< HEAD
                            print("Cadastro realizado com sucesso");
=======
                            criarConta();
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                          }
                        },
                      ),
                      SizedBox(height: 20),
<<<<<<< HEAD
                      // botão de login
=======
>>>>>>> 42c33b4 (+alteracoes e add da tela incial e home)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já possui uma conta?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 66, 245),
                                fontSize: 14,
                                fontFamily: 'Roboto',
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
        ],
      ),
    );
  }
}
