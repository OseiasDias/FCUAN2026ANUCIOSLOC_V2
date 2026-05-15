import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../utils/constantes.dart';

class ApiService {
  // ==================== UTILIZADORES ====================

  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:ativarUtilizador>
      <email>$email</email>
      <password>$senha</password>
      <nome>$nome</nome>
    </ns:ativarUtilizador>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);
        final texto =
            documento.findAllElements('return').firstOrNull?.innerText ?? '';

        if (texto.contains('sucesso') || texto.contains('✅')) {
          await cadastrarNoKerberos(email, senha);
          return {'sucesso': true, 'mensagem': texto};
        }

        return {'sucesso': false, 'mensagem': texto};
      }

      return {'sucesso': false, 'mensagem': Constantes.erroConexao};
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro: $e'};
    }
  }

  // ==================== KERBEROS ====================

  static Future<bool> cadastrarNoKerberos(String email, String senha) async {
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

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlAutenticacao),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      return resposta.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== LOGIN ====================

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

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlAutenticacao),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);
        final ticketId =
            documento.findAllElements('ticketId').firstOrNull?.innerText;

        if (ticketId != null) {
          final saldo = await consultarSaldo(email);

          return {
            'sucesso': true,
            'ticketId': ticketId,
            'email': email,
            'saldo': saldo,
          };
        }
      }

      return {'sucesso': false, 'mensagem': Constantes.erroCredenciais};
    } catch (e) {
      return {'sucesso': false, 'mensagem': Constantes.erroConexao};
    }
  }

  // ==================== SALDO ====================

  static Future<int> consultarSaldo(String email) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:consultarSaldo>
      <email>$email</email>
    </ns:consultarSaldo>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);
        final saldo =
            documento.findAllElements('return').firstOrNull?.innerText;

        return int.tryParse(saldo ?? '0') ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== ANÚNCIOS ====================

  static Future<bool> publicarAnuncio({
    required String email,
    required String conteudo,
    required String local,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:postarMensagem>
      <email>$email</email>
      <conteudo>$conteudo</conteudo>
      <local>$local</local>
    </ns:postarMensagem>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      return resposta.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> receberAnuncios({
    required String email,
    required String local,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:receberMensagens>
      <email>$email</email>
      <local>$local</local>
    </ns:receberMensagens>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);

        return documento
            .findAllElements('return')
            .map((e) => e.innerText)
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> listarUtilizadores() async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:listarUtilizadores/>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);

        return documento
            .findAllElements('return')
            .map((e) => e.innerText)
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> listarMeusAnuncios(String email) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:listarAnunciosPorUtilizador>
      <email>$email</email>
    </ns:listarAnunciosPorUtilizador>
  </soap:Body>
</soap:Envelope>''';

      final resposta = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (resposta.statusCode == 200) {
        final documento = XmlDocument.parse(resposta.body);

        return documento
            .findAllElements('return')
            .map((e) => e.innerText)
            .toList();
      }

      return [];
    } catch (e) {
      print("ERRO listarMeusAnuncios: $e");
      return [];
    }
  }
}
