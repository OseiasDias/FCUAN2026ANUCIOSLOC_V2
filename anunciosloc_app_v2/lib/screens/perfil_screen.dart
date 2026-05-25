import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';
import '../models/perfil_item.dart';

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

  List<PerfilItem> _perfilItems = [];

  final TextEditingController _novaChaveController = TextEditingController();
  final TextEditingController _novoValorController = TextEditingController();
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
    _nomeController.text = _email.split('@').first;

    await _carregarPerfil();

    if (mounted) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _carregarPerfil() async {
    final perfil = await ApiService.obterPerfilUtilizador(_email);
    if (mounted) {
      setState(() {
        _perfilItems = perfil;
      });
    }
  }

  Future<void> _guardarAlteracoes() async {
    final sucesso = await ApiService.editarPerfil(
      email: _email,
      novoEmail: _emailController.text,
      novoNome: _nomeController.text,
    );

    if (sucesso && mounted) {
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar perfil")),
      );
    }
  }

  Future<void> _adicionarItemPerfil() async {
    if (_novaChaveController.text.isEmpty ||
        _novoValorController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Preencha chave e valor"),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    final sucesso = await ApiService.salvarPreferencia(
        _email, _novaChaveController.text, _novoValorController.text);

    if (sucesso && mounted) {
      _novaChaveController.clear();
      _novoValorController.clear();
      await _carregarPerfil();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Item adicionado ao perfil"),
            backgroundColor: Colors.green),
      );
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erro ao adicionar item"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removerItemPerfil(String chave) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover item'),
        content: Text('Remover "$chave" do seu perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final sucesso = await ApiService.removerPreferencia(_email, chave);
      if (sucesso && mounted) {
        await _carregarPerfil();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("$chave removido do perfil"),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _mostrarDialogAdicionarItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar ao Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _novaChaveController,
              decoration: const InputDecoration(
                labelText: 'Chave (ex: clube, profissao, idade)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _novoValorController,
              decoration: const InputDecoration(
                labelText: 'Valor (ex: Real Madrid, estudante, 25)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _adicionarItemPerfil,
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
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

                  // Dados pessoais
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dados Pessoais',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: "Nome",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _guardarAlteracoes,
                            icon: const Icon(Icons.save),
                            label: const Text("Guardar Alterações"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constantes.corPrincipal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Perfil do Utilizador (pares chave-valor)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Meu Perfil',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.green),
                                onPressed: _mostrarDialogAdicionarItem,
                                tooltip: 'Adicionar ao perfil',
                              ),
                            ],
                          ),
                          const Divider(),
                          const Text(
                            'Estes dados permitem que anunciantes direcionem mensagens especificas para si.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          if (_perfilItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  'Nenhum item no perfil\nToque no + para adicionar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _perfilItems.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = _perfilItems[index];
                                return ListTile(
                                  leading: const Icon(Icons.label,
                                      color: Colors.blue),
                                  title: Text(
                                    item.chave,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(item.valor),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removerItemPerfil(item.chave),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Exemplos: clube=Real Madrid, profissao=estudante, idade=25, cidade=Luanda',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informacoes da conta
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.vpn_key, color: Colors.orange),
                      title: const Text('Ticket ID'),
                      subtitle: Text(_ticketId),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on,
                          color: Colors.green),
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
