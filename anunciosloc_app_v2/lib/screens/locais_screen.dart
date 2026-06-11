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
  String _erro = '';

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
      final locais = await ApiService.listarLocaisCoordenadas();
      setState(() {
        _locais = locais;
        _carregando = false;
      });
      
      print("Locais carregados: ${locais.length}");
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
      body: RefreshIndicator(
        onRefresh: _carregarLocais,
        child: _carregando
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('Nenhuma infraestrutura encontrada'),
                            const SizedBox(height: 8),
                            const Text(
                                'Toque no botão abaixo para adicionar um local'),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CadastroLocalScreen()),
                                );
                                if (result == true && mounted) {
                                  _carregarLocais();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Local'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constantes.corPrincipal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _locais.length,
                        itemBuilder: (context, index) {
                          final local = _locais[index];
                          final isGPS = local['tipo'] == 'GPS';
                          
                          return Card(
                            margin: const EdgeInsets.all(8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: isGPS ? Colors.blue : Colors.orange,
                                child: Icon(
                                  isGPS ? Icons.gps_fixed : Icons.wifi,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                local['nome'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                isGPS ? 'Localizacao GPS' : 'Rede WiFi',
                                style: TextStyle(color: isGPS ? Colors.blue : Colors.orange),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TIPO DE LOCAL
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isGPS ? Colors.blue.shade50 : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isGPS ? Icons.gps_fixed : Icons.wifi,
                                              size: 16,
                                              color: isGPS ? Colors.blue : Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isGPS ? 'Tipo: GPS' : 'Tipo: WiFi',
                                              style: TextStyle(
                                                color: isGPS ? Colors.blue : Colors.orange,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // COORDENADAS (apenas para GPS)
                                      if (isGPS) ...[
                                        const Text(
                                          'Coordenadas Geograficas',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Latitude: ${local['latitude']?.toStringAsFixed(6)}',
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Longitude: ${local['longitude']?.toStringAsFixed(6)}',
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        
                                        // RAIO
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.radio_button_checked, size: 16, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Raio de cobertura: ${local['raio']?.toStringAsFixed(0)} metros',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      
                                      // DADOS PARA WIFI
                                      if (!isGPS && local['wifiSsid'] != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.wifi, size: 16, color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'SSID: ${local['wifiSsid']}',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      
                                      // INFRAESTRUTURA
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.cloud_queue, size: 16, color: Colors.purple),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Infraestrutura: ${local['infraestrutura'] ?? 'Sem infraestrutura'}',
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // CRIADOR (se disponivel)
                                      if (local['criadorEmail'] != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.person, size: 14, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Criado por: ${local['criadorEmail']}',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: _locais.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CadastroLocalScreen()),
                );
                if (result == true && mounted) {
                  _carregarLocais();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Adicionar Local',
            )
          : null,
    );
  }
}