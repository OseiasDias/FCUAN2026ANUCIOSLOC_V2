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
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _carregarInfraestruturas();
  }

  Future<void> _carregarInfraestruturas() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      // Obter localizacao
      final temPermissao = await LocalizacaoService.verificarPermissoes();

      if (temPermissao) {
        final localizacao = await LocalizacaoService.obterLocalizacaoAtual();
        setState(() {
          _centro = LatLng(localizacao.latitude, localizacao.longitude);
        });
        print("Centro definido: $_centro");
      } else {
        setState(() {
          _centro = const LatLng(-8.838333, 13.234444);
        });
        print("Sem permissao, usando centro padrao");
      }

      // Usar o metodo listarLocaisCoordenadas
      final locais = await ApiService.listarLocaisCoordenadas();
      print("Locais recebidos: ${locais.length}");

      setState(() {
        _infraestruturas = locais;
        _carregando = false;
        _adicionarMarkers();
      });
    } catch (e) {
      print("Erro ao carregar: $e");
      setState(() {
        _carregando = false;
        _erro = e.toString();
      });
    }
  }

  void _adicionarMarkers() {
    _markers.clear();
    print("Adicionando markers. Centro: $_centro");
    print("Infraestruturas: ${_infraestruturas.length}");

    if (_centro != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('minha_localizacao'),
          position: _centro!,
          infoWindow: const InfoWindow(title: 'Minha Localização'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var infra in _infraestruturas) {
      final lat = infra['latitude'] as double;
      final lng = infra['longitude'] as double;
      final nome = infra['nome'] as String;
      final capacidade = infra['capacidade'] as int;

      print("Adicionando marker: $nome em ($lat, $lng)");

      _markers.add(
        Marker(
          markerId: MarkerId(nome),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: nome,
            snippet: 'Capacidade: $capacidade utilizadores',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Forcar atualizacao do mapa
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _centro ?? const LatLng(-8.838333, 13.234444),
            zoom: Constantes.zoomPadrao,
          ),
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

    if (_erro.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Infraestruturas Próximas'),
          backgroundColor: Constantes.corPrincipal,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar: $_erro'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarInfraestruturas,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_centro == null) {
      return const Scaffold(
        body: Center(child: Text('Não foi possível obter localização')),
      );
    }

    if (_infraestruturas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Infraestruturas Próximas'),
          backgroundColor: Constantes.corPrincipal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Nenhuma infraestrutura encontrada'),
        ),
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
              target: _centro!,
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
