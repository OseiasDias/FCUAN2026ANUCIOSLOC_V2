import 'package:flutter/material.dart';

class Constantes {
  // ==================== URLs DOS SERVIDORES ====================
  static const String ipServidor = '10.157.116.128';

  static const String portaApi = '8082';
  static const String portaAuth = '8085';

  static const String urlBase = 'http://$ipServidor:$portaApi';
  static const String urlAutenticacao = 'http://$ipServidor:$portaAuth/auth';
  static const String urlApi = '$urlBase/ws/anunciosloc';

  // ==================== SOAP NAMESPACES ====================
  static const String namespace = 'http://service.server.anunciosloc.pt/';
  static const String namespaceAuth = 'http://service.auth.anunciosloc.pt/';

  // ==================== TIMEOUT ====================
  static const int tempoEspera = 15;

  // ==================== SHARED PREFERENCES ====================
  static const String chaveEmail = 'email';
  static const String chaveTicket = 'ticket_id';
  static const String chaveLogado = 'logado';
  static const String chaveNome = 'nome';

  // ==================== CORES ====================
  static const Color corPrincipal = Color(0xFF6200EE);
  static const Color corSecundaria = Color(0xFF03DAC5);
  static const Color corFundo = Color(0xFFF5F5F5);
  static const Color corErro = Color(0xFFB00020);
  static const Color corSucesso = Color(0xFF4CAF50);

  // ==================== TEXTOS ====================
  static const String nomeApp = 'AnunciosLoc';
  static const String descricaoApp = 'Sistema de Anúncios por Localização';
  static const String sucessoLogin = 'Login realizado com sucesso!';
  static const String sucessoCadastro = 'Conta criada com sucesso!';
  static const String erroConexao = 'Erro de conexão com o servidor';
  static const String erroCredenciais = 'E-mail ou senha inválidos';
}
