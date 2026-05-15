class AnuncioModel {
  final String id;
  final String conteudo;
  final String autorEmail;
  final String local;
  final DateTime data;

  AnuncioModel({
    required this.id,
    required this.conteudo,
    required this.autorEmail,
    required this.local,
    required this.data,
  });

  factory AnuncioModel.fromSoap(String raw) {
    // formato esperado:
    // [2026-05-15T20:48:30] titulo (local)

    final regex = RegExp(r'\[(.*?)\]\s*(.*?)\s*\((.*?)\)');
    final match = regex.firstMatch(raw);

    if (match != null) {
      return AnuncioModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        data: DateTime.tryParse(match.group(1)!) ?? DateTime.now(),
        conteudo: match.group(2) ?? '',
        local: match.group(3) ?? '',
        autorEmail: '',
      );
    }

    return AnuncioModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: DateTime.now(),
      conteudo: raw,
      local: '',
      autorEmail: '',
    );
  }
}
