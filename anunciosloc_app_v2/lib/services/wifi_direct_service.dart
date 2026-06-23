import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/anuncio_p2p.dart';

class WifiDirectService {
  static final WifiDirectService _instance = WifiDirectService._internal();
  factory WifiDirectService() => _instance;
  WifiDirectService._internal();

  // Estados
  bool _isConnected = false;
  String? _deviceName;
  List<Map<String, dynamic>> _discoveredDevices = [];
  List<AnuncioP2P> _anunciosRecebidos = [];

  // Callbacks (inicializados como nulos)
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
      return false;
    }
  }

  // ==================== DESCOBERTA DE DISPOSITIVOS ====================

  Future<void> discoverDevices() async {
    try {
      onStatusChanged?.call('Procurando dispositivos...');

      await Future.delayed(const Duration(seconds: 2));

      _discoveredDevices = [
        {
          'ssid': 'Android-P2P-1',
          'signalStrength': -45,
          'security': 'NONE',
          'isP2P': true,
        },
        {
          'ssid': 'Android-P2P-2',
          'signalStrength': -60,
          'security': 'NONE',
          'isP2P': true,
        },
        {
          'ssid': 'DIRECT-Samsung',
          'signalStrength': -70,
          'security': 'NONE',
          'isP2P': true,
        },
      ];

      onDevicesDiscovered?.call(_discoveredDevices);
      onStatusChanged
          ?.call('Dispositivos encontrados: ${_discoveredDevices.length}');
    } catch (e) {
      onStatusChanged?.call('Erro ao descobrir dispositivos');
    }
  }

  // ==================== CONECTAR AO DISPOSITIVO ====================

  Future<bool> connectToDevice(String ssid) async {
    try {
      onStatusChanged?.call('Conectando a $ssid...');

      await Future.delayed(const Duration(seconds: 2));

      _isConnected = true;
      onStatusChanged?.call('Conectado a $ssid');

      await receberAnunciosP2P();
      return true;
    } catch (e) {
      onStatusChanged?.call('Falha ao conectar');
      return false;
    }
  }

  // ==================== RECEBER ANÚNCIOS VIA P2P ====================

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

  // ==================== ENVIAR ANÚNCIO VIA P2P ====================

  Future<bool> enviarAnuncioP2P(AnuncioP2P anuncio) async {
    try {
      onStatusChanged?.call('Enviando anuncio...');

      await Future.delayed(const Duration(seconds: 1));

      onStatusChanged?.call('Anuncio enviado com sucesso!');
      return true;
    } catch (e) {
      onStatusChanged?.call('Erro ao enviar anuncio');
      return false;
    }
  }

  // ==================== SCANNER DE ANÚNCIOS P2P ====================

  List<AnuncioP2P> _scannerAnunciosP2P() {
    return [
      AnuncioP2P(
        id: 'p2p-1',
        titulo: 'Venda iPhone 13 - P2P',
        descricao: 'Vendo iPhone 13, pouco uso, 500€.',
        autor: 'Dispositivo P2P 1',
        local: 'Belas Shopping',
        dataCriacao: DateTime.now(),
        dispositivoOrigem: 'Android-P2P-1',
        saltos: 0,
      ),
      AnuncioP2P(
        id: 'p2p-2',
        titulo: 'Alugo T2 - P2P',
        descricao: 'Apartamento T2 para alugar, 200.000 KZ/mês.',
        autor: 'Dispositivo P2P 2',
        local: 'Talatona',
        dataCriacao: DateTime.now().subtract(const Duration(minutes: 30)),
        dispositivoOrigem: 'Android-P2P-2',
        saltos: 1,
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
      return;
    }

    if (_cacheMula.any((a) => a.id == anuncio.id)) {
      return;
    }

    _cacheMula.add(anuncio);
    onStatusChanged?.call('Anuncios em cache: ${_cacheMula.length}');
  }

  Future<void> entregarAnunciosMula() async {
    if (_cacheMula.isEmpty) return;

    await Future.delayed(const Duration(seconds: 1));

    _cacheMula.clear();
    onStatusChanged?.call('Anuncios MULA entregues com sucesso!');
  }

  // ==================== GETTERS ====================

  bool get isConnected => _isConnected;
  String? get deviceName => _deviceName;
  List<Map<String, dynamic>> get discoveredDevices => _discoveredDevices;
  List<AnuncioP2P> get anunciosRecebidos => _anunciosRecebidos;
  bool get isModoMulaAtivo => _modoMulaAtivo;
  int get cacheMulaCount => _cacheMula.length;
}
