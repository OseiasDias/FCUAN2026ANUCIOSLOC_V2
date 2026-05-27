import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constantes.dart';
import '../utils/preferencias.dart';
import 'cadastro_local_screen.dart';
import 'meus_locais_screen.dart';

class LocaisScreen extends StatefulWidget {
  const LocaisScreen({super.key});

  @override
  State<LocaisScreen> createState() => _LocaisScreenState();
}

class _LocaisScreenState extends State<LocaisScreen> {
  List<Map<String, dynamic>> _locais = [];
  bool _carregando = true;
  String _erro = ''; // <-- ADICIONAR ESTA LINHA

  @override
  void initState() {
    super.initState();
    _carregarLocais();
  }

  Future<void> _carregarLocais() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final email = await Preferencias.getEmail();
      final locais = await ApiService.listarMeusLocais(email);
      setState(() {
        _locais = locais;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar locais: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraestruturas'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
        actions: [
          // Botao para gerir os meus locais
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeusLocaisScreen()),
              );
            },
            tooltip: 'Meus Locais',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarLocais,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_erro),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarLocais,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _locais.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhuma infraestrutura encontrada'),
                          SizedBox(height: 8),
                          Text('Toque no + para adicionar um local'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _locais.length,
                      itemBuilder: (context, index) {
                        final local = _locais[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Constantes.corPrincipal,
                              child: const Icon(Icons.location_city,
                                  color: Colors.white),
                            ),
                            title: Text(
                              local['nome'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Capacidade: ${local['capacidade']} utilizadores'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Coordenadas:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(
                                              'Latitude: ${local['latitude']}\nLongitude: ${local['longitude']}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.people,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                            '${local['capacidade']} utilizadores simultâneos'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroLocalScreen()),
          );
          if (result == true && mounted) {
            _carregarLocais();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Cadastrar Local',
      ),
    );
  }
}
