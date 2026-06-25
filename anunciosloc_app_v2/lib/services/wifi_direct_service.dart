import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import '../models/anuncio_p2p.dart';

class WifiDirectService {
  static final WifiDirectService _instance = WifiDirectService._internal();
  factory WifiDirectService() => _instance;
  WifiDirectService._internal();

  bool _isConnected = false;
  String? _deviceName;
  List<Map<String, dynamic>> _discoveredDevices = [];
  List<AnuncioP2P> _anunciosRecebidos = [];
  List<AnuncioP2P> _cacheMula = [];
  bool _modoMulaAtivo = false;
  String? _groupIp;

  Function(List<Map<String, dynamic>>)? onDevicesDiscovered;
  Function(List<AnuncioP2P>)? onAnunciosRecebidos;
  Function(String)? onStatusChanged;

  // ==================== INICIALIZAÇÃO ====================

  Future<bool> init() async {
    try {
      _deviceName =
          'Dispositivo-${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      onStatusChanged?.call('WiFi Direct inicializado');
      return true;
    } catch (e) {
      onStatusChanged?.call('Erro ao inicializar: $e');
      return false;
    }
  }

  // ==================== ABRIR CONFIGURAÇÕES ====================

  void abrirConfiguracoesWifiDirect() {
    try {
      // Abre as configurações de WiFi do Android
      onStatusChanged?.call('Abra as configurações e ative o WiFi Direct');
    } catch (e) {
      onStatusChanged?.call('Erro ao abrir configurações: $e');
    }
  }

  // ==================== DESCOBRIR DISPOSITIVOS ====================

  Future<void> discoverDevices() async {
    try {
      onStatusChanged?.call('Procurando dispositivos...');
      _discoveredDevices = [];

      // Carregar lista de redes WiFi disponíveis
      final devices = await WiFiForIoTPlugin.loadWifiList();

      if (devices != null && devices.isNotEmpty) {
        _discoveredDevices = devices
            .map((d) => {
                  'ssid': d.ssid ?? 'Desconhecido',
                  'address': d.bssid ?? '',
                  'signalStrength': d.level ?? -50,
                  'isP2P': true,
                })
            .toList();
      }

      onDevicesDiscovered?.call(_discoveredDevices);
      onStatusChanged
          ?.call('${_discoveredDevices.length} dispositivos encontrados');
    } catch (e) {
      onStatusChanged?.call('Erro ao descobrir: $e');
      _discoveredDevices = [];
      onDevicesDiscovered?.call(_discoveredDevices);
    }
  }

  // ==================== CONECTAR ====================

  Future<bool> connectToDevice(String ssid) async {
    try {
      onStatusChanged?.call('Conectando a $ssid...');

      final result = await WiFiForIoTPlugin.connect(
        ssid,
        security: NetworkSecurity.NONE,
      );

      if (result) {
        _isConnected = true;
        _groupIp = await WiFiForIoTPlugin.getIP();
        onStatusChanged?.call('Conectado a $ssid (IP: $_groupIp)');
        return true;
      }

      onStatusChanged?.call('Falha ao conectar a $ssid');
      return false;
    } catch (e) {
      onStatusChanged?.call('Erro ao conectar: $e');
      return false;
    }
  }

  // ==================== ENVIAR ANÚNCIO ====================

  Future<bool> enviarAnuncioP2P(AnuncioP2P anuncio) async {
    if (!_isConnected || _groupIp == null) {
      onStatusChanged?.call('Não está conectado a nenhum dispositivo');
      return false;
    }

    try {
      onStatusChanged?.call('Enviando anúncio...');

      final url = 'http://$_groupIp:8080/anuncio';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(anuncio.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        onStatusChanged?.call('Anúncio enviado com sucesso');
        return true;
      }

      onStatusChanged?.call('Erro ao enviar: ${response.statusCode}');
      return false;
    } catch (e) {
      onStatusChanged?.call('Erro ao enviar anúncio: $e');
      return false;
    }
  }

  // ==================== RECEBER ANÚNCIOS ====================

  Future<void> receberAnunciosP2P() async {
    if (!_isConnected || _groupIp == null) {
      onStatusChanged?.call('Não está conectado a nenhum dispositivo');
      return;
    }

    try {
      onStatusChanged?.call('Recebendo anúncios...');

      final url = 'http://$_groupIp:8080/anuncios';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final anuncios = data.map((e) => AnuncioP2P.fromJson(e)).toList();
        _onAnunciosRecebidos(anuncios);
      } else {
        onStatusChanged?.call('Nenhum anúncio disponível');
      }
    } catch (e) {
      onStatusChanged?.call('Erro ao receber anúncios: $e');
    }
  }

  // ==================== MODO MULA ====================

  void ativarModoMula(bool ativar) {
    _modoMulaAtivo = ativar;
    onStatusChanged
        ?.call(ativar ? 'Modo MULA ativado' : 'Modo MULA desativado');
  }

  Future<void> armazenarAnuncioMula(AnuncioP2P anuncio) async {
    if (!_modoMulaAtivo) return;
    if (_cacheMula.length >= 10) {
      onStatusChanged?.call('Cache MULA cheio');
      return;
    }
    if (_cacheMula.any((a) => a.id == anuncio.id)) return;

    _cacheMula.add(anuncio);
    onStatusChanged?.call('Anúncios em cache: ${_cacheMula.length}');
  }

  Future<void> entregarAnunciosMula() async {
    if (_cacheMula.isEmpty) {
      onStatusChanged?.call('Nenhum anúncio em cache');
      return;
    }

    onStatusChanged?.call('Entregando ${_cacheMula.length} anúncios...');

    for (var anuncio in _cacheMula) {
      await enviarAnuncioP2P(anuncio);
    }

    _cacheMula.clear();
    onStatusChanged?.call('Anúncios MULA entregues');
  }

  // ==================== MÉTODOS INTERNOS ====================

  void _onAnunciosRecebidos(List<AnuncioP2P> anuncios) {
    if (anuncios.isNotEmpty) {
      _anunciosRecebidos.addAll(anuncios);
      onAnunciosRecebidos?.call(_anunciosRecebidos);
      onStatusChanged?.call('${anuncios.length} anúncios P2P recebidos');
    } else {
      onStatusChanged?.call('Nenhum anúncio P2P disponível');
    }
  }

  // ==================== GETTERS ====================

  bool get isConnected => _isConnected;
  String? get deviceName => _deviceName;
  List<Map<String, dynamic>> get discoveredDevices => _discoveredDevices;
  List<AnuncioP2P> get anunciosRecebidos => _anunciosRecebidos;
  bool get isModoMulaAtivo => _modoMulaAtivo;
  int get cacheMulaCount => _cacheMula.length;

  void disconnect() {
    _isConnected = false;
    _groupIp = null;
    _discoveredDevices = [];
    onStatusChanged?.call('Desconectado');
  }

  void clearData() {
    _anunciosRecebidos = [];
    _cacheMula = [];
    onStatusChanged?.call('Dados limpos');
  }
}
