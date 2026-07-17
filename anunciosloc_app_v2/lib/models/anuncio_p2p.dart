class AnuncioP2P {
  final String id;
  final String titulo;
  final String descricao;
  final String autor;
  final String local;
  final DateTime dataCriacao;
  final String dispositivoOrigem;
  final int saltos;

  AnuncioP2P({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.local,
    required this.dataCriacao,
    required this.dispositivoOrigem,
    required this.saltos,
  });

  // PARA SQLITE

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "titulo": titulo,
      "descricao": descricao,
      "autor": autor,
      "local": local,
      "dataCriacao": dataCriacao.toIso8601String(),
      "dispositivoOrigem": dispositivoOrigem,
      "saltos": saltos
    };
  }

  factory AnuncioP2P.fromMap(Map<String, dynamic> map) {
    return AnuncioP2P(
      id: map["id"],
      titulo: map["titulo"],
      descricao: map["descricao"],
      autor: map["autor"],
      local: map["local"],
      dataCriacao: DateTime.parse(map["dataCriacao"]),
      dispositivoOrigem: map["dispositivoOrigem"],
      saltos: map["saltos"] ?? 0,
    );
  }

  // PARA WIFI DIRECT

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory AnuncioP2P.fromJson(Map<String, dynamic> json) {
    return AnuncioP2P.fromMap(json);
  }
}
