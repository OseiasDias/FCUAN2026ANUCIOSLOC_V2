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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    _email = await Preferencias.getEmail();
    _ticketId = await Preferencias.getTicketId();
    _saldo = await ApiService.consultarSaldo(_email);

    _emailController.text = _email;
    _nomeController.text = _email.split('@')[0]; // fallback simples

    setState(() => _carregando = false);
  }

  Future<void> _guardarAlteracoes() async {
    final sucesso = await ApiService.editarPerfil(
      email: _email,
      novoEmail: _emailController.text,
      novoNome: _nomeController.text,
    );

    if (sucesso) {
      await Preferencias.salvarUsuario(
        email: _emailController.text,
        ticketId: _ticketId,
        nome: _nomeController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso")),
      );

      setState(() {
        _email = _emailController.text;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar perfil")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),

                  const SizedBox(height: 20),

                  // EMAIL EDITÁVEL
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // NOME EDITÁVEL
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _guardarAlteracoes,
                    child: const Text("Guardar Alterações"),
                  ),
                ],
              ),
            ),
    );
  }
}
