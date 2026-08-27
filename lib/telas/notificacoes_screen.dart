import 'package:flutter/material.dart';
import 'package:meu_apli/services/apiservice.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  List<dynamic> _notificacoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  // ============================================================
  // CARREGAR NOTIFICAÇÕES
  // ============================================================

  Future<void> _carregarNotificacoes() async {
    try {
      final notificacoes = await ApiService.listarNotificacoes();

      if (!mounted) return;

      setState(() {
        _notificacoes = notificacoes;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar notificações: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // MARCAR COMO LIDA
  // ============================================================

  Future<void> _marcarComoLida(
    int index,
  ) async {
    final notificacao = _notificacoes[index];

    final bool lida = notificacao['lida'] == true;

    // Se já estiver lida, não precisa fazer nada
    if (lida) return;

    final int id = notificacao['id'];

    try {
      await ApiService.marcarNotificacaoComoLida(id);

      if (!mounted) return;

      setState(() {
        _notificacoes[index]['lida'] = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao marcar notificação como lida: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificações',
        ),
      ),

      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : _notificacoes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma notificação ainda.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )

              : RefreshIndicator(
                  onRefresh: _carregarNotificacoes,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),

                    itemCount: _notificacoes.length,

                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final notificacao =
                          _notificacoes[index];

                      final bool lida =
                          notificacao['lida'] == true;

                      final String titulo =
                          notificacao['titulo'] ?? '';

                      final String mensagem =
                          notificacao['mensagem'] ?? '';

                      final String tipo =
                          notificacao['tipo'] ?? 'SISTEMA';

                      return GestureDetector(
                        onTap: () {
                          _marcarComoLida(index);
                        },

                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),

                          decoration: BoxDecoration(
                            // 🔵 NÃO LIDA
                            color: lida
                                ? Colors.white
                                : const Color(
                                    0xFFEAF2FF,
                                  ),

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),

                            border: Border.all(
                              color: lida
                                  ? Colors.grey.shade200
                                  : const Color(
                                      0xFFBBD3FF,
                                    ),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),

                                blurRadius: 5,

                                offset: const Offset(
                                  0,
                                  2,
                                ),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              14,
                            ),

                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                // ==================================================
                                // BOLINHA DE STATUS
                                // ==================================================

                                Container(
                                  margin:
                                      const EdgeInsets.only(
                                    top: 5,
                                    right: 12,
                                  ),

                                  width: 10,

                                  height: 10,

                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,

                                    color: lida
                                        ? Colors.grey
                                        : const Color(
                                            0xFF2979FF,
                                          ),
                                  ),
                                ),

                                // ==================================================
                                // ÍCONE
                                // ==================================================

                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                    10,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: lida
                                        ? Colors.grey
                                            .shade200
                                        : const Color(
                                            0xFFDCE9FF,
                                          ),

                                    shape:
                                        BoxShape.circle,
                                  ),

                                  child: Icon(
                                    _iconePorTipo(tipo),

                                    color: lida
                                        ? Colors.grey
                                        : const Color(
                                            0xFF2979FF,
                                          ),

                                    size: 22,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                // ==================================================
                                // TEXTO
                                // ==================================================

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Text(
                                        titulo,

                                        style: TextStyle(
                                          fontSize: 16,

                                          fontWeight: lida
                                              ? FontWeight
                                                  .normal
                                              : FontWeight
                                                  .bold,

                                          color: lida
                                              ? Colors.black87
                                              : Colors.black,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Text(
                                        mensagem,

                                        style: TextStyle(
                                          fontSize: 14,

                                          color: lida
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Text(
                                        tipo,

                                        style: TextStyle(
                                          fontSize: 11,

                                          fontWeight:
                                              FontWeight.w600,

                                          color: lida
                                              ? Colors.grey
                                              : const Color(
                                                  0xFF2979FF,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // ============================================================
  // ÍCONE DE ACORDO COM O TIPO
  // ============================================================

  IconData _iconePorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'MERCADO':
        return Icons.trending_up_rounded;

      case 'CARTEIRA':
        return Icons.account_balance_wallet_rounded;

      case 'ACAO':
      case 'AÇÃO':
        return Icons.show_chart_rounded;

      case 'FUNDO':
        return Icons.pie_chart_rounded;

      case 'EDUCACAO':
      case 'EDUCAÇÃO':
        return Icons.school_rounded;

      case 'SISTEMA':
      default:
        return Icons.notifications_rounded;
    }
  }
}