import 'dart:math'; // ← APENAS UMA VEZ

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';

class ReceberAnunciosScreen extends StatefulWidget {
  const ReceberAnunciosScreen({super.key});

  @override
  State<ReceberAnunciosScreen> createState() => _ReceberAnunciosScreenState();
}

class _ReceberAnunciosScreenState extends State<ReceberAnunciosScreen> {
  List<Map<String, dynamic>> _anuncios = [];
  bool _carregando = false;
  String? _localSelecionado;
  List<Map<String, dynamic>> _locaisDisponiveis = [];
  bool _carregandoLocais = true;
  String _mensagemStatus = '';

  bool _usandoLocalizacaoAutomatica = true;
  Position? _posicaoAtual;
  bool _obtendoLocalizacao = false;

  @override
  void initState() {
    super.initState();
    _carregarLocaisEDetectar();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ==================== CARREGAR LOCAIS E DETECTAR AUTOMATICAMENTE ====================

  // ==================== DETECÇÃO AUTOMÁTICA DE LOCALIZAÇÃO ====================
  Future<void> _carregarLocaisEDetectar() async {
    setState(() => _carregandoLocais = true);

    try {
      final locais = await ApiService.listarLocaisCoordenadas();

      final locaisUnicos = <String, Map<String, dynamic>>{};
      for (var local in locais) {
        final nome = local['nome'] as String;
        if (!locaisUnicos.containsKey(nome)) {
          locaisUnicos[nome] = local;
        }
      }

      final locaisLista = locaisUnicos.values.toList();

      setState(() {
        _locaisDisponiveis = locaisLista;
        _carregandoLocais = false;
        // SÓ definir _localSelecionado se houver locais
        if (locaisLista.isNotEmpty) {
          _localSelecionado = locaisLista[0]['nome'];
        } else {
          _localSelecionado =
              null; // ← IMPORTANTE: definir como null se não houver locais
        }
      });

      print("Locais disponiveis carregados: ${locaisLista.length}");

      if (locaisLista.isNotEmpty) {
        await _detectarLocalizacaoAutomatica();
      } else {
        setState(() {
          _mensagemStatus = 'Nenhum local cadastrado no sistema.';
          _carregandoLocais = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar locais: $e");
      setState(() => _carregandoLocais = false);
    }
  }

  Future<void> _detectarLocalizacaoAutomatica() async {
    setState(() {
      _obtendoLocalizacao = true;
      _mensagemStatus = 'Detectando sua localização...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _obtendoLocalizacao = false;
          _mensagemStatus =
              'Ative o GPS para detectar sua localização automaticamente.\nOu selecione um local manualmente.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _obtendoLocalizacao = false;
            _mensagemStatus =
                'Permissão de localização negada.\nSelecione um local manualmente.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _obtendoLocalizacao = false;
          _mensagemStatus =
              'Permissão de localização bloqueada permanentemente.\nSelecione um local manualmente.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _posicaoAtual = position;
        _obtendoLocalizacao = false;
      });

      print("Localização obtida: ${position.latitude}, ${position.longitude}");

      String? localEncontrado = _encontrarLocalMaisProximo(
        position.latitude,
        position.longitude,
      );

      if (localEncontrado != null) {
        setState(() {
          _localSelecionado = localEncontrado;
          _mensagemStatus = '';
          _usandoLocalizacaoAutomatica = true;
        });

        await _buscarAnuncios();
      } else {
        setState(() {
          _mensagemStatus =
              'Você não está em nenhum local cadastrado.\nSelecione um local manualmente.';
        });
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
      setState(() {
        _obtendoLocalizacao = false;
        _mensagemStatus =
            'Erro ao obter localização.\nSelecione um local manualmente.';
      });
    }
  }

  // ==================== ENCONTRAR LOCAL MAIS PRÓXIMO ====================

  String? _encontrarLocalMaisProximo(double lat, double lng) {
    double distanciaMinima = double.infinity;
    String? localMaisProximo;

    for (var local in _locaisDisponiveis) {
      double latLocal = local['latitude'] ?? 0;
      double lngLocal = local['longitude'] ?? 0;
      double raio = local['raio'] ?? 50.0;

      double distancia = _calcularDistancia(lat, lng, latLocal, lngLocal);

      print(
          "Distância para ${local['nome']}: ${distancia.toStringAsFixed(0)}m (raio: ${raio}m)");

      if (distancia <= raio && distancia < distanciaMinima) {
        distanciaMinima = distancia;
        localMaisProximo = local['nome'];
      }
    }

    if (localMaisProximo != null) {
      print(
          "Local detectado: $localMaisProximo (${distanciaMinima.toStringAsFixed(0)}m)");
    }

    return localMaisProximo;
  }

  // ==================== CALCULAR DISTÂNCIA (HAVERSINE) ====================

  double _calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    const double raioTerra = 6371000; // metros

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return raioTerra * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // ==================== BUSCAR ANÚNCIOS ====================

  Future<void> _buscarAnuncios() async {
    final local = _localSelecionado;

    if (local == null || local.isEmpty) {
      _mostrarMensagem('Selecione um local', isErro: true);
      return;
    }

    setState(() {
      _carregando = true;
      _anuncios = [];
      _mensagemStatus = '';
    });

    final email = await Preferencias.getEmail();

    try {
      final mensagens = await ApiService.receberAnunciosPorLocalizacao(
        email: email,
        latitude: _posicaoAtual!.latitude,
        longitude: _posicaoAtual!.longitude,
      );

      print("Mensagens recebidas: ${mensagens.length}");

      if (mensagens.isEmpty) {
        setState(() {
          _carregando = false;
          _mensagemStatus =
              'Nenhum anuncio encontrado em "$local".\nSeja o primeiro a publicar algo aqui!';
        });
      } else {
        setState(() {
          _carregando = false;
          _anuncios = mensagens
              .map((msg) => ({
                    'conteudo': msg,
                    'lido': false,
                    'data': DateTime.now(),
                  }))
              .toList();
        });
      }
    } catch (e) {
      print("Erro na busca: $e");
      setState(() {
        _carregando = false;
        _mensagemStatus =
            'Erro ao conectar ao servidor.\nVerifique sua conexão.';
      });
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

  void _marcarComoLido(int index) {
    setState(() {
      _anuncios[index]['lido'] = true;
    });
    _mostrarMensagem('Marcado como lido');
  }

  void _mostrarDetalhesAnuncio(Map<String, dynamic> anuncio, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Constantes.corPrincipal.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.announcement,
                      color: Constantes.corPrincipal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anúncio de outro utilizador',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Recebido agora',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              anuncio['conteudo'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _marcarComoLido(index);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Marcar como lido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anúncios de Outros'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _detectarLocalizacaoAutomatica,
            tooltip: 'Detectar localização',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              setState(() {
                _usandoLocalizacaoAutomatica = !_usandoLocalizacaoAutomatica;
                if (_usandoLocalizacaoAutomatica) {
                  _detectarLocalizacaoAutomatica();
                } else {
                  _mensagemStatus = 'Modo manual: selecione um local.';
                }
              });
            },
            tooltip: 'Alternar modo de localização',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constantes.corPrincipal,
                  Constantes.corPrincipal.withAlpha(204),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Anúncios de outros utilizadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_usandoLocalizacaoAutomatica &&
                        _localSelecionado != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Veja anúncios publicados por outros utilizadores neste local',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
                if (_localSelecionado != null &&
                    _usandoLocalizacaoAutomatica) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Local: $_localSelecionado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (!_usandoLocalizacaoAutomatica) ...[
                  _carregandoLocais
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Selecione um local'),
                                ),
                                value: _localSelecionado,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('Selecione um local'),
                                    ),
                                  ),
                                  ..._locaisDisponiveis.map((local) {
                                    return DropdownMenuItem<String>(
                                      value: local['nome'],
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          children: [
                                            Icon(
                                              local['tipo'] == 'GPS'
                                                  ? Icons.gps_fixed
                                                  : Icons.wifi,
                                              size: 18,
                                              color: local['tipo'] == 'GPS'
                                                  ? Colors.blue
                                                  : Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                local['nome'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _localSelecionado = value;
                                    _mensagemStatus = '';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                ],
                if (!_usandoLocalizacaoAutomatica)
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _carregando ? null : _buscarAnuncios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Constantes.corPrincipal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('BUSCAR ANÚNCIOS'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: _obtendoLocalizacao
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _mensagemStatus,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : _mensagemStatus.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _mensagemStatus,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/postar_anuncio');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Publicar Anúncio'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constantes.corPrincipal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _anuncios.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      _usandoLocalizacaoAutomatica
                                          ? 'Nenhum anúncio encontrado na sua localização.\nAproxime-se de um local com anúncios.'
                                          : 'Selecione um local para ver os anúncios',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _anuncios.length,
                                itemBuilder: (context, index) {
                                  final anuncio = _anuncios[index];
                                  final isLido = anuncio['lido'] == true;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Material(
                                      elevation: isLido ? 0 : 2,
                                      borderRadius: BorderRadius.circular(16),
                                      color: isLido
                                          ? Colors.grey[50]
                                          : Colors.white,
                                      child: InkWell(
                                        onTap: () => _mostrarDetalhesAnuncio(
                                            anuncio, index),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (!isLido)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin: const EdgeInsets.only(
                                                      top: 8, right: 12),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Constantes.corPrincipal
                                                      .withAlpha(25),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.announcement,
                                                  color: isLido
                                                      ? Colors.grey
                                                      : Constantes.corPrincipal,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      anuncio['conteudo'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: isLido
                                                            ? FontWeight.normal
                                                            : FontWeight.w500,
                                                        color: isLido
                                                            ? Colors.grey[600]
                                                            : Colors.black87,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .person_outline,
                                                            size: 12,
                                                            color: Colors
                                                                .grey[400]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'De outro utilizador',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey[400],
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
