import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/telas/perfilusuario.dart';
import 'package:meu_apli/telas/home/gerenciar_videos.dart';
import 'package:meu_apli/telas/home/centro_ensino_page.dart';
import 'package:meu_apli/services/apiservice.dart';

// ============================================================
// MODEL PARA CONTEÚDOS DE LEITURA
// ============================================================

class ConteudoLeitura {
  final int id;
  final String titulo;
  final String descricao;
  final String tipo;
  final String arquivo;
  final String tema;

  const ConteudoLeitura({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.arquivo,
    required this.tema,
  });
}

// ============================================================
// SCREEN
// ============================================================

class EnsinoScreen extends StatefulWidget {
  const EnsinoScreen({super.key});

  @override
  State<EnsinoScreen> createState() => _EnsinoScreenState();
}

class _EnsinoScreenState extends State<EnsinoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ==========================================================
  // ADMIN
  // ==========================================================

  bool _isAdmin = false;
  bool _carregandoAdmin = true;

  // ==========================================================
  // VÍDEOS
  // ==========================================================

  List<dynamic> _videos = [];

  bool _carregandoVideos = true;

  String? _erroVideos;

  // ==========================================================
  // MATERIAIS
  // ==========================================================

  List<ConteudoLeitura> _materiais = [];

  bool _carregandoMateriais = true;

  String? _erroMateriais;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _tab = TabController(
      length: 2,
      vsync: this,
    );

    _verificarAdmin();
    _carregarVideos();
    _carregarMateriais();
  }

  // ==========================================================
  // VERIFICAR ADMIN
  // ==========================================================

  Future<void> _verificarAdmin() async {
    try {
      final admin = await ApiService.isAdmin();

      if (!mounted) return;

      setState(() {
        _isAdmin = admin;
        _carregandoAdmin = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAdmin = false;
        _carregandoAdmin = false;
      });

      debugPrint(
        'Erro ao verificar administrador: $e',
      );
    }
  }

  // ==========================================================
  // CARREGAR VÍDEOS
  // ==========================================================

  Future<void> _carregarVideos() async {
    if (mounted) {
      setState(() {
        _carregandoVideos = true;
        _erroVideos = null;
      });
    }

    try {
      final resultado = await ApiService.listarVideos();

      if (!mounted) return;

      setState(() {
        _videos = resultado;
        _carregandoVideos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoVideos = false;
        _erroVideos = e.toString();
      });

      debugPrint(
        'Erro ao carregar vídeos: $e',
      );
    }
  }

  // ==========================================================
  // CARREGAR MATERIAIS
  // ==========================================================

  Future<void> _carregarMateriais() async {
    if (mounted) {
      setState(() {
        _carregandoMateriais = true;
        _erroMateriais = null;
      });
    }

    try {
      final resultado = await ApiService.listarMateriais();

      debugPrint('====================================');
      debugPrint('MATERIAIS RECEBIDOS');
      debugPrint('$resultado');
      debugPrint('====================================');

      final materiais = resultado.map<ConteudoLeitura>((item) {
        // O backend retorna "url", não "arquivo".
        String url = '';

        if (item['url'] != null) {
          url = item['url'].toString();
        }

        // Se a API retornar uma URL relativa,
        // adicionamos o endereço do backend.
        if (url.startsWith('/')) {
          url = '${ApiService.baseUrl}$url';
        }

        debugPrint(
          'Material: ${item['titulo']}',
        );

        debugPrint(
          'URL original: ${item['url']}',
        );

        debugPrint(
          'URL final: $url',
        );

        return ConteudoLeitura(
          id: item['id'] ?? 0,
          titulo: item['titulo'] ?? 'Sem título',
          descricao: item['descricao'] ?? '',
          tipo: item['tipo'] ?? 'PDF',
          arquivo: url,
          tema: item['tema'] ?? '',
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _materiais = materiais;
        _carregandoMateriais = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoMateriais = false;
        _erroMateriais = e.toString();
      });

      debugPrint(
        'Erro ao carregar materiais: $e',
      );
    }
  }

  // ==========================================================
  // ABRIR MATERIAL
  // ==========================================================

  Future<void> _abrirMaterial(
    ConteudoLeitura material,
  ) async {
    final urlString = material.arquivo.trim();

    debugPrint('====================================');
    debugPrint('ABRINDO MATERIAL');
    debugPrint('Título: ${material.titulo}');
    debugPrint('URL: $urlString');
    debugPrint('====================================');

    if (urlString.isEmpty) {
      debugPrint(
        'ERRO: URL do material está vazia.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O arquivo não possui uma URL válida.',
          ),
        ),
      );

      return;
    }

    try {
      final url = Uri.parse(urlString);

      debugPrint(
        'URI criada: $url',
      );

      final podeAbrir = await canLaunchUrl(url);

      debugPrint(
        'Pode abrir URL: $podeAbrir',
      );

      if (podeAbrir) {
        final abriu = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        debugPrint(
          'Resultado do launchUrl: $abriu',
        );

        if (!abriu && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível abrir o arquivo.',
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o arquivo.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Erro ao abrir material: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao abrir arquivo: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _tab.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: CoresGlobais.backgrounder,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // TÍTULO + BOTÕES
                  // ==========================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Centro de Ensino',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ======================================
                      // BOTÕES
                      // ======================================

                      Row(
                        children: [
                          // ADMIN
                          if (!_carregandoAdmin && _isAdmin)
                            IconButton(
                              tooltip:
                                  'Gerenciar conteúdo',
                              icon: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CentroEnsinoPage(),
                                  ),
                                );

                                _carregarVideos();
                                _carregarMateriais();
                              },
                            ),

                          // PERFIL
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PerfilScreen(),
                                ),
                              );
                            },
                            borderRadius:
                                BorderRadius.circular(20),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Colors.white24,
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // ABAS
                  // ==========================================

                  TabBar(
                    controller: _tab,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabAlignment:
                        TabAlignment.start,
                    tabs: const [
                      Tab(
                        text: 'Vídeos',
                      ),
                      Tab(
                        text: 'Leitura',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTEÚDO
            // ==================================================

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _abaVideos(),
                  _abaLeitura(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ABA VÍDEOS
  // ==========================================================

  Widget _abaVideos() {
    if (_carregandoVideos) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erroVideos != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar os vídeos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregarVideos,
                child: const Text(
                  'Tentar novamente',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _carregarVideos,
        child: ListView(
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'Nenhum vídeo disponível.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarVideos,
      child: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: _videos.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final video = _videos[index];

          final titulo =
              video['titulo'] ?? 'Sem título';

          final url =
              video['url'] ?? '';

          final duracao =
              video['duracao']?.toString() ?? '';

          final videoId =
              _extrairVideoId(url);

          if (videoId == null) {
            return _videoInvalido(
              titulo,
              url,
            );
          }

          return VideoCard(
            title: titulo,
            videoId: videoId,
            duration: duracao,
          );
        },
      ),
    );
  }

  // ==========================================================
  // EXTRAIR ID DO YOUTUBE
  // ==========================================================

  String? _extrairVideoId(
    String url,
  ) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }

      if (uri.host.contains('youtu.be')) {
        if (uri.pathSegments.isNotEmpty) {
          return uri.pathSegments.first;
        }
      }
    } catch (_) {}

    return null;
  }

  // ==========================================================
  // VÍDEO INVÁLIDO
  // ==========================================================

  Widget _videoInvalido(
    String titulo,
    String url,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'URL do YouTube inválida.',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            url,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ABA LEITURA
  // ==========================================================

  Widget _abaLeitura() {
    if (_carregandoMateriais) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erroMateriais != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar os materiais.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    _carregarMateriais,
                child: const Text(
                  'Tentar novamente',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_materiais.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _carregarMateriais,
        child: ListView(
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'Nenhum material disponível.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _carregarMateriais,
      child: ListView.separated(
        padding:
            const EdgeInsets.all(15),
        itemCount:
            _materiais.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(height: 10),
        itemBuilder:
            (context, index) {
          final material =
              _materiais[index];

          return _materialCard(
            material,
          );
        },
      ),
    );
  }

  // ==========================================================
  // CARD DO MATERIAL
  // ==========================================================

  Widget _materialCard(
    ConteudoLeitura material,
  ) {
    IconData icone;
    Color cor;

    switch (
        material.tipo.toLowerCase()) {
      case 'pdf':
        icone =
            Icons.picture_as_pdf_rounded;
        cor = Colors.red;
        break;

      case 'epub':
        icone =
            Icons.menu_book_rounded;
        cor = Colors.deepPurple;
        break;

      case 'mobi':
        icone =
            Icons.book_rounded;
        cor = Colors.orange;
        break;

      default:
        icone =
            Icons.description_rounded;
        cor = Colors.blue;
    }

    return GestureDetector(
      onTap: () =>
          _abrirMaterial(material),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ==============================================
            // ÍCONE
            // ==============================================

            Container(
              width: 50,
              height: 50,
              decoration:
                  BoxDecoration(
                color:
                    cor.withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icone,
                color: cor,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            // ==============================================
            // TEXTOS
            // ==============================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    material.titulo,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  if (material
                      .descricao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      material.descricao,
                      style: TextStyle(
                        color:
                            Colors.grey[500],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              cor.withOpacity(
                                  0.10),
                          borderRadius:
                              BorderRadius
                                  .circular(6),
                        ),
                        child: Text(
                          material.tipo
                              .toUpperCase(),
                          style:
                              TextStyle(
                            color: cor,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      if (material
                          .tema.isNotEmpty) ...[
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            material.tema,
                            style:
                                TextStyle(
                              color:
                                  Colors.grey[400],
                              fontSize: 10,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

