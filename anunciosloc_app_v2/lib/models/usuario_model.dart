class AnuncioModel {
  final DateTime data;
  final String titulo;
  final String local;

  AnuncioModel({
    required this.data,
    required this.titulo,
    required this.local,
  });

  factory AnuncioModel.fromRaw(String raw) {
    final regex = RegExp(r'\[(.*?)\]\s*(.*?)\s*\((.*?)\)');
    final match = regex.firstMatch(raw);

    if (match == null) {
      return AnuncioModel(
        data: DateTime.now(),
        titulo: raw,
        local: 'Desconhecido',
      );
    }

    return AnuncioModel(
      data: DateTime.parse(match.group(1)!),
      titulo: match.group(2)!,
      local: match.group(3)!,
    );
  }
}
