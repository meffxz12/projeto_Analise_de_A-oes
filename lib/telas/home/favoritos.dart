import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<dynamic> _acoes = [];
  List<dynamic> _fundos = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final acoes = await ApiService.listarFavoritosAcoes();
      final fundos = await ApiService.listarFavoritosFundos();
      setState(() {
        _acoes = acoes;
        _fundos = fundos;
        _loading = false;
      });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Future<void> _removerAcao(String codigo) async {
    try {
      await ApiService.removerFavoritoAcao(codigo);
      setState(() => _acoes.removeWhere((a) => a['codigo'] == codigo));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover favorito')),
      );
    }
  }

  Future<void> _removerFundo(String codigo) async {
    try {
      await ApiService.removerFavoritoFundo(codigo);
      setState(() => _fundos.removeWhere((f) => f['codigo'] == codigo));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover favorito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Favoritos',
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
            ),

            // ── BODY ─────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
                              const SizedBox(height: 8),
                              Text('Erro ao carregar', style: TextStyle(color: Colors.grey[500])),
                              TextButton(onPressed: _carregar, child: const Text('Tentar novamente')),
                            ],
                          ),
                        )
                      : (_acoes.isEmpty && _fundos.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_outline, size: 56, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhum favorito ainda',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _carregar,
                              child: ListView(
                                padding: const EdgeInsets.all(15),
                                children: [
                                  if (_acoes.isNotEmpty) ...[
                                    _sectionLabel('Ações'),
                                    const SizedBox(height: 8),
                                    ..._acoes.map((a) => _itemCard(
                                          codigo: a['codigo'] ?? '',
                                          nome: a['nome'] ?? a['codigo'] ?? '',
                                          preco: a['price']?.toString() ?? '--',
                                          variacao: a['change']?.toString() ?? '--',
                                          onRemover: () => _removerAcao(a['codigo']),
                                        )),
                                  ],
                                  if (_fundos.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _sectionLabel('Fundos'),
                                    const SizedBox(height: 8),
                                    ..._fundos.map((f) => _itemCard(
                                          codigo: f['codigo'] ?? '',
                                          nome: f['nome'] ?? f['codigo'] ?? '',
                                          preco: f['price']?.toString() ?? '--',
                                          variacao: f['change']?.toString() ?? '--',
                                          onRemover: () => _removerFundo(f['codigo']),
                                        )),
                                  ],
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget _itemCard({
    required String codigo,
    required String nome,
    required String preco,
    required String variacao,
    required VoidCallback onRemover,
  }) {
    final positivo = variacao.startsWith('+');
    final cor = positivo ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);
    final corFundo = positivo ? const Color(0xFFE6F4ED) : const Color(0xFFFFEBEB);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6A5AE0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                codigo.length >= 2 ? codigo.substring(0, 2) : codigo,
                style: const TextStyle(
                  color: Color(0xFF6A5AE0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(codigo, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(nome, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(preco, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  variacao,
                  style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemover,
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
          ),
        ],
      ),
    );
  }
}