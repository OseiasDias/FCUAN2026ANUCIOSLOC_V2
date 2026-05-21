import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../utils/constantes.dart';
import '../models/anuncio_model.dart';
import '../models/localizacao_model.dart';

class ApiService {
  static const String _soapAction = '';

  static String _buildEnvelope(String method, String body) {
    return '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:$method>
      $body
    </ns:$method>
  </soap:Body>
</soap:Envelope>''';
  }

  static Future<Map<String, dynamic>> _postRequest(
      String url, String envelope) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': _soapAction,
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final result = doc.findAllElements('return').firstOrNull?.innerText;
        return {'sucesso': true, 'mensagem': result ?? ''};
      }
      return {'sucesso': false, 'mensagem': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro: $e'};
    }
  }

  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    final body = '''
      <email>$email</email>
      <password>$senha</password>
      <nome>$nome</nome>
    ''';

    final envelope = _buildEnvelope('ativarUtilizador', body);
    final result = await _postRequest(Constantes.urlApi, envelope);

    if (result['sucesso'] == true) {
      await _registarNoKerberos(email, senha);
    }
    return result;
  }

  static Future<bool> _registarNoKerberos(String email, String senha) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceAuth}">
  <soap:Body>
    <ns:registarUtilizador>
      <email>$email</email>
      <password>$senha</password>
    </ns:registarUtilizador>
  </soap:Body>
</soap:Envelope>''';

      final response = await http.post(
        Uri.parse(Constantes.urlAutenticacao),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceAuth}">
  <soap:Body>
    <ns:solicitarTicket>
      <email>$email</email>
      <password>$senha</password>
    </ns:solicitarTicket>
  </soap:Body>
</soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(Constantes.urlAutenticacao),
            headers: {'Content-Type': 'text/xml'},
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final ticketId = doc.findAllElements('ticketId').firstOrNull?.innerText;

        if (ticketId != null) {
          final saldo = await consultarSaldo(email);
          return {'sucesso': true, 'ticketId': ticketId, 'saldo': saldo};
        }
      }
      return {'sucesso': false, 'mensagem': Constantes.erroCredenciais};
    } catch (e) {
      return {'sucesso': false, 'mensagem': Constantes.erroConexao};
    }
  }

  static Future<int> consultarSaldo(String email) async {
    try {
      final body = '<email>$email</email>';
      final envelope = _buildEnvelope('consultarSaldo', body);
      final response = await _postRequest(Constantes.urlApi, envelope);

      if (response['sucesso'] == true) {
        return int.tryParse(response['mensagem'] ?? '0') ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> publicarAnuncio({
    required String email,
    required String conteudo,
    required String local,
  }) async {
    final body = '''
      <email>$email</email>
      <conteudo>$conteudo</conteudo>
      <local>$local</local>
    ''';
    final envelope = _buildEnvelope('postarMensagem', body);
    final result = await _postRequest(Constantes.urlApi, envelope);
    return result['sucesso'] == true;
  }

  static Future<List<String>> receberAnuncios({
    required String email,
    required String local,
  }) async {
    try {
      final body = '''
        <email>$email</email>
        <local>$local</local>
      ''';
      final envelope = _buildEnvelope('receberMensagens', body);

      final response = await http.post(
        Uri.parse(Constantes.urlApi),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        return doc.findAllElements('return').map((e) => e.innerText).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<AnuncioModel>> listarMeusAnuncios(String email) async {
    try {
      final body = '<email>$email</email>';
      final envelope = _buildEnvelope('listarAnunciosPorUtilizador', body);

      final response = await http.post(
        Uri.parse(Constantes.urlApi),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('item');
        return items.map((e) => AnuncioModel.fromSoap(e.innerText)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> editarPerfil({
    required String email,
    required String novoEmail,
    required String novoNome,
  }) async {
    final body = '''
      <email>$email</email>
      <novoEmail>$novoEmail</novoEmail>
      <novoNome>$novoNome</novoNome>
    ''';
    final envelope = _buildEnvelope('editarUtilizador', body);
    final result = await _postRequest(Constantes.urlApi, envelope);
    return result['sucesso'] == true;
  }

  static Future<List<Map<String, dynamic>>> listarInfraestruturas() async {
    try {
      final envelope = _buildEnvelope('listarInfraestruturas', '');
      final response = await http.post(
        Uri.parse(Constantes.urlApi),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('item');
        return items
            .map((e) => {
                  'nome': e.findElements('nome').firstOrNull?.innerText ?? '',
                  'latitude': double.tryParse(
                          e.findElements('latitude').firstOrNull?.innerText ??
                              '0') ??
                      0,
                  'longitude': double.tryParse(
                          e.findElements('longitude').firstOrNull?.innerText ??
                              '0') ??
                      0,
                  'capacidade': int.tryParse(
                          e.findElements('capacidade').firstOrNull?.innerText ??
                              '0') ??
                      0,
                })
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
