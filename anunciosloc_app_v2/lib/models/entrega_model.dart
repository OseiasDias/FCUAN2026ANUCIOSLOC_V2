import '../utils/constantes.dart';

class EntregaModel {
  final String id;
  final String anuncioId;
  final String conteudo;
  final String local;
  final String remetente;
  final String destinatario;
  final TipoEntrega tipo;
  final DateTime dataCriacao;
  final DateTime? dataEntrega;
  final String status; // PENDENTE, EM_TRANSITO, ENTREGUE, FALHOU

  EntregaModel({
    required this.id,
    required this.anuncioId,
    required this.conteudo,
    required this.local,
    required this.remetente,
    required this.destinatario,
    required this.tipo,
    required this.dataCriacao,
    this.dataEntrega,
    required this.status,
  });

  factory EntregaModel.fromMap(Map<String, dynamic> map) {
    return EntregaModel(
      id: map['id'],
      anuncioId: map['anuncioId'],
      conteudo: map['conteudo'],
      local: map['local'],
      remetente: map['remetente'],
      destinatario: map['destinatario'],
      tipo: map['tipo'] == 'CENTRALIZADA'
          ? TipoEntrega.centralizada
          : (map['tipo'] == 'WIFI_DIRECT'
              ? TipoEntrega.wifiDirect
              : TipoEntrega.mula),
      dataCriacao: DateTime.parse(map['dataCriacao']),
      dataEntrega: map['dataEntrega'] != null
          ? DateTime.parse(map['dataEntrega'])
          : null,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anuncioId': anuncioId,
      'conteudo': conteudo,
      'local': local,
      'remetente': remetente,
      'destinatario': destinatario,
      'tipo': tipo.apiValue,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'status': status,
    };
  }
}
