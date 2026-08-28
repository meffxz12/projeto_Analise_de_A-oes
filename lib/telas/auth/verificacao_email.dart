import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/auth/login.dart';

class VerificacaoEmailScreen extends StatefulWidget {
final String nome;

const VerificacaoEmailScreen({
super.key,
required this.nome,
});

@override
State<VerificacaoEmailScreen> createState() =>
_VerificacaoEmailScreenState();
}

class _VerificacaoEmailScreenState
extends State<VerificacaoEmailScreen> {
bool _loading = false;

Future<void> _verificar() async {
setState(() => _loading = true);

```
try {
  final verificado =
      await ApiService.verificarEmailFirebase();

  if (!verificado) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'O e-mail ainda não foi verificado.',
        ),
      ),
    );

    return;
  }

  // ======================================================
  // AGORA CRIA O USUÁRIO NO POSTGRESQL PELO FASTAPI
  // ======================================================

  await ApiService.finalizarCadastro(
    widget.nome,
  );

  await FirebaseAuth.instance.signOut();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'E-mail verificado! Agora você já pode entrar.',
      ),
    ),
  );

} catch (e) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      ),
    ),
  );
} finally {
  if (mounted) {
    setState(() => _loading = false);
  }
}
```

}

Future<void> _reenviarEmail() async {
try {
await ApiService.reenviarEmailVerificacao();

```
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'E-mail de verificação reenviado.',
      ),
    ),
  );
} catch (e) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      ),
    ),
  );
}
```

}

Future<void> _cancelar() async {
await FirebaseAuth.instance.signOut();

```
if (!mounted) return;

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const LoginScreen(),
  ),
  (route) => false,
);
```

}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [
Color(0xFF6A5AE0),
Color(0xFF8E7CFF),
],
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
),
),
child: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(25),
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
const Icon(
Icons.mark_email_read,
size: 80,
color: Color(0xFF6A5AE0),
),

```
                const SizedBox(height: 20),

                const Text(
                  'Verifique seu e-mail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'Enviamos um link de verificação '
                  'para o e-mail cadastrado.\n\n'
                  'Abra seu e-mail, clique no link '
                  'de verificação e depois volte '
                  'para o aplicativo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 30),

                _loading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF6A5AE0),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _verificar,
                          icon: const Icon(
                            Icons.verified,
                          ),
                          label: const Text(
                            'Já verifiquei meu e-mail',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6A5AE0),
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: _reenviarEmail,
                  child: const Text(
                    'Reenviar e-mail de verificação',
                    style: TextStyle(
                      color: Color(0xFF6A5AE0),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: _cancelar,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
```

}
}
