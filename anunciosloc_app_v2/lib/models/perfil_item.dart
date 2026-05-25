class PerfilItem {
  final String chave;
  final String valor;

  PerfilItem({
    required this.chave,
    required this.valor,
  });

  factory PerfilItem.fromJson(Map<String, dynamic> json) {
    return PerfilItem(
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

  @override
  String toString() => '$chave = $valor';
}
