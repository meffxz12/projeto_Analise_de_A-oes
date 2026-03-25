class Stock {
  final String name;
  final String code;
  final String price;
  final String change;

  Stock({
    required this.name,
    required this.code,
    required this.price,
    required this.change,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      change: json['change']?.toString() ?? '',
    );
  }

  // 🔥 útil pra enviar dados depois (opcional)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'change': change,
    };
  }
}