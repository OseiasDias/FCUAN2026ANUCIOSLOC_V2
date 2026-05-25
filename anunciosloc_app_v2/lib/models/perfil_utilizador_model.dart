class PerfilUtilizador {
  final String chave;
  final String valor;

  PerfilUtilizador({
    required this.chave,
    required this.valor,
  });

  factory PerfilUtilizador.fromJson(Map<String, dynamic> json) {
    return PerfilUtilizador(
      chave: json['chave'],
      valor: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chave': chave,
      'valor': valor,
    };
  }
}
