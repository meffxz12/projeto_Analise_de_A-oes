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

                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      // Nome
                      TextFormGlobal(
                        controller: nome,
                        text: "Nome Completo",
                        obscure: false,
                        textInputType: TextInputType.name,
                        prefixicon: Icons.person,
                        onChanged:(value){
                          nome.text = formatarNome(value);
                          nome.selection = TextSelection.fromPosition(TextPosition(offset: nome.text.length));
                        } ,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome completo';
                          } 
                          if (value.trim().split(" ").length < 2) {
                            return 'Digite nome e sobrenome';
                          }
                           if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'O nome deve conter apenas letras e espaços';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 15),

                      // email
                      TextFormGlobal(
                        controller: email,
                        text: "Email",
                        obscure: false,
                        textInputType: TextInputType.emailAddress,
                        prefixicon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Por favor, insira um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      //senha
                      TextFormGlobal(
                        controller: senha,
                        text: "Senha",
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          if (value.length < 8 || !RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'A senha deve conter pelo menos 8 caracteres, incluindo uma letra maiúscula e um número';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      //confirmar senha
                      TextFormGlobal(
                        controller: confirmasenha,
                        text: "Confirmar Senha",
                        obscure: true,
                        textInputType: TextInputType.visiblePassword,
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua senha';
                          }
                          if (value != senha.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      ButtonGlobal(
                        text: "Cadastrar",
                        color: Color.fromARGB(255, 34, 66, 245),
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            try{ 
                             await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: email.text, password: senha.text);
                                       logger.i("Conta criada com sucesso");
                                if (!mounted) return;
                                 ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Conta criada com sucesso')), );
                               
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
                                  SnackBar(content: Text('Erro ao criar conta: $error')), );
                               
                              
                                
                              }
                            }
                            },
                            colortext: Colors.white,
                            ),
                        
                        
                    
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
