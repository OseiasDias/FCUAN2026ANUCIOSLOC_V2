import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import '../services/localizacao_service.dart';
import '../utils/constantes.dart';
import '../utils/preferencias.dart';

class CadastroLocalScreen extends StatefulWidget {
  const CadastroLocalScreen({super.key});

  @override
  State<CadastroLocalScreen> createState() => _CadastroLocalScreenState();
}

class _CadastroLocalScreenState extends State<CadastroLocalScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  final Set<Marker> _markers = {};

  final _nomeController = TextEditingController();
  final _raioController = TextEditingController();
  String _tipoLocal = 'GPS';
  String _wifiSsid = '';

  bool _carregando = false;
  bool _carregandoMapa = true;
  String _enderecoSelecionado = '';
  String _erroLocalizacao = '';

  // Lista de locais do utilizador
  List<Map<String, dynamic>> _meusLocais = [];
  bool _carregandoLocais = true;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacaoAtual();
    _carregarMeusLocais();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _raioController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _carregarMeusLocais() async {
    try {
      final email = await Preferencias.getEmail();

      if (email.isEmpty) {
        print("Email nao encontrado nas preferencias");
        setState(() {
          _carregandoLocais = false;
        });
        return;
      }

      print("Carregando locais para: $email");
      final locais = await ApiService.listarMeusLocais(email);

      setState(() {
        _meusLocais = locais;
        _carregandoLocais = false;
      });

      print("Locais carregados: ${locais.length}");
    } catch (e) {
      print("Erro ao carregar locais: $e");
      setState(() {
        _meusLocais = [];
        _carregandoLocais = false;
      });
    }
  }

  Future<void> _carregarLocalizacaoAtual() async {
    setState(() {
      _carregandoMapa = true;
      _erroLocalizacao = '';
    });

    try {
      final temPermissao = await LocalizacaoService.verificarPermissoes();

      if (!temPermissao) {
        setState(() {
          _erroLocalizacao = 'Permissão de localização negada';
          _selectedPosition = const LatLng(-8.838333, 13.234444);
          _carregandoMapa = false;
        });
        return;
      }

      final localizacao = await LocalizacaoService.obterLocalizacaoAtual();
      if (mounted) {
        setState(() {
          _selectedPosition =
              LatLng(localizacao.latitude, localizacao.longitude);
          _carregandoMapa = false;
        });
        _moverCamera(_selectedPosition!);
      }
    } catch (e) {
      print('Erro ao carregar localizacao: $e');
      if (mounted) {
        setState(() {
          _erroLocalizacao = 'Erro ao obter localização. Usando local padrão.';
          _selectedPosition = const LatLng(-8.838333, 13.234444);
          _carregandoMapa = false;
        });
      }
    }
  }

  void _moverCamera(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15),
        ),
      );
    }
  }

  Future<void> _onMapTapped(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: const InfoWindow(title: 'Local Selecionado'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      _enderecoSelecionado = '';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        setState(() {
          _enderecoSelecionado =
              '${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}';
        });
      }
    } catch (e) {
      print('Erro ao obter endereco: $e');
    }
  }

  Future<void> _salvarLocal() async {
    if (_nomeController.text.trim().isEmpty) {
      _mostrarMensagem('Digite o nome do local', isErro: true);
      return;
    }

    if (_tipoLocal == 'GPS' && _selectedPosition == null) {
      _mostrarMensagem('Selecione um local no mapa', isErro: true);
      return;
    }

    if (_tipoLocal == 'WIFI' && _wifiSsid.trim().isEmpty) {
      _mostrarMensagem('Digite o SSID da rede WiFi', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    final email = await Preferencias.getEmail();
    double raio = double.tryParse(_raioController.text.trim()) ?? 20;

    final sucesso = await ApiService.criarLocal(
      nome: _nomeController.text.trim(),
      tipo: _tipoLocal,
      latitude: _selectedPosition?.latitude ?? 0,
      longitude: _selectedPosition?.longitude ?? 0,
      raio: raio,
      wifiSsid: _wifiSsid.trim(),
      criadorEmail: email,
    );

    setState(() => _carregando = false);

    if (sucesso && mounted) {
      _mostrarMensagem('Local cadastrado com sucesso!');
      _nomeController.clear();
      _raioController.clear();
      _wifiSsid = '';
      _selectedPosition = null;
      _markers.clear();
      await _carregarMeusLocais();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Local cadastrado com sucesso!'),
            backgroundColor: Colors.green),
      );
    } else if (mounted) {
      _mostrarMensagem('Erro ao cadastrar local. Verifique o servidor.',
          isErro: true);
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
      final sucesso = await ApiService.eliminarLocal(local['id']);
      if (sucesso && mounted) {
        await _carregarMeusLocais();
        _mostrarMensagem('Local eliminado com sucesso!');
      } else if (mounted) {
        _mostrarMensagem('Erro ao eliminar local', isErro: true);
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
        title: const Text('Gestão de Locais'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card da infraestrutura
            _buildInfraCard(),

            const SizedBox(height: 16),

            // Lista de locais existentes
            _buildListaLocais(),

            const SizedBox(height: 16),

            // Separador
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(thickness: 2),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cadastrar Novo Local',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Tipo de localizacao
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Tipo de Localização',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'GPS', label: Text('GPS (Mapa)')),
                      ButtonSegment(value: 'WIFI', label: Text('WiFi (SSID)')),
                    ],
                    selected: {_tipoLocal},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _tipoLocal = selection.first;
                      });
                    },
                  ),
                ],
              ),
            ),

            if (_tipoLocal == 'GPS') ...[
              Container(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _carregandoMapa
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedPosition == null
                          ? const Center(child: Text('A carregar mapa...'))
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _selectedPosition!,
                                zoom: 14,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              onTap: _onMapTapped,
                              markers: _markers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
                            ),
                ),
              ),
              if (_erroLocalizacao.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _erroLocalizacao,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_enderecoSelecionado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _enderecoSelecionado,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            if (_tipoLocal == 'WIFI')
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => _wifiSsid = value,
                  decoration: const InputDecoration(
                    labelText: 'SSID da Rede WiFi',
                    hintText: 'Ex: Free_WiFi_Shop, Rede_Do_Shop',
                    prefixIcon: Icon(Icons.wifi),
                    border: OutlineInputBorder(),
                    helperText: 'Nome da rede WiFi que identifica o local',
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Local *',
                      hintText: 'Ex: Largo da Independência, Belas Shopping',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _raioController,
                    decoration: const InputDecoration(
                      labelText: 'Raio (metros)',
                      hintText: 'Ex: 20',
                      prefixIcon: Icon(Icons.radio_button_checked),
                      border: OutlineInputBorder(),
                      helperText: 'Apenas para localização GPS',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (_tipoLocal == 'GPS' && _selectedPosition != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.gps_fixed,
                                  size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Coordenadas Selecionadas:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Latitude: ${_selectedPosition!.latitude.toStringAsFixed(6)}'),
                          Text(
                              'Longitude: ${_selectedPosition!.longitude.toStringAsFixed(6)}'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _carregando ? null : _salvarLocal,
                    icon: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('CADASTRAR LOCAL'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfraCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Constantes.corPrincipal,
            Constantes.corPrincipal.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Constantes.corPrincipal.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Infraestrutura',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.cloud_queue, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Infraestrutura Central',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaLocais() {
    if (_carregandoLocais) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _meusLocais.length,
          itemBuilder: (context, index) {
            final local = _meusLocais[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  local['tipo'] == 'GPS' ? Icons.gps_fixed : Icons.wifi,
                  color: local['tipo'] == 'GPS' ? Colors.blue : Colors.orange,
                ),
                title: Text(
                  local['nome'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  local['tipo'] == 'GPS'
                      ? 'Lat: ${local['latitude']?.toStringAsFixed(4)}, Lng: ${local['longitude']?.toStringAsFixed(4)}'
                      : 'SSID: ${local['wifiSsid'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarLocal(local),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
