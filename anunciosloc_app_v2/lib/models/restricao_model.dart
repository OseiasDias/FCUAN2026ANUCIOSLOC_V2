class Restricao {
  final String tipo;
  final String chave;
  final String valor;

  Restricao({
    required this.tipo,
    required this.chave,
    required this.valor,
  });

  factory Restricao.fromJson(Map<String, dynamic> json) {
    return Restricao(
      tipo: json['tipo'],
      chave: json['chave'],
      valor: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'chave': chave,
      'valor': valor,
    };
  }

  bool get isWhitelist => tipo.toUpperCase() == 'WHITELIST';
  bool get isBlacklist => tipo.toUpperCase() == 'BLACKLIST';
}
