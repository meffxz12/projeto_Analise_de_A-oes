import 'dart:async';

import 'package:flutter/material.dart';

import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/opcaocard.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/componentes/grafico.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/telas/fundos_screen.dart';
import 'package:meu_apli/telas/home/acoes_screen.dart';
import 'package:meu_apli/telas/perfilusuario.dart';
import 'package:meu_apli/telas/notificacoes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _buscaController =
      TextEditingController();

  Timer? _debounce;

  // ==========================================================
  // RESULTADOS
  // ==========================================================

  List<dynamic> _resultadosAtivos = [];

  List<dynamic> _videos = [];

  // ==========================================================
  // ESTADO
  // ==========================================================

  String _query = '';

  bool _pesquisandoAtivos = false;

  bool _carregandoVideos = true;

  String? _erroBusca;

  // ==========================================================
  // USUÁRIO / AVATAR
  // ==========================================================

  String _avatarAtual = 'avatar_1';

  // ==========================================================
  // NOTIFICAÇÕES
  // ==========================================================

  int _notificacoesNaoLidas = 0;

  Timer? _timerNotificacoes;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _carregarPerfil();

    _carregarVideos();

    _carregarNotificacoesNaoLidas();

    _timerNotificacoes = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (mounted) {
          _carregarNotificacoesNaoLidas();
        }
      },
    );

    _buscaController.addListener(
      _quandoPesquisar,
    );
  }

  // ==========================================================
  // CARREGAR PERFIL / AVATAR
  // ==========================================================

  Future<void> _carregarPerfil() async {
    try {
      final perfil = await ApiService.buscarPerfil();

      if (!mounted) return;

      final avatar = perfil['avatar']?.toString();

      if (avatar != null && avatar.isNotEmpty) {
        setState(() {
          _avatarAtual = avatar;
        });
      }
    } catch (e) {
      print('Erro ao carregar avatar do usuário: $e');
    }
  }

  // ==========================================================
  // PESQUISA
  // ==========================================================

  void _quandoPesquisar() {
    if (!mounted) return;

    final texto = _buscaController.text.trim();

    setState(() {
      _query = texto;
    });

    _debounce?.cancel();

    if (texto.isEmpty) {
      setState(() {
        _resultadosAtivos = [];
        _pesquisandoAtivos = false;
        _erroBusca = null;
      });

      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          _pesquisarAtivos(texto);
        }
      },
    );
  }

  Future<void> _pesquisarAtivos(
    String texto,
  ) async {
    if (!mounted) return;

    setState(() {
      _pesquisandoAtivos = true;
      _erroBusca = null;
    });

    try {
      print('====================================');
      print('INICIANDO PESQUISA');
      print('BUSCA: $texto');
      print('====================================');

      final resultados =
          await ApiService.pesquisarAtivos(
        texto,
        tipo: 'todos',
        limit: 30,
      );

      if (!mounted) return;

      print('====================================');
      print('RESULTADOS RECEBIDOS');
      print('QUANTIDADE: ${resultados.length}');
      print('DADOS: $resultados');
      print('====================================');

      setState(() {
        _resultadosAtivos = resultados;
        _pesquisandoAtivos = false;
        _erroBusca = null;
      });
    } catch (e) {
      if (!mounted) return;

      print('====================================');
      print('ERRO NA PESQUISA');
      print('ERRO: $e');
      print('====================================');

      setState(() {
        _pesquisandoAtivos = false;
        _erroBusca = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ==========================================================
  // VÍDEOS
  // ==========================================================

  Future<void> _carregarVideos() async {
    try {
      final videos =
          await ApiService.listarVideos();

      if (!mounted) return;

      setState(() {
        _videos = videos;
        _carregandoVideos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoVideos = false;
      });

      print(
        'Erro ao carregar vídeos: $e',
      );
    }
  }

  // ==========================================================
  // CICLO DE VIDA
  // ==========================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _carregarNotificacoesNaoLidas();
        _carregarPerfil();
      }
    }
  }

  // ==========================================================
  // NOTIFICAÇÕES
  // ==========================================================

  Future<void> _carregarNotificacoesNaoLidas() async {
    try {
      final quantidade =
          await ApiService.contarNotificacoesNaoLidas();

      if (!mounted) return;

      setState(() {
        _notificacoesNaoLidas = quantidade;
      });
    } catch (e) {
      print(
        'Erro ao carregar notificações: $e',
      );
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _timerNotificacoes?.cancel();

    _debounce?.cancel();

    _buscaController.removeListener(
      _quandoPesquisar,
    );

    _buscaController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: _query.isNotEmpty
                  ? _buildResultadosBusca()
                  : _buildConteudoPadrao(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CONTEÚDO PADRÃO
  // ==========================================================

  Widget _buildConteudoPadrao() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          _card(
            child: const GraficoAcao(),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OpcaoCard(
                    text: 'Fundos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FundosScreen(),
                        ),
                      );
                    },
                    color: CoresGlobais.botao2,
                    textColor: Colors.white,
                    icon: Icons.pie_chart_rounded,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OpcaoCard(
                    text: 'Ações',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AcoesScreen(),
                        ),
                      );
                    },
                    color: CoresGlobais.botao2,
                    textColor: Colors.white,
                    icon: Icons.show_chart_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _card(
            child: _buildVideos(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================================
  // VÍDEOS
  // ==========================================================

  Widget _buildVideos() {
    if (_carregandoVideos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_videos.isEmpty) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Vídeos em destaque',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Nenhum vídeo disponível.',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ========================================================
    // VÍDEOS MAIS RECENTES
    // ========================================================

    final videosRecentes =
        List<dynamic>.from(_videos);

    // A API normalmente já retorna os vídeos
    // em ordem de cadastro. Mantemos apenas
    // os 3 primeiros para a Home.

    final quantidade =
        videosRecentes.length > 3
            ? 3
            : videosRecentes.length;

    final ultimosVideos =
        videosRecentes.take(quantidade).toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimos vídeos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 14),

        ...ultimosVideos.map(
          (video) {
            final titulo =
                video['titulo']?.toString() ??
                    'Vídeo';

            final url =
                video['url']?.toString() ??
                    '';

            final duracao =
                video['duracao']?.toString() ??
                    '';

            // ==================================================
            // PEGA O ID DO YOUTUBE
            // ==================================================

            String videoId = '';

            if (url.contains('v=')) {
              videoId =
                  url.split('v=').last.split('&').first;
            } else if (url.contains('youtu.be/')) {
              videoId =
                  url.split('youtu.be/').last.split('?').first;
            } else if (url.contains('/shorts/')) {
              videoId =
                  url.split('/shorts/').last.split('?').first;
            }

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: VideoCard(
                title: titulo,
                videoId: videoId,
                duration: duracao,
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // RESULTADOS DA BUSCA
  // ==========================================================

  Widget _buildResultadosBusca() {
    if (_pesquisandoAtivos) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erroBusca != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.grey[400],
              ),

              const SizedBox(height: 10),

              Text(
                _erroBusca!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  _pesquisarAtivos(_query);
                },
                child: const Text(
                  'Tentar novamente',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultadosAtivos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.grey[300],
            ),

            const SizedBox(height: 12),

            Text(
              'Nenhum ativo encontrado',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _resultadosAtivos.length,
      itemBuilder: (context, index) {
        final ativo =
            _resultadosAtivos[index];

        final codigo =
            ativo['stock']?.toString() ?? '';

        final nome =
            ativo['name']?.toString() ?? '';

        final tipo =
            ativo['type']?.toString() ?? '';

        final preco =
            ativo['close'];

        final tipoNormalizado =
            tipo.toLowerCase();

        final bool isFundo =
            tipoNormalizado == 'fund' ||
            tipoNormalizado == 'funds' ||
            tipoNormalizado == 'fii';

        final bool isBdr =
            tipoNormalizado == 'bdr';

        String textoTipo;

        if (isFundo) {
          textoTipo =
              'Fundo Imobiliário';
        } else if (isBdr) {
          textoTipo = 'BDR';
        } else {
          textoTipo = 'Ação';
        }

        return Container(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          decoration: BoxDecoration(
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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isFundo
                    ? Colors.orange
                        .withOpacity(0.12)
                    : CoresGlobais.botao2
                        .withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                isFundo
                    ? Icons.pie_chart_rounded
                    : Icons.show_chart_rounded,
                color: isFundo
                    ? Colors.orange
                    : CoresGlobais.botao2,
              ),
            ),
            title: Text(
              codigo,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (nome.isNotEmpty)
                  Text(
                    nome,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 2),

                Text(
                  textoTipo,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            trailing: preco != null
                ? Text(
                    'R\$ ${_formatarPreco(preco)}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  // ==========================================================
  // FORMATAR PREÇO
  // ==========================================================

  String _formatarPreco(dynamic valor) {
    final numero =
        double.tryParse(
              valor.toString(),
            ) ??
            0;

    return numero.toStringAsFixed(2);
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24,
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
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: TextField(
                controller:
                    _buscaController,
                decoration:
                    InputDecoration(
                  hintText: 'Buscar ativos',
                  hintStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),
                  border:
                      InputBorder.none,
                  icon:
                      const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                  ),
                  suffixIcon:
                      _query.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                color:
                                    Colors.white70,
                              ),
                              onPressed: () {
                                _buscaController
                                    .clear();
                              },
                            )
                          : null,
                ),
                style:
                    const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ====================================================
          // NOTIFICAÇÕES
          // ====================================================

          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificacoesScreen(),
                ),
              );

              if (!mounted) return;

              await
                  _carregarNotificacoesNaoLidas();
            },
            borderRadius:
                BorderRadius.circular(20),
            child: Stack(
              clipBehavior:
                  Clip.none,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Colors.white24,
                  child: Icon(
                    Icons
                        .notifications_rounded,
                    color: Colors.white,
                  ),
                ),

                if (_notificacoesNaoLidas >
                    0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color.fromARGB(
                          255,
                          168,
                          37,
                          28,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(10),
                        border:
                            Border.all(
                          color:
                              Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _notificacoesNaoLidas >
                                99
                            ? '99+'
                            : _notificacoesNaoLidas
                                .toString(),
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ====================================================
          // PERFIL / AVATAR DO USUÁRIO
          // ====================================================

          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PerfilScreen(),
                ),
              );

              if (!mounted) return;

              // Depois que o usuário volta
              // do perfil, busca novamente
              // o avatar atualizado.

              await _carregarPerfil();

              await
                  _carregarNotificacoesNaoLidas();
            },
            borderRadius:
                BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 20,
              backgroundColor:
                  Colors.white24,
              backgroundImage: AssetImage(
                avatarAssetPath(
                  _avatarAtual,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARD
  // ==========================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}