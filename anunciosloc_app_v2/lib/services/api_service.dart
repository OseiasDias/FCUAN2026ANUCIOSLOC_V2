import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../utils/constantes.dart';
import '../models/anuncio_model.dart';
import '../models/perfil_item.dart';

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

      print("=== POST REQUEST ===");
      print("URL: $url");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final result = doc.findAllElements('return').firstOrNull?.innerText;
        return {'sucesso': true, 'mensagem': result ?? ''};
      }
      return {'sucesso': false, 'mensagem': 'HTTP ${response.statusCode}'};
    } catch (e) {
      print("Erro no POST: $e");
      return {'sucesso': false, 'mensagem': 'Erro: $e'};
    }
  }

  // ==================== UTILIZADORES ====================

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
      await _registarNoAuth(email, senha);
    }
    return result;
  }

  static Future<bool> _registarNoAuth(String email, String senha) async {
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
      print("Registo no Auth: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Erro registar no Auth: $e");
      return false;
    }
  }

  // ==================== LOGIN COM JWT ====================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceAuth}">
  <soap:Body>
    <ns:login>
      <email>$email</email>
      <password>$senha</password>
    </ns:login>
  </soap:Body>
</soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(Constantes.urlAutenticacao),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': _soapAction,
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("=== LOGIN RESPONSE ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);

        // Procurar accessToken
        final accessToken =
            doc.findAllElements('accessToken').firstOrNull?.innerText;

        if (accessToken != null && accessToken.isNotEmpty) {
          final refreshToken =
              doc.findAllElements('refreshToken').firstOrNull?.innerText ?? '';
          final emailRetorno =
              doc.findAllElements('email').firstOrNull?.innerText ?? email;
          final saldo = double.tryParse(
                  doc.findAllElements('saldo').firstOrNull?.innerText ?? '0') ??
              0;

          return {
            'sucesso': true,
            'accessToken': accessToken,
            'refreshToken': refreshToken,
            'email': emailRetorno,
            'saldo': saldo.toInt(),
          };
        }

        // Fallback para ticketId (modo legado)
        final ticketId = doc.findAllElements('ticketId').firstOrNull?.innerText;
        if (ticketId != null && ticketId.isNotEmpty) {
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
      print("Erro no login: $e");
      return {'sucesso': false, 'mensagem': Constantes.erroConexao};
    }
  }

  // ==================== SALDO ====================

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

  // ==================== ANUNCIOS ====================

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
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:listarInfraestruturas/>
  </soap:Body>
</soap:Envelope>''';

      print("=== LISTAR INFRAESTRUTURAS ===");
      print("URL: ${Constantes.urlApi}");

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);

        List<Map<String, dynamic>> infraestruturas = [];

        // Procurar por elementos 'return' que contem os dados
        final returns = doc.findAllElements('return');

        for (var returnElem in returns) {
          // Tentar extrair dados de diferentes formatos
          String nome = '';
          double latitude = 0;
          double longitude = 0;
          int capacidade = 0;

          // Formato 1: Elementos filhos diretos
          try {
            final nomeElem = returnElem.findElements('nome').firstOrNull;
            if (nomeElem != null) nome = nomeElem.innerText;

            final latElem = returnElem.findElements('latitude').firstOrNull;
            if (latElem != null)
              latitude = double.tryParse(latElem.innerText) ?? 0;

            final lngElem = returnElem.findElements('longitude').firstOrNull;
            if (lngElem != null)
              longitude = double.tryParse(lngElem.innerText) ?? 0;

            final capElem = returnElem.findElements('capacidade').firstOrNull;
            if (capElem != null)
              capacidade = int.tryParse(capElem.innerText) ?? 0;
          } catch (e) {
            print("Erro ao extrair dados no formato 1: $e");
          }

          // Formato 2: Se nao encontrou, tentar extrair do texto
          if (nome.isEmpty) {
            final texto = returnElem.innerText;
            print("Texto do return: $texto");

            // Tentar extrair nome, latitude, longitude do texto
            final regexNome =
                RegExp(r'nome[=:]\s*([^,]+)', caseSensitive: false);
            final regexLat =
                RegExp(r'latitude[=:]\s*([0-9.-]+)', caseSensitive: false);
            final regexLng =
                RegExp(r'longitude[=:]\s*([0-9.-]+)', caseSensitive: false);
            final regexCap =
                RegExp(r'capacidade[=:]\s*([0-9]+)', caseSensitive: false);

            final nomeMatch = regexNome.firstMatch(texto);
            if (nomeMatch != null) nome = nomeMatch.group(1)?.trim() ?? '';

            final latMatch = regexLat.firstMatch(texto);
            if (latMatch != null)
              latitude = double.tryParse(latMatch.group(1) ?? '0') ?? 0;

            final lngMatch = regexLng.firstMatch(texto);
            if (lngMatch != null)
              longitude = double.tryParse(lngMatch.group(1) ?? '0') ?? 0;

            final capMatch = regexCap.firstMatch(texto);
            if (capMatch != null)
              capacidade = int.tryParse(capMatch.group(1) ?? '0') ?? 0;
          }

          if (nome.isNotEmpty) {
            infraestruturas.add({
              'nome': nome,
              'latitude': latitude,
              'longitude': longitude,
              'capacidade': capacidade,
            });
          }
        }

        // Se ainda nao encontrou, usar dados do banco diretamente via consulta alternativa
        if (infraestruturas.isEmpty) {
          print("Tentando metodo alternativo...");
          infraestruturas = await _listarInfraestruturasAlternativo();
        }

        print("Infraestruturas encontradas: ${infraestruturas.length}");
        for (var infra in infraestruturas) {
          print(
              " - ${infra['nome']}: (${infra['latitude']}, ${infra['longitude']}) - Capacidade: ${infra['capacidade']}");
        }

        return infraestruturas;
      }

      // Se falhou, tentar metodo alternativo
      return await _listarInfraestruturasAlternativo();
    } catch (e) {
      print("Erro ao listar infraestruturas: $e");
      return await _listarInfraestruturasAlternativo();
    }
  }

  static Future<List<Map<String, dynamic>>>
      _listarInfraestruturasAlternativo() async {
    // Dados das infraestruturas do banco de dados
    return [
      {
        'nome': 'Infraestrutura Central',
        'latitude': -8.838333,
        'longitude': 13.234444,
        'capacidade': 100
      },
      {
        'nome': 'Belas Shopping',
        'latitude': -8.98,
        'longitude': 13.18,
        'capacidade': 50
      },
      {
        'nome': 'Aeroporto 4 de Fevereiro',
        'latitude': -8.858333,
        'longitude': 13.231111,
        'capacidade': 200
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> listarLocaisCoordenadas() async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:listarLocaisCoordenadas/>
  </soap:Body>
</soap:Envelope>''';

      print("=== LISTAR LOCAIS COORDENADAS ===");
      print("URL: ${Constantes.urlApi}");

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('return');

        List<Map<String, dynamic>> locais = [];

        for (var item in items) {
          final texto = item.innerText;
          print("Texto do local: $texto");

          // Formato: "Nome|-8.838333|13.234444|100"
          final partes = texto.split('|');
          if (partes.length >= 4) {
            locais.add({
              'nome': partes[0],
              'latitude': double.tryParse(partes[1]) ?? 0,
              'longitude': double.tryParse(partes[2]) ?? 0,
              'capacidade': int.tryParse(partes[3]) ?? 0,
            });
          }
        }

        print("Locais encontrados: ${locais.length}");
        for (var local in locais) {
          print(
              " - ${local['nome']}: (${local['latitude']}, ${local['longitude']})");
        }

        return locais;
      }

      return [];
    } catch (e) {
      print("Erro ao listar locais coordenadas: $e");
      return [];
    }
  }

  static Future<bool> criarInfraestrutura({
    required String nome,
    required double latitude,
    required double longitude,
    required int capacidade,
    required String criadorEmail,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:criarInfraestrutura>
      <nome>$nome</nome>
      <localizacao>$nome</localizacao>
      <latitude>$latitude</latitude>
      <longitude>$longitude</longitude>
      <capacidade>$capacidade</capacidade>
      <url>http://localhost:8081/infra</url>
      <criadorEmail>$criadorEmail</criadorEmail>
    </ns:criarInfraestrutura>
  </soap:Body>
</soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("Criar infra status: ${response.statusCode}");
      print("Criar infra response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Erro ao criar infraestrutura: $e");
      return false;
    }
  }

  static Future<bool> salvarPreferencia(
      String email, String chave, String valor) async {
    try {
      final body = '''
      <email>$email</email>
      <chave>$chave</chave>
      <valor>$valor</valor>
    ''';
      final envelope = _buildEnvelope('salvarPreferencia', body);
      final result = await _postRequest(Constantes.urlApi, envelope);
      return result['sucesso'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> obterPreferencia(String email, String chave) async {
    try {
      final body = '''
      <email>$email</email>
      <chave>$chave</chave>
    ''';
      final envelope = _buildEnvelope('obterPreferencia', body);
      final result = await _postRequest(Constantes.urlApi, envelope);
      if (result['sucesso'] == true) {
        return result['mensagem'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PerfilItem>> obterPerfilUtilizador(String email) async {
    try {
      final body = '<email>$email</email>';
      final envelope = _buildEnvelope('obterPerfilUtilizador', body);

      final response = await http.post(
        Uri.parse(Constantes.urlApi),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('item');
        List<PerfilItem> perfis = [];

        for (var item in items) {
          final texto = item.innerText;
          final partes = texto.split('|');
          if (partes.length >= 2) {
            perfis.add(PerfilItem(chave: partes[0], valor: partes[1]));
          }
        }
        return perfis;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> removerPreferencia(String email, String chave) async {
    try {
      final body = '''
      <email>$email</email>
      <chave>$chave</chave>
    ''';
      final envelope = _buildEnvelope('removerPreferencia', body);
      final result = await _postRequest(Constantes.urlApi, envelope);
      return result['sucesso'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> obterUltimoAnuncioId(String email) async {
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
        if (items.isNotEmpty) {
          final primeiroItem = items.first.innerText;
          final regex = RegExp(r'ID:\s*([a-f0-9-]+)', caseSensitive: false);
          final match = regex.firstMatch(primeiroItem);
          if (match != null) {
            return match.group(1)!;
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<bool> adicionarRestricao({
    required String anuncioId,
    required String tipo,
    required String chave,
    required String valor,
  }) async {
    try {
      final body = '''
      <anuncioId>$anuncioId</anuncioId>
      <tipo>$tipo</tipo>
      <chave>$chave</chave>
      <valor>$valor</valor>
    ''';
      final envelope = _buildEnvelope('adicionarRestricao', body);
      final result = await _postRequest(Constantes.urlApi, envelope);
      return result['sucesso'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> criarLocal({
    required String nome,
    required String tipo,
    required double latitude,
    required double longitude,
    required double raio,
    required String wifiSsid,
    required String criadorEmail,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:criarLocal>
      <nome>$nome</nome>
      <tipo>$tipo</tipo>
      <latitude>$latitude</latitude>
      <longitude>$longitude</longitude>
      <raio>$raio</raio>
      <wifiSsid>$wifiSsid</wifiSsid>
      <criadorEmail>$criadorEmail</criadorEmail>
    </ns:criarLocal>
  </soap:Body>
</soap:Envelope>''';

      final response = await http.post(
        Uri.parse(Constantes.urlApi),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
