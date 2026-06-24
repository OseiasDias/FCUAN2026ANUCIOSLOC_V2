import 'dart:async';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../models/anuncio_p2p.dart';

class WifiDirectRealService {
  static final WifiDirectRealService _instance =
      WifiDirectRealService._internal();
  factory WifiDirectRealService() => _instance;
  WifiDirectRealService._internal();

  bool _isConnected = false;
  String? _deviceName;
  List<Map<String, dynamic>> _discoveredDevices = [];
  List<AnuncioP2P> _anunciosRecebidos = [];

  Function(List<Map<String, dynamic>>)? onDevicesDiscovered;
  Function(List<AnuncioP2P>)? onAnunciosRecebidos;
  Function(String)? onStatusChanged;

  // ==================== INICIALIZAÇÃO ====================

  Future<bool> init() async {
    try {
      _deviceName = 'Android-${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      onStatusChanged?.call('WiFi Direct inicializado');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ABRIR CONFIGURAÇÕES WIFI DIRECT ====================

  void abrirConfiguracoesWifiDirect() {
    try {
      // Abre as configurações nativas de WiFi Direct do Android
      const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      ).launch();

      onStatusChanged?.call('Abrindo configurações WiFi...');
    } catch (e) {
      onStatusChanged?.call('Erro ao abrir configurações: $e');
    }
  }

  // ==================== DESCOBRIR DISPOSITIVOS (SIMULADO) ====================

  Future<void> discoverDevices() async {
    try {
      onStatusChanged?.call('Procurando dispositivos WiFi Direct...');

      // Na implementação real, usaria WiFi P2P Manager
      // Por enquanto, simulamos com dispositivos de exemplo
      await Future.delayed(const Duration(seconds: 2));

      _discoveredDevices = [
        {
          'ssid': 'Android-P2P-Real-1',
          'signalStrength': -45,
          'security': 'NONE',
          'isP2P': true,
          'address': '02:00:00:00:00:01',
        },
        {
          'ssid': 'Android-P2P-Real-2',
          'signalStrength': -60,
          'security': 'NONE',
          'isP2P': true,
          'address': '02:00:00:00:00:02',
        },
      ];

      onDevicesDiscovered?.call(_discoveredDevices);
      onStatusChanged
          ?.call('Dispositivos encontrados: ${_discoveredDevices.length}');
    } catch (e) {
      onStatusChanged?.call('Erro ao descobrir dispositivos');
    }
  }

  // ==================== CONECTAR (SIMULADO) ====================

  Future<bool> connectToDevice(String ssid) async {
    try {
      onStatusChanged?.call('Conectando a $ssid...');

      // Simular conexão
      await Future.delayed(const Duration(seconds: 2));

      _isConnected = true;
      onStatusChanged?.call('Conectado a $ssid');

      // Receber anúncios simulados
      await receberAnunciosP2P();

      // Mostrar instrução para WiFi Direct real
      _mostrarInstrucaoWifiDirect();

      return true;
    } catch (e) {
      onStatusChanged?.call('Falha ao conectar');
      return false;
    }
  }

  // ==================== MOSTRAR INSTRUÇÃO ====================

  void _mostrarInstrucaoWifiDirect() {
    // Para WiFi Direct real, o utilizador precisa:
    // 1. Ativar WiFi Direct nas configurações
    // 2. Fazer pairing com o outro dispositivo
    // 3. A app deteta automaticamente
    onStatusChanged?.call(
        '📱 WiFi Direct: Para conexão real, ative o WiFi Direct nas configurações do Android.');
  }

  // ==================== RECEBER ANÚNCIOS ====================

  Future<void> receberAnunciosP2P() async {
    try {
      onStatusChanged?.call('Recebendo anuncios P2P...');

      await Future.delayed(const Duration(seconds: 1));

      final anuncios = _scannerAnunciosP2P();

      if (anuncios.isNotEmpty) {
        _anunciosRecebidos.addAll(anuncios);
        onAnunciosRecebidos?.call(_anunciosRecebidos);
        onStatusChanged?.call('${anuncios.length} anuncios P2P recebidos');
      } else {
        onStatusChanged?.call('Nenhum anuncio P2P disponivel');
      }
    } catch (e) {
      onStatusChanged?.call('Erro ao receber anuncios P2P');
    }
  }

  // ==================== SCANNER ====================

  List<AnuncioP2P> _scannerAnunciosP2P() {
    return [
      AnuncioP2P(
        id: 'p2p-real-1',
        titulo: 'Venda iPhone 13 - P2P Real',
        descricao: 'Vendo iPhone 13, pouco uso, 500€. Entrega em mãos.',
        autor: 'Dispositivo P2P Real',
        local: 'Belas Shopping',
        dataCriacao: DateTime.now(),
        dispositivoOrigem: 'Android-P2P-Real',
        saltos: 0,
      ),
      AnuncioP2P(
        id: 'p2p-real-2',
        titulo: 'Alugo T2 - P2P Real',
        descricao: 'Apartamento T2 para alugar, 200.000 KZ/mês.',
        autor: 'Dispositivo P2P Real 2',
        local: 'Talatona',
        dataCriacao: DateTime.now().subtract(const Duration(minutes: 30)),
        dispositivoOrigem: 'Android-P2P-Real-2',
        saltos: 0,
      ),
    ];
  }

  // ==================== MODO MULA ====================

  List<AnuncioP2P> _cacheMula = [];
  bool _modoMulaAtivo = false;

  void ativarModoMula(bool ativar) {
    _modoMulaAtivo = ativar;
    onStatusChanged
        ?.call(ativar ? 'Modo MULA ativado' : 'Modo MULA desativado');
  }

  Future<void> armazenarAnuncioMula(AnuncioP2P anuncio) async {
    if (!_modoMulaAtivo) return;

    if (_cacheMula.length >= 10) {
      onStatusChanged?.call('Cache MULA cheio!');
      return;
    }

    if (_cacheMula.any((a) => a.id == anuncio.id)) {
      return;
    }

    _cacheMula.add(anuncio);
    onStatusChanged?.call('Anuncios em cache: ${_cacheMula.length}');
  }

  Future<void> entregarAnunciosMula() async {
    if (_cacheMula.isEmpty) {
      onStatusChanged?.call('Nenhum anúncio em cache');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    _cacheMula.clear();
    onStatusChanged?.call('Anuncios MULA entregues!');
  }

  // ==================== GETTERS ====================

  bool get isConnected => _isConnected;
  String? get deviceName => _deviceName;
  List<Map<String, dynamic>> get discoveredDevices => _discoveredDevices;
  List<AnuncioP2P> get anunciosRecebidos => _anunciosRecebidos;
  bool get isModoMulaAtivo => _modoMulaAtivo;
  int get cacheMulaCount => _cacheMula.length;
}
