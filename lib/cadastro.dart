import 'package:flutter/material.dart';
import 'package:meu_app/login/button.dart';
import '../text.form.global.dart';
class Cadastro extends StatelessWidget {
  Cadastro({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final TextEditingController confirmasenha = TextEditingController();
  final TextEditingController matricula = TextEditingController();

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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Form(
                key: formKey,
                
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    // Nome
                    TextFormGlobal(controller: nome, 
                    text: "Nome Completo", 
                    obscure: false, 
                    textInputType: TextInputType.name,
                     prefixicon: Icons.person,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira Nome Completo';
                      }
                      return null;  
                     }
                     ),

                  
                    SizedBox(height: 15),

                    TextFormGlobal(controller: matricula, text: "Matrícula", obscure: false, textInputType: TextInputType.name, prefixicon: Icons.badge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira Matrícula';
                      }
                      return null;
                    },
                    ),
                    SizedBox(height: 15),
                    // senha
                    TextFormGlobal(controller: email, text: "Email", obscure: false, textInputType: TextInputType.emailAddress, prefixicon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira Email';
                      }
                      return null;
                    },
                    ),
                   SizedBox(height: 15),
                   TextFormGlobal(controller: senha, text: "Senha", obscure: true, textInputType: TextInputType.visiblePassword, prefixicon: Icons.lock,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Por favor, insira Senha';
                     }
                     return null;
                   },
                   ),
                   SizedBox(height: 15),
                   TextFormGlobal(controller: confirmasenha, text: "Confirmar Senha", obscure: true, textInputType: TextInputType.visiblePassword, prefixicon: Icons.lock,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Por favor, confirme Senha';
                     } if (value != senha.text) {
                       return 'As senhas não coincidem';
                     }
                     return null;
                   },
                   ),
                   SizedBox(height: 15),
                   //botão entrar
                    ButtonGlobal(color: Color.fromARGB(255, 34, 66, 245), 
                   text: 'Cadastrar',
                   onTap: () {
                    if (formKey.currentState!.validate()) {
                      print("Cadastro realizado com sucesso");
                    }
                    },
                   ),
                   SizedBox(height: 20),
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
                          Navigator.pop(context);
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
                   )
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
