class AnuncioModel {
  final String id;
  final String conteudo;
  final String local;
  final DateTime data;

  AnuncioModel({
    required this.id,
    required this.conteudo,
    required this.local,
    required this.data,
  });

  factory AnuncioModel.fromSoap(String raw) {
    // exemplo:
    // [2026-05-15T20:48:30] titulo (local)

    try {
      final regex = RegExp(r'\[(.*?)\]\s*(.*?)\s*\((.*?)\)');
      final match = regex.firstMatch(raw);

      if (match == null) {
        return AnuncioModel(
          id: DateTime.now().toString(),
          conteudo: raw,
          local: '',
          data: DateTime.now(),
        );
      }

      final data = DateTime.parse(match.group(1)!);
      final conteudo = match.group(2)!;
      final local = match.group(3)!;

      return AnuncioModel(
        id: data.millisecondsSinceEpoch.toString(),
        conteudo: conteudo,
        local: local,
        data: data,
      );
    } catch (e) {
      return AnuncioModel(
        id: DateTime.now().toString(),
        conteudo: raw,
        local: '',
        data: DateTime.now(),
      );
    }
  }
}
