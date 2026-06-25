/// Espelha o payload enviado pelo `notificar_favorito` do backend:
/// {
///   "event": "favorito_adicionado" | "favorito_removido",
///   "title": "⭐ Filme adicionado",
///   "message": "ABC123 foi adicionado aos seus favoritos.",
///   "codigo": "ABC123",
///   "tipo": "filme"
/// }
class NotificacaoModel {
  final String event;
  final String title;
  final String message;
  final String codigo;
  final String tipo;

  NotificacaoModel({
    required this.event,
    required this.title,
    required this.message,
    required this.codigo,
    required this.tipo,
  });

  factory NotificacaoModel.fromJson(Map<String, dynamic> json) {
    return NotificacaoModel(
      event: json['event'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'event': event,
        'title': title,
        'message': message,
        'codigo': codigo,
        'tipo': tipo,
      };

  bool get adicionado => event == 'favorito_adicionado';
  bool get removido => event == 'favorito_removido';
}