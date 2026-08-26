import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/apiservice.dart';

class GerenciarMateriaisPage extends StatefulWidget {
  const GerenciarMateriaisPage({
    super.key,
  });

  @override
  State<GerenciarMateriaisPage> createState() =>
      _GerenciarMateriaisPageState();
}

class _GerenciarMateriaisPageState
    extends State<GerenciarMateriaisPage> {
  List<dynamic> materiais = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarMateriais();
  }

  // ==========================================================
  // CARREGAR MATERIAIS
  // ==========================================================

  Future<void> carregarMateriais() async {
    try {
      setState(() {
        carregando = true;
      });

      final resultado =
          await ApiService.listarMateriais();

      if (!mounted) return;

      setState(() {
        materiais = resultado;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar materiais: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ADICIONAR MATERIAL
  // ==========================================================

  Future<void> adicionarMaterial() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => const _MaterialDialog(),
    );

    if (resultado == true) {
      await carregarMateriais();
    }
  }

  // ==========================================================
  // EXCLUIR MATERIAL
  // ==========================================================

  Future<void> excluirMaterial(
    Map<String, dynamic> material,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir material?',
          ),
          content: Text(
            'Deseja excluir "${material['titulo']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Excluir',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      final id = material['id'];

      if (id == null) {
        throw Exception(
          'ID do material não encontrado.',
        );
      }

      await ApiService.excluirMaterial(
        int.parse(id.toString()),
      );

      await carregarMateriais();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Material excluído com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao excluir material: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ÍCONE
  // ==========================================================

  Widget _iconeTipo(
    String? tipo,
  ) {
    final tipoNormalizado =
        (tipo ?? '').toUpperCase();

    IconData icone;

    Color cor;

    switch (tipoNormalizado) {
      case 'PDF':
        icone = Icons.picture_as_pdf_rounded;
        cor = Colors.red;
        break;

      case 'EPUB':
        icone = Icons.menu_book_rounded;
        cor = Colors.deepPurple;
        break;

      case 'MOBI':
        icone = Icons.book_rounded;
        cor = Colors.orange;
        break;

      default:
        icone = Icons.description_rounded;
        cor = Colors.blue;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icone,
        color: cor,
        size: 27,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciar materiais',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMaterial,
        child: const Icon(
          Icons.add,
        ),
      ),

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : materiais.isEmpty
              ? RefreshIndicator(
                  onRefresh: carregarMateriais,
                  child: ListView(
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          'Nenhum material cadastrado.',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: carregarMateriais,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: materiais.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final material =
                          Map<String, dynamic>.from(
                        materiais[index],
                      );

                      final titulo =
                          material['titulo']
                                  ?.toString() ??
                              'Sem título';

                      final descricao =
                          material['descricao']
                                  ?.toString() ??
                              '';

                      final tipo =
                          material['tipo']
                                  ?.toString() ??
                              '';

                      final tema =
                          material['tema']
                                  ?.toString() ??
                              '';

                      final nomeArquivo =
                          material['nome_arquivo']
                                  ?.toString() ??
                              '';

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          leading:
                              _iconeTipo(tipo),

                          title: Text(
                            titulo,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              if (descricao
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    descricao,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),

                              if (tema.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    'Tema: $tema',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[
                                              600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              if (nomeArquivo
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    nomeArquivo,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey[
                                              500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          trailing:
                              IconButton(
                            tooltip:
                                'Excluir material',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                excluirMaterial(
                              material,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ============================================================
// DIALOG DE ADICIONAR MATERIAL
// ============================================================

class _MaterialDialog
    extends StatefulWidget {
  const _MaterialDialog();

  @override
  State<_MaterialDialog> createState() =>
      _MaterialDialogState();
}

class _MaterialDialogState
    extends State<_MaterialDialog> {
  final tituloController =
      TextEditingController();

  final descricaoController =
      TextEditingController();

  final temaController =
      TextEditingController();

  String? caminhoArquivo;

  String? nomeArquivo;

  bool salvando = false;

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    temaController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SELECIONAR ARQUIVO
  // ==========================================================

  Future<void> selecionarArquivo() async {
    try {
      final resultado =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'epub',
          'mobi',
        ],
      );

      if (resultado == null) {
        return;
      }

      final arquivo =
          resultado.files.single;

      if (arquivo.path == null ||
          arquivo.path!.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível acessar o arquivo.',
            ),
          ),
        );

        return;
      }

      setState(() {
        caminhoArquivo =
            arquivo.path;

        nomeArquivo =
            arquivo.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao selecionar arquivo: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SALVAR
  // ==========================================================

  Future<void> salvar() async {
    final titulo =
        tituloController.text.trim();

    final descricao =
        descricaoController.text.trim();

    final tema =
        temaController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o título.',
          ),
        ),
      );

      return;
    }

    if (caminhoArquivo == null ||
        caminhoArquivo!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um arquivo.',
          ),
        ),
      );

      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      await ApiService.adicionarMaterial(
        titulo: titulo,
        descricao: descricao,
        tema: tema,
        caminhoArquivo:
            caminhoArquivo!,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao adicionar material: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Adicionar material',
      ),

      content:
          SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  tituloController,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'Título *',
                prefixIcon:
                    Icon(Icons.title),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              controller:
                  descricaoController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    'Descrição',
                prefixIcon:
                    Icon(
                  Icons.description_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              controller:
                  temaController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Tema',
                prefixIcon:
                    Icon(
                  Icons.category_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey[100],
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        salvando
                            ? null
                            : selecionarArquivo,
                    icon:
                        const Icon(
                      Icons.upload_file,
                    ),
                    label:
                        const Text(
                      'Selecionar arquivo',
                    ),
                  ),

                  if (nomeArquivo !=
                      null) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      nomeArquivo!,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'PDF, EPUB ou MOBI',
                    style:
                        TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed:
              salvando
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
          child:
              const Text(
            'Cancelar',
          ),
        ),

        ElevatedButton(
          onPressed:
              salvando
                  ? null
                  : salvar,
          child: salvando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Salvar',
                ),
        ),
      ],
    );
  }
}