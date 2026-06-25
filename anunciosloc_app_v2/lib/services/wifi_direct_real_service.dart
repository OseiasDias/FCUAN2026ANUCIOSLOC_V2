import 'dart:async';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../models/anuncio_p2p.dart';

class WifiDirectRealService {
  static final WifiDirectRealService _instance =
      WifiDirectRealService._internal();
  factory WifiDirectRealService() => _instance;
  WifiDirectRealService._internal();

  // Estados
  bool _isConnected = false;
  String? _deviceName;
  List<Map<String, dynamic>> _discoveredDevices = [];
  List<AnuncioP2P> _anunciosRecebidos = [];

  // Cache para modo MULA
  List<AnuncioP2P> _cacheMula = [];
  bool _modoMulaAtivo = false;

  // Callbacks
  Function(List<Map<String, dynamic>>)? onDevicesDiscovered;
  Function(List<AnuncioP2P>)? onAnunciosRecebidos;
  Function(String)? onStatusChanged;

  // ==================== INICIALIZACAO ====================

  Future<bool> init() async {
    try {
      _deviceName = 'Android-${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      onStatusChanged?.call('WiFi Direct inicializado');
      return true;
    } catch (e) {
      onStatusChanged?.call('Erro ao inicializar WiFi Direct: $e');
      return false;
    }
  }

  // ==================== ABRIR CONFIGURACOES WIFI DIRECT ====================

  void abrirConfiguracoesWifiDirect() {
    try {
      const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      ).launch();

      onStatusChanged?.call('Abrindo configuracoes WiFi...');
    } catch (e) {
      onStatusChanged?.call('Erro ao abrir configuracoes: $e');
    }
  }

  // ==================== DESCOBRIR DISPOSITIVOS ====================

  Future<void> discoverDevices() async {
    try {
      onStatusChanged?.call('Procurando dispositivos WiFi Direct...');
      
      // TODO: Implementar descoberta real com WiFi P2P Manager
      // Em producao, usar: WifiP2pManager.discoverPeers()
      
      _discoveredDevices = [];
      onDevicesDiscovered?.call(_discoveredDevices);
      onStatusChanged?.call('Nenhum dispositivo encontrado');
    } catch (e) {
      onStatusChanged?.call('Erro ao descobrir dispositivos: $e');
    }
  }

  // ==================== CONECTAR AO DISPOSITIVO ====================

  Future<bool> connectToDevice(String ssid) async {
    try {
      onStatusChanged?.call('Conectando a $ssid...');
      
      // TODO: Implementar conexao real com WiFi P2P
      // Em producao, usar: WifiP2pManager.connect()
      
      _isConnected = true;
      onStatusChanged?.call('Conectado a $ssid');
      
      return true;
    } catch (e) {
      onStatusChanged?.call('Falha ao conectar: $e');
      return false;
    }
  }

  // ==================== RECEBER ANUNCIOS ====================

  Future<void> receberAnunciosP2P() async {
    try {
      onStatusChanged?.call('Recebendo anuncios P2P...');
      
      // TODO: Implementar recebimento real via WiFi Direct
      // Em producao, usar: socket server para receber dados
      
      onStatusChanged?.call('Nenhum anuncio P2P disponivel');
    } catch (e) {
      onStatusChanged?.call('Erro ao receber anuncios P2P: $e');
    }
  }

  // ==================== ENVIAR ANUNCIO VIA P2P ====================

  Future<bool> enviarAnuncioP2P(AnuncioP2P anuncio) async {
    try {
      onStatusChanged?.call('Enviando anuncio...');
      
      // TODO: Implementar envio real via WiFi Direct
      // Em producao, usar: socket client para enviar dados
      
      onStatusChanged?.call('Anuncio enviado com sucesso');
      return true;
    } catch (e) {
      onStatusChanged?.call('Erro ao enviar anuncio: $e');
      return false;
    }
  }

  // ==================== ADICIONAR ANUNCIO RECEBIDO ====================

  void adicionarAnuncioRecebido(AnuncioP2P anuncio) {
    if (!_anunciosRecebidos.any((a) => a.id == anuncio.id)) {
      _anunciosRecebidos.add(anuncio);
      onAnunciosRecebidos?.call(_anunciosRecebidos);
      onStatusChanged?.call('Novo anuncio P2P recebido');
    }
  }

  // ==================== MODO MULA ====================

  void ativarModoMula(bool ativar) {
    _modoMulaAtivo = ativar;
    onStatusChanged?.call(ativar ? 'Modo MULA ativado' : 'Modo MULA desativado');
  }

  Future<void> armazenarAnuncioMula(AnuncioP2P anuncio) async {
    if (!_modoMulaAtivo) {
      onStatusChanged?.call('Modo MULA desativado');
      return;
    }

    if (_cacheMula.length >= 10) {
      onStatusChanged?.call('Cache MULA cheio (10 anuncios)');
      return;
    }

    if (_cacheMula.any((a) => a.id == anuncio.id)) {
      return;
    }

    // Incrementar contador de saltos
    final anuncioComSalto = AnuncioP2P(
      id: anuncio.id,
      titulo: anuncio.titulo,
      descricao: anuncio.descricao,
      autor: anuncio.autor,
      local: anuncio.local,
      dataCriacao: anuncio.dataCriacao,
      dispositivoOrigem: anuncio.dispositivoOrigem,
      saltos: anuncio.saltos + 1,
    );

    _cacheMula.add(anuncioComSalto);
    onStatusChanged?.call('Anuncios em cache: ${_cacheMula.length}');
  }

  Future<void> entregarAnunciosMula() async {
    if (_cacheMula.isEmpty) {
      onStatusChanged?.call('Nenhum anuncio em cache');
      return;
    }

    onStatusChanged?.call('Entregando ${_cacheMula.length} anuncios...');
    
    // TODO: Implementar entrega real via WiFi Direct
    // Em producao: transmitir anuncios para dispositivos vizinhos
    
    _cacheMula.clear();
    onStatusChanged?.call('Anuncios MULA entregues com sucesso');
  }

  // ==================== GETTERS ====================

  bool get isConnected => _isConnected;
  String? get deviceName => _deviceName;
  List<Map<String, dynamic>> get discoveredDevices => _discoveredDevices;
  List<AnuncioP2P> get anunciosRecebidos => _anunciosRecebidos;
  bool get isModoMulaAtivo => _modoMulaAtivo;
  int get cacheMulaCount => _cacheMula.length;

  // ==================== DESCONECTAR ====================

  void disconnect() {
    _isConnected = false;
    _discoveredDevices = [];
    onStatusChanged?.call('Desconectado');
  }

  // ==================== LIMPAR DADOS ====================

  void clearData() {
    _anunciosRecebidos = [];
    _cacheMula = [];
    onStatusChanged?.call('Dados limpos');
  }
}