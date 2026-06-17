class AnuncioModel {
  final String id;
  final String titulo;
  final String conteudo;
  final String local;
  final DateTime data;
  final int totalVisualizacoes;
  final int totalEntregas;
  final bool activo;
  final bool isExpirado;
  final DateTime? dataExpiracao;

  AnuncioModel({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.local,
    required this.data,
    required this.totalVisualizacoes,
    required this.totalEntregas,
    required this.activo,
    required this.isExpirado,
    this.dataExpiracao,
  });

  factory AnuncioModel.fromSoap(String data) {
    try {
      // Formato: titulo|descricao|local|data|visualizacoes|entregas|ativo|expirado
      final partes = data.split('|');

      if (partes.length >= 8) {
        return AnuncioModel(
          id: '', // Será preenchido se disponível
          titulo: partes[0],
          conteudo: partes[1],
          local: partes[2],
          data: DateTime.parse(partes[3]),
          totalVisualizacoes: int.tryParse(partes[4]) ?? 0,
          totalEntregas: int.tryParse(partes[5]) ?? 0,
          activo: partes[6] == '1',
          isExpirado: partes[7] == '1',
        );
      }

      // Fallback para formato antigo
      return AnuncioModel(
        id: '',
        titulo: 'Anúncio',
        conteudo: data,
        local: 'Local desconhecido',
        data: DateTime.now(),
        totalVisualizacoes: 0,
        totalEntregas: 0,
        activo: true,
        isExpirado: false,
      );
    } catch (e) {
      print('Erro ao parsear anúncio: $e');
      return AnuncioModel(
        id: '',
        titulo: 'Erro ao carregar',
        conteudo: data,
        local: 'Local desconhecido',
        data: DateTime.now(),
        totalVisualizacoes: 0,
        totalEntregas: 0,
        activo: true,
        isExpirado: false,
      );
    }
  }

  // Para compatibilidade com código antigo
  String get descricao => conteudo;
}
