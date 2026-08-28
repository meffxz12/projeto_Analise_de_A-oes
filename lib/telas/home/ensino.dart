import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/telas/perfilusuario.dart';
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
  final int? materialIdInicial;
  final String? urlMaterialInicial;

  const EnsinoScreen({
    super.key,
    this.materialIdInicial,
    this.urlMaterialInicial,
  });

  @override
  State<EnsinoScreen> createState() => _EnsinoScreenState();
}

class _EnsinoScreenState extends State<EnsinoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ==========================================================
  // AVATAR
  // ==========================================================

  String _avatar = 'avatar_1';

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
  // CONTROLE PARA NÃO ABRIR DUAS VEZES
  // ==========================================================

  bool _materialInicialProcessado = false;

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
    _carregarAvatar();
  }

  // ==========================================================
  // CARREGAR AVATAR
  // ==========================================================

  Future<void> _carregarAvatar() async {
    try {
      final data = await ApiService.buscarPerfil();

      if (!mounted) return;

      setState(() {
        _avatar = data['avatar'] ?? 'avatar_1';
      });
    } catch (e) {
      debugPrint('Erro ao carregar avatar: $e');
    }
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

      debugPrint('Erro ao verificar administrador: $e');
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

      debugPrint('Erro ao carregar vídeos: $e');
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
        String url = '';

        if (item['url'] != null) {
          url = item['url'].toString();
        }

        if (url.startsWith('/')) {
          url = '${ApiService.baseUrl}$url';
        }

        debugPrint('====================================');
        debugPrint('MATERIAL CARREGADO');
        debugPrint('ID: ${item['id']}');
        debugPrint('TÍTULO: ${item['titulo']}');
        debugPrint('URL ORIGINAL: ${item['url']}');
        debugPrint('URL FINAL: $url');
        debugPrint('====================================');

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

      await _abrirMaterialInicial();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoMateriais = false;
        _erroMateriais = e.toString();
      });

      debugPrint('Erro ao carregar materiais: $e');
    }
  }

  // ==========================================================
  // ABRIR MATERIAL INICIAL
  // ==========================================================

  Future<void> _abrirMaterialInicial() async {
    if (widget.materialIdInicial == null) {
      return;
    }

    if (_materialInicialProcessado) {
      return;
    }

    _materialInicialProcessado = true;

    final materialId = widget.materialIdInicial!;

    debugPrint('====================================');
    debugPrint('ABRINDO MATERIAL RECEBIDO PELA NOTIFICAÇÃO');
    debugPrint('ID: $materialId');
    debugPrint('====================================');

    ConteudoLeitura? material;

    try {
      material = _materiais.firstWhere(
        (item) => item.id == materialId,
      );
    } catch (_) {
      material = null;
    }

    if (material != null) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      await _abrirMaterial(material);
      return;
    }

    final url = widget.urlMaterialInicial;

    if (url != null && url.trim().isNotEmpty) {
      String urlFinal = url.trim();

      if (urlFinal.startsWith('/')) {
        urlFinal = '${ApiService.baseUrl}$urlFinal';
      }

      final materialTemporario = ConteudoLeitura(
        id: materialId,
        titulo: 'Material',
        descricao: '',
        tipo: 'PDF',
        arquivo: urlFinal,
        tema: '',
      );

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      await _abrirMaterial(materialTemporario);
      return;
    }

    debugPrint(
      'Não foi possível encontrar o material.',
    );
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
    debugPrint('ID: ${material.id}');
    debugPrint('URL: $urlString');
    debugPrint('====================================');

    if (urlString.isEmpty) {
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

      final podeAbrir = await canLaunchUrl(url);

      if (!podeAbrir) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o arquivo.',
            ),
          ),
        );

        return;
      }

      final abriu = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
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
    } catch (e) {
      debugPrint('Erro ao abrir material: $e');

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
                      Row(
                        children: [
                          if (!_carregandoAdmin && _isAdmin)
                            IconButton(
                              tooltip:
                                  'Gerenciar conteúdo',
                              icon: const Icon(
                                Icons
                                    .admin_panel_settings_rounded,
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

                          // PERFIL COM AVATAR
                          InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PerfilScreen(),
                                ),
                              );

                              _carregarAvatar();
                            },
                            borderRadius:
                                BorderRadius.circular(20),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Colors.white24,
                              backgroundImage: AssetImage(
                                avatarAssetPath(_avatar),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TabBar(
                    controller: _tab,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabAlignment:
                        TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Vídeos'),
                      Tab(text: 'Leitura'),
                    ],
                  ),
                ],
              ),
            ),

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

          final url = video['url'] ?? '';

          final duracao =
              video['duracao']?.toString() ?? '';

          final videoId = _extrairVideoId(url);

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

  String? _extrairVideoId(String url) {
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
        borderRadius: BorderRadius.circular(15),
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
                onPressed: _carregarMateriais,
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
        onRefresh: _carregarMateriais,
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
      onRefresh: _carregarMateriais,
      child: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: _materiais.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final material = _materiais[index];

          return _materialCard(material);
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

    switch (material.tipo.toLowerCase()) {
      case 'pdf':
        icone = Icons.picture_as_pdf_rounded;
        cor = Colors.red;
        break;

      case 'epub':
        icone = Icons.menu_book_rounded;
        cor = Colors.deepPurple;
        break;

      case 'mobi':
        icone = Icons.book_rounded;
        cor = Colors.orange;
        break;

      default:
        icone = Icons.description_rounded;
        cor = Colors.blue;
    }

    return GestureDetector(
      onTap: () => _abrirMaterial(material),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.12),
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

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    material.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  if (material.descricao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      material.descricao,
                      style: TextStyle(
                        color: Colors.grey[500],
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
                            const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              cor.withOpacity(0.10),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(
                          material.tipo.toUpperCase(),
                          style: TextStyle(
                            color: cor,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      if (material.tema.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            material.tema,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                            overflow:
                                TextOverflow.ellipsis,
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