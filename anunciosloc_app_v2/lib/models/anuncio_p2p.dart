class AnuncioP2P {
  final String id;
  final String titulo;
  final String descricao;
  final String autor;
  final String local;
  final DateTime dataCriacao;
  final String dispositivoOrigem;
  final int saltos; // Para rastrear o número de saltos (MULA)

  AnuncioP2P({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.local,
    required this.dataCriacao,
    required this.dispositivoOrigem,
    this.saltos = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'autor': autor,
        'local': local,
        'dataCriacao': dataCriacao.toIso8601String(),
        'dispositivoOrigem': dispositivoOrigem,
        'saltos': saltos,
      };

  factory AnuncioP2P.fromJson(Map<String, dynamic> json) => AnuncioP2P(
        id: json['id'],
        titulo: json['titulo'],
        descricao: json['descricao'],
        autor: json['autor'],
        local: json['local'],
        dataCriacao: DateTime.parse(json['dataCriacao']),
        dispositivoOrigem: json['dispositivoOrigem'],
        saltos: json['saltos'] ?? 0,
      );
}
