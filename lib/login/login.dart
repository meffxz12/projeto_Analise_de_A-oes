import 'package:flutter/material.dart';
import 'package:meu_app/login/button.dart';
import '../text.form.global.dart';
import 'package:meu_app/cadastro.dart';
class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final TextEditingController matricula = TextEditingController();
  final TextEditingController senha = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 66, 245),
      body: Column(
        children: [
          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            color: Color.fromARGB(255, 34, 66, 245),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.white),
                
                ),
                SizedBox(height: 7),
                Text(
                  'Bem-vindo de volta!',
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    // Email
                    TextFormGlobal(controller: matricula, text: "Matrícula", obscure: false, textInputType: TextInputType.emailAddress, prefixicon: Icons.person, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira Matrícula';
                      }
                      return null;
                    },),
                    SizedBox(height: 15),
                    // senha
                    TextFormGlobal(controller: senha, text: "Senha", obscure: true, textInputType: TextInputType.visiblePassword, prefixicon: Icons.lock, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira Senha';
                      }
                      return null;
                    },),
                   SizedBox(height: 15),
                   //botão entrar
                   ButtonGlobal(color: Color.fromARGB(255, 34, 66, 245), 
                   text: 'Entrar',
                   onTap: () {
                      print('login');
                    },
                   ),
                   SizedBox(height: 20),
                   Row( 
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Não tem uma conta?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Cadastro()),
                            );
                          },
                          child: Text("Cadastre-se"),
                        ),
                      ],
                   )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),      
    ); 
  }
}
