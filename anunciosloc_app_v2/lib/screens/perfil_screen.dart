import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _email = '';
  String _ticketId = '';
  int _saldo = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    _email = await Preferencias.getEmail();
    _ticketId = await Preferencias.getTicketId();
    _saldo = await ApiService.consultarSaldo(_email);
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('E-mail'),
                      subtitle: Text(_email),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: const Text('Ticket ID'),
                      subtitle: Text(_ticketId),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: const Text('Saldo'),
                      subtitle: Text('$_saldo pontos'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
