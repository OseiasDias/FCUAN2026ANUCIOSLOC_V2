class UsuarioModel {
  final String email;
  final String nome;
  final int saldo;
  final String? ticketId;

  UsuarioModel({
    required this.email,
    required this.nome,
    required this.saldo,
    this.ticketId,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        email: json['email'] ?? '',
        nome: json['nome'] ?? '',
        saldo: json['saldo'] ?? 0,
        ticketId: json['ticketId'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'nome': nome,
        'saldo': saldo,
        'ticketId': ticketId,
      };
}
