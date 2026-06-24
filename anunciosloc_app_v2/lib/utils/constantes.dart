import 'package:flutter/material.dart';

class Constantes {
  // ==================== URLs DOS SERVIDORES ====================
  static const String ipServidor = '10.100.183.128';
  //static const String ipServidor = '192.168.8.119';
  //static const String ipServidor = 'localhost';

  // Para emulador Android usar: 10.0.2.2
  // static const String ipServidor = '10.0.2.2';
  static const String portaApi = '8082';
  static const String portaAuth = '8085';
  static const String portaInfra = '8081';
  static const String portaUddi = '8090';

  static const String urlBase = 'http://$ipServidor:$portaApi';
  static const String urlAutenticacao = 'http://$ipServidor:$portaAuth/auth';
  static const String urlApi = '$urlBase/ws/anunciosloc';
  static const String urlInfra = 'http://$ipServidor:$portaInfra/infra';
  static const String urlUddi = 'http://$ipServidor:$portaUddi/uddi';

  // ==================== SOAP NAMESPACES ====================
  static const String namespace = 'http://service.server.anunciosloc.pt/';
  static const String namespaceAuth = 'http://service.auth.anunciosloc.pt/';
  static const String namespaceInfra = 'http://service.infra.anunciosloc.pt/';

  // ==================== TIMEOUT ====================
  static const int tempoEspera = 30;

  // ==================== SHARED PREFERENCES ====================
  static const String chaveEmail = 'email';
  static const String chaveTicket = 'ticket_id';
  static const String chaveLogado = 'logado';
  static const String chaveNome = 'nome';
  static const String chaveUltimaLocalizacao = 'ultima_localizacao';
  static const String chaveConfigEntrega = 'config_entrega';

  // ==================== CORES ====================
  static const Color corPrincipal = Color(0xFF6200EE);
  static const Color corSecundaria = Color(0xFF03DAC5);
  static const Color corFundo = Color(0xFFF5F5F5);
  static const Color corErro = Color(0xFFB00020);
  static const Color corSucesso = Color(0xFF4CAF50);
  static const Color corAviso = Color(0xFFFF9800);
  static const Color corInfo = Color(0xFF2196F3);

  // ==================== TEXTOS ====================
  static const String nomeApp = 'AnunciosLoc';
  static const String descricaoApp = 'Sistema de Anúncios por Localização';
  static const String sucessoLogin = 'Login realizado com sucesso!';
  static const String sucessoCadastro = 'Conta criada com sucesso!';
  static const String sucessoAnuncio = 'Anúncio publicado com sucesso!';
  static const String erroConexao = 'Erro de conexão com o servidor';
  static const String erroCredenciais = 'E-mail ou senha inválidos';
  static const String erroSaldoInsuficiente =
      'Saldo insuficiente para publicar anúncio';
  static const String erroLimiteAnuncios =
      'Aguarde 5 minutos para publicar outro anúncio';

  // ==================== TIPOS DE ENTREGA ====================
  static const String entregaCentralizada = 'CENTRALIZADA';
  static const String entregaWifiDirect = 'WIFI_DIRECT';
  static const String entregaMula = 'MULA';

  static const Map<String, String> descricaoEntrega = {
    entregaCentralizada: 'Entrega via servidor central',
    entregaWifiDirect: 'Entrega peer-to-peer via WiFi Direct',
    entregaMula: 'Entrega offline com cache local (Store and Forward)',
  };

  // ==================== STATUS ====================
  static const String statusPendente = 'PENDENTE';
  static const String statusEmTransito = 'EM_TRANSITO';
  static const String statusEntregue = 'ENTREGUE';
  static const String statusFalhou = 'FALHOU';

  // ==================== CONFIGURACOES DE MAPA ====================
  static const double zoomPadrao = 13.0;
  static const double zoomMaximo = 18.0;
  static const double raioBuscaPadrao = 5000.0; // 5km

  // ==================== CONFIGURACOES DE CACHE ====================
  static const int cacheExpirationHoras = 24;
  static const int maxMensagensCache = 100;

  // ==================== CONSTANTES DE NEGOCIO ====================
  static const double custoAnuncio = 5.0;
  static const double saldoInicial = 10.0;
  static const int intervaloMinimoAnunciosMinutos = 5;
  static const int duracaoTicketSegundos = 3600; // 1 hora

  // ==================== METODOS AUXILIARES ====================
  static String getStatusIcon(String status) {
    switch (status) {
      case statusPendente:
        return '⏳';
      case statusEmTransito:
        return '🚚';
      case statusEntregue:
        return '✅';
      case statusFalhou:
        return '❌';
      default:
        return '📦';
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case statusPendente:
        return corAviso;
      case statusEmTransito:
        return corInfo;
      case statusEntregue:
        return corSucesso;
      case statusFalhou:
        return corErro;
      default:
        return Colors.grey;
    }
  }
}

// ==================== ENUM PARA TIPO DE ENTREGA ====================
enum TipoEntrega {
  centralizada,
  wifiDirect,
  mula,
}

extension TipoEntregaExtension on TipoEntrega {
  String get apiValue {
    switch (this) {
      case TipoEntrega.centralizada:
        return Constantes.entregaCentralizada;
      case TipoEntrega.wifiDirect:
        return Constantes.entregaWifiDirect;
      case TipoEntrega.mula:
        return Constantes.entregaMula;
    }
  }

  String get displayName {
    switch (this) {
      case TipoEntrega.centralizada:
        return 'Centralizada (Servidor)';
      case TipoEntrega.wifiDirect:
        return 'WiFi Direct (P2P)';
      case TipoEntrega.mula:
        return 'MULA (Offline)';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoEntrega.centralizada:
        return Icons.cloud;
      case TipoEntrega.wifiDirect:
        return Icons.wifi;
      case TipoEntrega.mula:
        return Icons.qr_code;
    }
  }

  Color get color {
    switch (this) {
      case TipoEntrega.centralizada:
        return Constantes.corInfo;
      case TipoEntrega.wifiDirect:
        return Colors.green;
      case TipoEntrega.mula:
        return Constantes.corAviso;
    }
  }
}
