import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/componentes/videocard.dart';
import 'package:meu_apli/services/apiservice.dart';
import 'package:meu_apli/services/apiservice.dart';

class EnsinoScreen extends StatefulWidget {
  const EnsinoScreen({super.key});

  @override
  State<EnsinoScreen> createState() => _EnsinoScreenState();
}

class _EnsinoScreenState extends State<EnsinoScreen> {
  late Future<List<dynamic>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = ApiService.listarVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: CoresGlobais.backgrounder),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.school_rounded, color: Colors.white),
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
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── VÍDEOS ────────────────────────────────────────
              _sectionCard(
                title: 'Vídeos',
                child: FutureBuilder<List<dynamic>>(
                  future: _videosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 36),
                              const SizedBox(height: 8),
                              const Text(
                                'Não foi possível carregar os vídeos',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() {
                                  _videosFuture = ApiService.listarVideos();
                                }),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final videos = snapshot.data!;
                    if (videos.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Nenhum vídeo disponível no momento.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(videos.length, (index) {
                        final video = videos[index];
                        final videoId = _extrairVideoId(video['url'] ?? '');

                        return Column(
                          children: [
                            VideoCard(
                              title: video['titulo'] ?? 'Sem título',
                              videoId: videoId,
                              duration: _formatarDuracao(video['duracao']),
                            ),
                            if (index < videos.length - 1) const SizedBox(height: 10),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _extrairVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
      return uri.queryParameters['v'] ?? '';
    } catch (_) {
      return '';
    }
  }

  String _formatarDuracao(dynamic duracao) {
    if (duracao == null) return '';
    final int seg = duracao is int ? duracao : int.tryParse('$duracao') ?? 0;
    final int min = seg ~/ 60;
    final int s = seg % 60;
    return '$min:${s.toString().padLeft(2, '0')}';
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}