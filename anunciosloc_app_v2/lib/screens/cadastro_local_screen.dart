import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final _capacidadeController = TextEditingController();
  bool _carregando = false;

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

  void _onMapTapped(LatLng position) {
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
    });
  }

  Future<void> _salvarLocal() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Digite o nome da infraestrutura'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione um local no mapa'),
            backgroundColor: Colors.red),
      );
      return;
    }

    int capacidade = int.tryParse(_capacidadeController.text) ?? 100;

    setState(() => _carregando = true);

    final sucesso = await ApiService.criarInfraestrutura(
      nome: _nomeController.text,
      latitude: _selectedPosition!.latitude,
      longitude: _selectedPosition!.longitude,
      capacidade: capacidade,
      criadorEmail: await Preferencias.getEmail(),
    );

    if (mounted) {
      setState(() => _carregando = false);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Infraestrutura cadastrada com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao cadastrar infraestrutura'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Infraestrutura'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: _selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mapa
                Expanded(
                  flex: 2,
                  child: GoogleMap(
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

                // Formulario
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da Infraestrutura',
                            hintText: 'Ex: Belas Shopping',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _capacidadeController,
                          decoration: const InputDecoration(
                            labelText: 'Capacidade (utilizadores)',
                            hintText: 'Ex: 100',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Coordenadas selecionadas:'),
                                    Text(
                                      _selectedPosition != null
                                          ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                                              'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}'
                                          : 'Toque no mapa para selecionar',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _carregando ? null : _salvarLocal,
                          icon: _carregando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save),
                          label: const Text('CADASTRAR INFRAESTRUTURA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constantes.corPrincipal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
