import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../services/localizacao_service.dart';
import '../utils/constantes.dart';

class LocaisScreen extends StatefulWidget {
  const LocaisScreen({super.key});

  @override
  State<LocaisScreen> createState() => _LocaisScreenState();
}

class _LocaisScreenState extends State<LocaisScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _centro;
  List<Map<String, dynamic>> _infraestruturas = [];
  bool _carregando = true;
  String _enderecoAtual = '';

  @override
  void initState() {
    super.initState();
    _carregarInfraestruturas();
  }

  Future<void> _carregarInfraestruturas() async {
    final temPermissao = await LocalizacaoService.verificarPermissoes();

    if (temPermissao) {
      final localizacao = await LocalizacaoService.obterLocalizacaoAtual();
      setState(() {
        _centro = LatLng(localizacao.latitude, localizacao.longitude);
        _enderecoAtual = localizacao.endereco ?? 'Sua localização';
      });
    } else {
      setState(() {
        _centro = const LatLng(-8.838333, 13.234444);
      });
    }

    final infra = await ApiService.listarInfraestruturas();
    setState(() {
      _infraestruturas = infra;
      _carregando = false;
      _adicionarMarkers();
    });
  }

  void _adicionarMarkers() {
    _markers.clear();

    if (_centro != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('minha_localizacao'),
          position: _centro!,
          infoWindow: InfoWindow(title: _enderecoAtual),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var infra in _infraestruturas) {
      final lat = infra['latitude'] as double;
      final lng = infra['longitude'] as double;

      _markers.add(
        Marker(
          markerId: MarkerId(infra['nome']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: infra['nome'],
            snippet: 'Capacidade: ${infra['capacidade']} utilizadores',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  void _moverParaLocalizacao() async {
    if (_mapController != null && _centro != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _centro!, zoom: Constantes.zoomPadrao),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraestruturas Próximas'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centro ?? const LatLng(-8.838333, 13.234444),
              zoom: Constantes.zoomPadrao,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _moverParaLocalizacao,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
