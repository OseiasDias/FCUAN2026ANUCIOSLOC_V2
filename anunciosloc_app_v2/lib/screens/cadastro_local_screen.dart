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
  String _enderecoSelecionado = '';

  @override
  void initState() {
    super.initState();
    _carregarLocalizacaoAtual();
  }

  Future<void> _carregarLocalizacaoAtual() async {
    try {
      final localizacao = await LocalizacaoService.obterLocalizacaoAtual();
      if (mounted) {
        setState(() {
          _selectedPosition =
              LatLng(localizacao.latitude, localizacao.longitude);
        });
        _moverCamera(_selectedPosition!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedPosition = const LatLng(-8.838333, 13.234444);
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
              '${p.street}, ${p.locality}, ${p.administrativeArea}';
        });
      }
    } catch (e) {
      print('Erro ao obter endereco: $e');
    }
  }

  Future<void> _salvarLocal() async {
    if (_nomeController.text.isEmpty) {
      _mostrarMensagem('Digite o nome do local', isErro: true);
      return;
    }

    if (_tipoLocal == 'GPS' && _selectedPosition == null) {
      _mostrarMensagem('Selecione um local no mapa', isErro: true);
      return;
    }

    if (_tipoLocal == 'WIFI' && _wifiSsid.isEmpty) {
      _mostrarMensagem('Digite o SSID da rede WiFi', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    final email = await Preferencias.getEmail();
    double raio = double.tryParse(_raioController.text) ?? 20;

    final sucesso = await ApiService.criarLocal(
      nome: _nomeController.text,
      tipo: _tipoLocal,
      latitude: _selectedPosition?.latitude ?? 0,
      longitude: _selectedPosition?.longitude ?? 0,
      raio: raio,
      wifiSsid: _wifiSsid,
      criadorEmail: email,
    );

    setState(() => _carregando = false);

    if (sucesso && mounted) {
      _mostrarMensagem('Local cadastrado com sucesso!');
      Navigator.pop(context, true);
    } else if (mounted) {
      _mostrarMensagem('Erro ao cadastrar local', isErro: true);
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
        title: const Text('Cadastrar Novo Local'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tipo de localizacao
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'GPS', label: Text('GPS (Coordenadas)')),
                  ButtonSegment(value: 'WIFI', label: Text('WiFi (SSID)')),
                ],
                selected: {_tipoLocal},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _tipoLocal = selection.first;
                  });
                },
              ),
            ),

            if (_tipoLocal == 'GPS') ...[
              // Mapa para GPS
              SizedBox(
                height: 300,
                child: _selectedPosition == null
                    ? const Center(child: CircularProgressIndicator())
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

              if (_enderecoSelecionado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _enderecoSelecionado,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],

            if (_tipoLocal == 'WIFI')
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: TextEditingController(text: _wifiSsid),
                  onChanged: (value) => _wifiSsid = value,
                  decoration: const InputDecoration(
                    labelText: 'SSID da Rede WiFi',
                    hintText: 'Ex: Free_WiFi_Shop',
                    prefixIcon: Icon(Icons.wifi),
                    border: OutlineInputBorder(),
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
                      labelText: 'Nome do Local',
                      hintText: 'Ex: Largo da Independência',
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
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (_tipoLocal == 'GPS' && _selectedPosition != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Coordenadas:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Qualquer utilizador pode cadastrar novos locais',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
