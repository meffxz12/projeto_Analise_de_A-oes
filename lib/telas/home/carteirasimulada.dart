import 'package:flutter/material.dart';
import 'package:meu_apli/cores/coresglobais.dart';
import 'package:meu_apli/services/apiservice.dart';

class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  List<dynamic> _ativos = [];
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
      final data = await ApiService.buscarCarteiraAtualizada();
      setState(() { _ativos = data; _loading = false; });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  double get _totalCarteira {
    return _ativos.fold(0.0, (sum, a) {
      final preco = (a['preco_atual'] ?? a['preco'] ?? 0).toDouble();
      final qtd = (a['quantidade'] ?? 0).toDouble();
      return sum + (preco * qtd);
    });
  }

  Future<void> _remover(int itemId) async {
    try {
      await ApiService.removerAtivoCarteira(itemId);
      await _carregar();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover ativo')),
      );
    }
  }

  void _mostrarModalAdicionar() {
    final codigoCtrl = TextEditingController();
    final qtdCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar ativo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codigoCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Código (ex: PETR4)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: qtdCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final codigo = codigoCtrl.text.trim().toUpperCase();
                  final qtd = int.tryParse(qtdCtrl.text.trim()) ?? 0;
                  if (codigo.isEmpty || qtd <= 0) return;

                  Navigator.pop(ctx);
                  try {
                    await ApiService.adicionarAtivoCarteira(codigo, qtd);
                    await _carregar();
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao adicionar ativo')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Adicionar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                          Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Carteira Simulada',
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
                  const SizedBox(height: 20),
                  // ── SALDO ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patrimônio total',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'R\$ ${_totalCarteira.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_ativos.length} ativo${_ativos.length != 1 ? 's' : ''}',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── HEADER DA LISTA ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meus ativos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: _mostrarModalAdicionar,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6A5AE0),
                    ),
                  ),
                ],
              ),
            ),

            // ── LISTA ─────────────────────────────────────────
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
                      : _ativos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Carteira vazia',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toque em Adicionar para começar',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _carregar,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                itemCount: _ativos.length,
                                itemBuilder: (context, i) => _ativoCard(_ativos[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ativoCard(dynamic ativo) {
    final codigo = ativo['codigo']?.toString() ?? '';
    final nome = ativo['nome']?.toString() ?? codigo;
    final preco = (ativo['preco_atual'] ?? ativo['preco'] ?? 0).toDouble();
    final qtd = (ativo['quantidade'] ?? 0).toInt();
    final variacao = (ativo['variacao'] ?? ativo['change'] ?? 0).toDouble();
    final total = preco * qtd;
    final itemId = ativo['id'] as int?;

    final positivo = variacao >= 0;
    final cor = positivo ? const Color(0xFF1B8A5A) : const Color(0xFFCC2929);
    final corFundo = positivo ? const Color(0xFFE6F4ED) : const Color(0xFFFFEBEB);

    return Dismissible(
      key: Key(codigo + qtd.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        if (itemId != null) _remover(itemId);
      },
      child: Container(
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
                  Text(
                    '$qtd cotas · R\$ ${preco.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${positivo ? '+' : ''}${variacao.toStringAsFixed(2)}%',
                    style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}