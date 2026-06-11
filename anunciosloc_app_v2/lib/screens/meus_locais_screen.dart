import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../services/api_service.dart';
import '../utils/constantes.dart';
import '../utils/preferencias.dart';
import 'cadastro_local_screen.dart';

class MeusLocaisScreen extends StatefulWidget {
  const MeusLocaisScreen({super.key});

  @override
  State<MeusLocaisScreen> createState() => _MeusLocaisScreenState();
}

class _MeusLocaisScreenState extends State<MeusLocaisScreen> {
  List<Map<String, dynamic>> _locais = [];
  bool _carregando = true;
  String _erro = '';

  Map<String, dynamic> _infraestrutura = {};
  bool _carregandoInfra = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await Future.wait([
      _carregarLocais(),
      _carregarInfraestrutura(),
    ]);
  }

  Future<void> _carregarLocais() async {
    try {
      final email = await Preferencias.getEmail();
      print("=== CARREGANDO MEUS LOCAIS ===");
      print("Email: $email");

      final locais = await ApiService.listarMeusLocais(email);

      setState(() {
        _locais = locais;
        _carregando = false;
      });

      print("Locais carregados: ${locais.length}");
    } catch (e) {
      print("Erro: $e");
      setState(() {
        _erro = 'Erro ao carregar locais: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _carregarInfraestrutura() async {
    try {
      final infra = await ApiService.obterInfoInfraestrutura();
      setState(() {
        _infraestrutura = infra;
        _carregandoInfra = false;
      });
    } catch (e) {
      print("Erro ao carregar infraestrutura: $e");
      setState(() {
        _carregandoInfra = false;
      });
    }
  }

  Future<void> _editarLocal(Map<String, dynamic> local) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarLocalScreen(local: local),
      ),
    );

    if (result == true) {
      _carregarLocais();
    }
  }

  Future<void> _eliminarLocal(Map<String, dynamic> local) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Local'),
        content: Text('Tem certeza que deseja eliminar "${local['nome']}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);

      final sucesso = await ApiService.eliminarLocal(local['id']);
      if (sucesso && mounted) {
        _mostrarMensagem('Local eliminado com sucesso!');
        _carregarLocais();
      } else if (mounted) {
        _mostrarMensagem('Erro ao eliminar local', isErro: true);
        setState(() => _carregando = false);
      }
    }
  }

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Locais'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroLocalScreen()),
              );
              if (result == true) {
                _carregarLocais();
              }
            },
            tooltip: 'Adicionar Local',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildInfraCard(),
              _carregando
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
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.location_off,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('Nenhum local cadastrado'),
                                    SizedBox(height: 8),
                                    Text('Toque no + para adicionar um local'),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _locais.length,
                              itemBuilder: (context, index) {
                                final local = _locais[index];
                                return _buildLocalCard(local);
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfraCard() {
    if (_carregandoInfra) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Constantes.corPrincipal,
            Constantes.corPrincipal.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Constantes.corPrincipal.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_queue,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Infraestrutura Atual',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      Text(
                        _infraestrutura['nome'] ?? 'Infraestrutura Central',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfraStat(
                  icon: Icons.people,
                  label: 'Capacidade',
                  value: '${_infraestrutura['capacidade'] ?? 100}',
                ),
                const SizedBox(width: 16),
                _buildInfraStat(
                  icon: Icons.trending_up,
                  label: 'Conectados',
                  value: '${_infraestrutura['conectados'] ?? 0}',
                ),
                const SizedBox(width: 16),
                _buildInfraStat(
                  icon: Icons.attach_money,
                  label: 'Premio',
                  value: '${_infraestrutura['premio'] ?? 2.0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfraStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalCard(Map<String, dynamic> local) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _editarLocal(local),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: local['tipo'] == 'GPS'
                          ? Colors.blue.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      local['tipo'] == 'GPS' ? Icons.gps_fixed : Icons.wifi,
                      size: 20,
                      color:
                          local['tipo'] == 'GPS' ? Colors.blue : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          local['nome'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          local['tipo'] == 'GPS'
                              ? 'Localizacao GPS'
                              : 'Rede WiFi',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarLocal(local),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarLocal(local),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              if (local['tipo'] == 'GPS') ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Lat: ${local['latitude']?.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Lng: ${local['longitude']?.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.radio_button_checked,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Raio: ${local['raio']} metros',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.wifi, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'SSID: ${local['wifiSsid'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TELA DE EDITAR LOCAL ====================

class EditarLocalScreen extends StatefulWidget {
  final Map<String, dynamic> local;

  const EditarLocalScreen({super.key, required this.local});

  @override
  State<EditarLocalScreen> createState() => _EditarLocalScreenState();
}

class _EditarLocalScreenState extends State<EditarLocalScreen> {
  late final TextEditingController _nomeController;
  late final TextEditingController _raioController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _wifiSsidController;
  late String _tipoLocal;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.local['nome']);
    _raioController = TextEditingController(
      text: widget.local['raio']?.toString() ?? '20',
    );
    _latitudeController = TextEditingController(
      text: widget.local['latitude']?.toString() ?? '0',
    );
    _longitudeController = TextEditingController(
      text: widget.local['longitude']?.toString() ?? '0',
    );
    _wifiSsidController = TextEditingController(
      text: widget.local['wifiSsid'] ?? '',
    );
    _tipoLocal = widget.local['tipo'] ?? 'GPS';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _raioController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _wifiSsidController.dispose();
    super.dispose();
  }

  Future<void> _salvarEdicao() async {
    if (_nomeController.text.trim().isEmpty) {
      _mostrarMensagem('Digite o nome do local', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    final sucesso = await ApiService.atualizarLocal(
      id: widget.local['id'],
      nome: _nomeController.text.trim(),
      tipo: _tipoLocal,
      latitude: double.tryParse(_latitudeController.text.trim()) ?? 0,
      longitude: double.tryParse(_longitudeController.text.trim()) ?? 0,
      raio: double.tryParse(_raioController.text.trim()) ?? 20,
      wifiSsid: _wifiSsidController.text.trim(),
    );

    setState(() => _carregando = false);

    if (sucesso && mounted) {
      _mostrarMensagem('Local atualizado com sucesso!');
      Navigator.pop(context, true);
    } else if (mounted) {
      _mostrarMensagem('Erro ao atualizar local', isErro: true);
    }
  }

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Local'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tipo de Localizacao',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'GPS', label: Text('GPS')),
                ButtonSegment(value: 'WIFI', label: Text('WiFi')),
              ],
              selected: {_tipoLocal},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _tipoLocal = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Local',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _raioController,
              decoration: const InputDecoration(
                labelText: 'Raio (metros)',
                prefixIcon: Icon(Icons.radio_button_checked),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_tipoLocal == 'GPS') ...[
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  prefixIcon: Icon(Icons.gps_fixed),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  prefixIcon: Icon(Icons.gps_fixed),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              TextField(
                controller: _wifiSsidController,
                decoration: const InputDecoration(
                  labelText: 'SSID da Rede WiFi',
                  prefixIcon: Icon(Icons.wifi),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _salvarEdicao,
              icon: _carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('SALVAR ALTERACOES'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constantes.corPrincipal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
