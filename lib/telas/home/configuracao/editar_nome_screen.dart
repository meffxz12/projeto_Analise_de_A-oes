import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

class EditarNomeScreen extends StatefulWidget {
  final String nomeAtual;

  const EditarNomeScreen({
    super.key,
    required this.nomeAtual,
  });

  @override
  State<EditarNomeScreen> createState() => _EditarNomeScreenState();
}

class _EditarNomeScreenState extends State<EditarNomeScreen> {
  late TextEditingController _nomeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(
      text: widget.nomeAtual,
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvarNome() async {
    final novoNome = _nomeController.text.trim();

    if (novoNome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um nome.'),
        ),
      );
      return;
    }

    if (novoNome == widget.nomeAtual.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um nome diferente do atual.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.atualizarPerfil(novoNome);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nome atualizado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context, true);
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // =====================================================
          // CABEÇALHO
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              10,
              40,
              20,
              30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: CoresGlobais.backgrounder,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(context),
                ),
                const Text(
                  'Alterar nome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // =====================================================
          // FORMULÁRIO
          // =====================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nome',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _nomeController,
                  textCapitalization:
                      TextCapitalization.words,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Digite seu nome',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // BOTÃO SALVAR
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _salvarNome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CoresGlobais.backgrounder.first,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Salvar alteração',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}