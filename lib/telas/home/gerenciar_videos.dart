import 'package:flutter/material.dart';

import '../../services/apiservice.dart';

class GerenciarVideosPage extends StatefulWidget {
  const GerenciarVideosPage({super.key});

  @override
  State<GerenciarVideosPage> createState() => _GerenciarVideosPageState();
}

class _GerenciarVideosPageState extends State<GerenciarVideosPage> {
  List<dynamic> videos = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarVideos();
  }

  Future<void> carregarVideos() async {
    try {
      final resultado = await ApiService.listarVideosAdmin();

      if (!mounted) return;

      setState(() {
        videos = resultado;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar vídeos: $e')));
    }
  }

  Future<void> adicionarVideo() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const _VideoDialog();
      },
    );

    if (resultado == true) {
      await carregarVideos();
    }
  }

  Future<void> editarVideo(Map<String, dynamic> video) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _VideoDialog(video: video);
      },
    );

    if (resultado == true) {
      await carregarVideos();
    }
  }

  Future<void> excluirVideo(Map<String, dynamic> video) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir vídeo?'),
          content: Text('Deseja excluir "${video['titulo']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await ApiService.excluirVideoAdmin(video['id']);

      await carregarVideos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vídeo excluído com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir vídeo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar vídeos')),

      floatingActionButton: FloatingActionButton(
        onPressed: adicionarVideo,
        child: const Icon(Icons.add),
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : videos.isEmpty
          ? const Center(child: Text('Nenhum vídeo cadastrado.'))
          : RefreshIndicator(
              onRefresh: carregarVideos,

              child: ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: videos.length,

                itemBuilder: (context, index) {
                  final video = videos[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            video['titulo'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          if (video['descricao'] != null)
                            Text(video['descricao']),

                          const SizedBox(height: 8),

                          if (video['tema'] != null)
                            Text('Tema: ${video['tema']}'),

                          if (video['duracao'] != null)
                            Text('Duração: ${video['duracao']}'),

                          const SizedBox(height: 12),

                          Text(
                            video['url'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              IconButton(
                                onPressed: () {
                                  editarVideo(video);
                                },
                                icon: const Icon(Icons.edit),
                              ),

                              IconButton(
                                onPressed: () {
                                  excluirVideo(video);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
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
// FORMULÁRIO DE VÍDEO
// ============================================================

class _VideoDialog extends StatefulWidget {
  final Map<String, dynamic>? video;

  const _VideoDialog({this.video});

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  late TextEditingController tituloController;
  late TextEditingController descricaoController;
  late TextEditingController urlController;
  late TextEditingController temaController;
  late TextEditingController duracaoController;

  bool salvando = false;

  bool get editando => widget.video != null;

  @override
  void initState() {
    super.initState();

    final video = widget.video;

    tituloController = TextEditingController(text: video?['titulo'] ?? '');

    descricaoController = TextEditingController(
      text: video?['descricao'] ?? '',
    );

    urlController = TextEditingController(text: video?['url'] ?? '');

    temaController = TextEditingController(text: video?['tema'] ?? '');

    duracaoController = TextEditingController(text: video?['duracao'] ?? '');
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    urlController.dispose();
    temaController.dispose();
    duracaoController.dispose();

    super.dispose();
  }

  Future<void> salvar() async {
    if (tituloController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título e URL são obrigatórios.')),
      );

      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      if (editando) {
        await ApiService.editarVideoAdmin(
          videoId: widget.video!['id'],
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim(),
          url: urlController.text.trim(),
          tema: temaController.text.trim(),
          duracao: duracaoController.text.trim(),
        );
      } else {
        await ApiService.adicionarVideoAdmin(
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim(),
          url: urlController.text.trim(),
          tema: temaController.text.trim(),
          duracao: duracaoController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(editando ? 'Editar vídeo' : 'Adicionar vídeo'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título *'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL do vídeo *'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: temaController,
              decoration: const InputDecoration(labelText: 'Tema'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: duracaoController,
              decoration: const InputDecoration(labelText: 'Duração'),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: salvando
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Text('Cancelar'),
        ),

        ElevatedButton(
          onPressed: salvando ? null : salvar,

          child: salvando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
