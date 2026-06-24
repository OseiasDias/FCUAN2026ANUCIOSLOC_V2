import 'package:flutter/material.dart';
import '../services/wifi_direct_service.dart';
import '../models/anuncio_p2p.dart';

class WifiDirectScreen extends StatefulWidget {
  const WifiDirectScreen({super.key});

  @override
  State<WifiDirectScreen> createState() => _WifiDirectScreenState();
}

class _WifiDirectScreenState extends State<WifiDirectScreen> {
  final WifiDirectService _wifiService = WifiDirectService();

  bool _carregando = false;
  String _status = 'Inicializando...';
  List<Map<String, dynamic>> _dispositivos = [];
  List<AnuncioP2P> _anuncios = [];
  bool _modoMula = false;

  @override
  void initState() {
    super.initState();
    _inicializar();

    _wifiService.onDevicesDiscovered = (devices) {
      setState(() {
        _dispositivos = devices;
        _carregando = false;
      });
    };

    _wifiService.onAnunciosRecebidos = (anuncios) {
      setState(() {
        _anuncios = anuncios;
      });
    };

    _wifiService.onStatusChanged = (status) {
      setState(() {
        _status = status;
      });
    };
  }

  Future<void> _inicializar() async {
    setState(() => _carregando = true);
    await _wifiService.init();
    await _wifiService.discoverDevices();
    setState(() => _carregando = false);
  }

  Future<void> _descobrirDispositivos() async {
    setState(() => _carregando = true);
    await _wifiService.discoverDevices();
    setState(() => _carregando = false);
  }

  Future<void> _conectar(String ssid) async {
    await _wifiService.connectToDevice(ssid);
  }

  void _ativarMula(bool ativar) {
    setState(() {
      _modoMula = ativar;
      _wifiService.ativarModoMula(ativar);
    });
  }

  void _mostrarDetalhesAnuncio(AnuncioP2P anuncio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(anuncio.titulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descricao: ${anuncio.descricao}'),
              const SizedBox(height: 8),
              Text('Autor: ${anuncio.autor}'),
              Text('Local: ${anuncio.local}'),
              Text('Data: ${anuncio.dataCriacao.toString().substring(0, 16)}'),
              if (anuncio.saltos > 0) Text('Saltos: ${anuncio.saltos}'),
              Text('Origem: ${anuncio.dispositivoOrigem}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Entregue via WiFi Direct (P2P)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _wifiService.armazenarAnuncioMula(anuncio);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar como MULA'),
          ),
        ],
      ),
    );
  }

  void _abrirConfiguracoesWifi() {
    _wifiService.abrirConfiguracoesWifiDirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Direct - P2P'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _descobrirDispositivos,
            tooltip: 'Procurar dispositivos',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _abrirConfiguracoesWifi,
            tooltip: 'Configuracoes WiFi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                Icon(
                  _wifiService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _wifiService.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_carregando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Modo MULA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Text('Modo MULA (Store-and-Forward)'),
                const Spacer(),
                Row(
                  children: [
                    if (_modoMula)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_wifiService.cacheMulaCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    Switch(
                      value: _modoMula,
                      onChanged: _ativarMula,
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Listas
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Dispositivos'),
                      Tab(text: 'Anuncios P2P'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: DISPOSITIVOS
                        _dispositivos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Nenhum dispositivo encontrado'),
                                    const SizedBox(height: 8),
                                    const Text(
                                        'Toque no botao de busca para procurar'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _descobrirDispositivos,
                                      child:
                                          const Text('Procurar dispositivos'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _dispositivos.length,
                                itemBuilder: (context, index) {
                                  final device = _dispositivos[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  device['ssid'] ??
                                                      'Dispositivo',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Sinal: ${device['signalStrength']} dBm',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: _wifiService
                                                      .isConnected
                                                  ? null
                                                  : () =>
                                                      _conectar(device['ssid']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _wifiService.isConnected
                                                        ? Colors.green
                                                        : Colors.deepPurple,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                _wifiService.isConnected
                                                    ? 'Conectado'
                                                    : 'Conectar',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                        // TAB 2: ANÚNCIOS P2P
                        _anuncios.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Nenhum anuncio P2P recebido'),
                                    const SizedBox(height: 8),
                                    const Text(
                                        'Conecte-se a um dispositivo para receber anuncios'),
                                    if (_wifiService.isConnected) ...[
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _wifiService.receberAnunciosP2P(),
                                        child: const Text('Verificar anuncios'),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _anuncios.length,
                                itemBuilder: (context, index) {
                                  final anuncio = _anuncios[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: anuncio.saltos > 0
                                                      ? Colors.orange.shade100
                                                      : Colors
                                                          .deepPurple.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  anuncio.saltos > 0
                                                      ? '📦'
                                                      : '📡',
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  anuncio.titulo,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.visibility),
                                                onPressed: () {
                                                  _mostrarDetalhesAnuncio(
                                                      anuncio);
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Autor: ${anuncio.autor}'),
                                          Text('Local: ${anuncio.local}'),
                                          if (anuncio.saltos > 0)
                                            Text('Saltos: ${anuncio.saltos}'),
                                          Text(
                                              'Data: ${anuncio.dataCriacao.toString().substring(0, 16)}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
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
