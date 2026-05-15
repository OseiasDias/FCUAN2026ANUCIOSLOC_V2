class AnuncioModel {
  final String id;
  final String conteudo;
  final String autorEmail;
  final String local;
  final DateTime dataCriacao;

  AnuncioModel({
    required this.id,
    required this.conteudo,
    required this.autorEmail,
    required this.local,
    required this.dataCriacao,
  });

  factory AnuncioModel.fromTexto(String texto) {
    return AnuncioModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conteudo: texto,
      autorEmail: '',
      local: '',
      dataCriacao: DateTime.now(),
    );
  }
}
