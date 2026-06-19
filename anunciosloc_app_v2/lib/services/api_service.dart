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

  // Método antigo (compatibilidade) - aceita apenas conteudo
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

  static Future<Map<String, dynamic>> publicarAnuncioCompleto({
    required String email,
    required String titulo,
    required String descricao,
    required String local,
    required int diasValidade,
  }) async {
    try {
      // Verificar saldo primeiro
      final saldoAtual = await consultarSaldo(email);
      print("Saldo atual: $saldoAtual");

      if (saldoAtual < 5) {
        return {
          'sucesso': false,
          'id': null,
          'mensagem':
              'Saldo insuficiente! Você tem $saldoAtual pontos. Necessário 5 pontos.',
          'saldoRestante': saldoAtual,
          'codigo': 'SALDO_INSUFICIENTE'
        };
      }

      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:postarMensagemCompleta>
      <email>$email</email>
      <titulo>$titulo</titulo>
      <descricao>$descricao</descricao>
      <local>$local</local>
      <diasValidade>$diasValidade</diasValidade>
    </ns:postarMensagemCompleta>
  </soap:Body>
</soap:Envelope>''';

      print("=== PUBLICAR ANUNCIO COMPLETO ===");
      print("Email: $email");
      print("Titulo: $titulo");
      print("Local: $local");
      print("Dias de validade: $diasValidade");

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': _soapAction,
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final returnElement = doc.findAllElements('return').firstOrNull;

        if (returnElement != null) {
          final texto = returnElement.innerText;

          // VERIFICAR SE A RESPOSTA CONTÉM ERRO
          final palavrasErro = [
            'Erro:',
            'Saldo insuficiente',
            'Aguarde',
            'não encontrado',
            'inválido'
          ];
          final temErro =
              palavrasErro.any((palavra) => texto.contains(palavra));

          if (temErro) {
            return {
              'sucesso': false,
              'id': null,
              'mensagem': texto,
              'saldoRestante': null,
              'codigo': 'ERRO_NEGOCIO'
            };
          }

          // Tentar extrair o ID do anúncio da mensagem de retorno
          final regexId = RegExp(r'ID:\s*([a-f0-9-]+)');
          final matchId = regexId.firstMatch(texto);

          // Tentar extrair o saldo restante
          final regexSaldo = RegExp(r'Saldo restante:\s*(\d+)');
          final matchSaldo = regexSaldo.firstMatch(texto);

          return {
            'sucesso': true,
            'id': matchId?.group(1),
            'mensagem': texto,
            'saldoRestante': matchSaldo != null
                ? int.tryParse(matchSaldo.group(1) ?? '0')
                : null,
            'codigo': 'SUCESSO'
          };
        }
        return {
          'sucesso': false,
          'id': null,
          'mensagem': 'Erro ao publicar anúncio',
          'codigo': 'ERRO_DESCONHECIDO'
        };
      }
      return {
        'sucesso': false,
        'id': null,
        'mensagem': 'HTTP ${response.statusCode}',
        'codigo': 'ERRO_HTTP'
      };
    } catch (e) {
      print("Erro ao publicar anuncio: $e");
      return {
        'sucesso': false,
        'id': null,
        'mensagem': 'Erro: $e',
        'codigo': 'ERRO_EXCECAO'
      };
    }
  }

  // Método de conveniencia para publicar com titulo e descricao (retorna bool)
  static Future<bool> publicarAnuncioComTitulo({
    required String email,
    required String titulo,
    required String descricao,
    required String local,
    int diasValidade = 30,
  }) async {
    final resultado = await publicarAnuncioCompleto(
      email: email,
      titulo: titulo,
      descricao: descricao,
      local: local,
      diasValidade: diasValidade,
    );
    return resultado['sucesso'] == true;
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

        final returns = doc.findAllElements('return');

        for (var returnElem in returns) {
          String nome = '';
          double latitude = 0;
          double longitude = 0;
          int capacidade = 0;

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

          if (nome.isEmpty) {
            final texto = returnElem.innerText;
            print("Texto do return: $texto");

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

      return await _listarInfraestruturasAlternativo();
    } catch (e) {
      print("Erro ao listar infraestruturas: $e");
      return await _listarInfraestruturasAlternativo();
    }
  }

  static Future<List<Map<String, dynamic>>>
      _listarInfraestruturasAlternativo() async {
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

        final returnElement = doc.findAllElements('return').firstOrNull;

        if (returnElement == null) {
          print("Elemento return nao encontrado");
          return [];
        }

        final items = returnElement.findAllElements('item');
        List<Map<String, dynamic>> locais = [];

        for (var item in items) {
          final texto = item.innerText;
          print("Texto do local: $texto");

          final partes = texto.split('|');

          if (partes.length >= 6 && partes[1] == 'GPS') {
            locais.add({
              'nome': partes[0],
              'tipo': partes[1],
              'latitude': double.tryParse(partes[2]) ?? 0,
              'longitude': double.tryParse(partes[3]) ?? 0,
              'raio': double.tryParse(partes[4]) ?? 0,
              'infraestrutura':
                  partes.length > 5 ? partes[5] : 'Sem infraestrutura',
            });
          } else if (partes.length >= 4 && partes[1] == 'WIFI') {
            locais.add({
              'nome': partes[0],
              'tipo': partes[1],
              'wifiSsid': partes[2],
              'infraestrutura':
                  partes.length > 3 ? partes[3] : 'Sem infraestrutura',
            });
          } else if (partes.length >= 4) {
            locais.add({
              'nome': partes[0],
              'tipo': 'GPS',
              'latitude': double.tryParse(partes[1]) ?? 0,
              'longitude': double.tryParse(partes[2]) ?? 0,
              'capacidade': int.tryParse(partes[3]) ?? 0,
            });
          }
        }

        print("Locais encontrados: ${locais.length}");
        for (var local in locais) {
          if (local['tipo'] == 'GPS') {
            print(
                "   - ${local['nome']}: GPS (${local['latitude']}, ${local['longitude']}) - ${local['infraestrutura']}");
          } else {
            print(
                "   - ${local['nome']}: WIFI (${local['wifiSsid']}) - ${local['infraestrutura']}");
          }
        }

        return locais;
      }

      print("Status code: ${response.statusCode}");
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
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:listarAnunciosPorUtilizador>
      <email>$email</email>
    </ns:listarAnunciosPorUtilizador>
  </soap:Body>
</soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {'Content-Type': 'text/xml'},
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final returnElement = doc.findAllElements('return').firstOrNull;

        if (returnElement != null) {
          final items = returnElement.findAllElements('item');
          if (items.isNotEmpty) {
            final ultimoItem = items.last;
            final idTexto = ultimoItem.innerText;
            print("Ultimo anuncio: $idTexto");
            return idTexto;
          }
        }
      }
      return '';
    } catch (e) {
      print("Erro ao obter ultimo anuncio ID: $e");
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
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:criarLocal>
      <nome>$nome</nome>
      <tipo>$tipo</tipo>
      <latitude>$latitude</latitude>
      <longitude>$longitude</longitude>
      <raio>$raio</raio>
      <wifiSsid>$wifiSsid</wifiSsid>
      <infraestruturaId>1</infraestruturaId>
      <email>$criadorEmail</email>
    </ns:criarLocal>
  </soap:Body>
</soap:Envelope>''';

      print("=== CRIAR LOCAL ===");
      print("URL: ${Constantes.urlInfra}");
      print("Email: $criadorEmail");
      print("Envelope: $envelope");

      final response = await http
          .post(
            Uri.parse(Constantes.urlInfra),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final result =
            doc.findAllElements('return').firstOrNull?.innerText ?? '';
        print("Resultado: $result");
        return result.contains('sucesso') || result.contains('criado');
      }

      return false;
    } catch (e) {
      print("Erro ao criar local: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listarTodosLocais() async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:listarLocais/>
  </soap:Body>
</soap:Envelope>''';

      final response = await http.post(
        Uri.parse(Constantes.urlInfra),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('return');
        List<Map<String, dynamic>> locais = [];

        for (var item in items) {
          final texto = item.innerText;
          final partes = texto.split('|');
          if (partes.length >= 4) {
            locais.add({
              'id': int.tryParse(partes[0] ?? '0') ?? 0,
              'nome': partes[1] ?? '',
              'tipo': partes[2] ?? 'GPS',
              'latitude': double.tryParse(partes[3] ?? '0') ?? 0,
              'longitude': double.tryParse(partes[4] ?? '0') ?? 0,
              'raio': double.tryParse(partes[5] ?? '20') ?? 20,
              'wifiSsid': partes.length > 6 ? partes[6] : '',
            });
          }
        }
        return locais;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> eliminarLocal(int id) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:eliminarLocal>
      <id>$id</id>
    </ns:eliminarLocal>
  </soap:Body>
</soap:Envelope>''';

      final response = await http.post(
        Uri.parse(Constantes.urlInfra),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> atualizarLocal({
    required int id,
    required String nome,
    required String tipo,
    required double latitude,
    required double longitude,
    required double raio,
    required String wifiSsid,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:atualizarLocal>
      <id>$id</id>
      <nome>$nome</nome>
      <tipo>$tipo</tipo>
      <latitude>$latitude</latitude>
      <longitude>$longitude</longitude>
      <raio>$raio</raio>
      <wifiSsid>$wifiSsid</wifiSsid>
    </ns:atualizarLocal>
  </soap:Body>
</soap:Envelope>''';

      final response = await http.post(
        Uri.parse(Constantes.urlInfra),
        headers: {'Content-Type': 'text/xml'},
        body: envelope,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listarMeusLocais(
      String email) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:listarMeusLocais>
      <email>$email</email>
    </ns:listarMeusLocais>
  </soap:Body>
</soap:Envelope>''';

      print("=== LISTAR MEUS LOCAIS ===");
      print("URL: ${Constantes.urlInfra}");
      print("Email: $email");

      final response = await http
          .post(
            Uri.parse(Constantes.urlInfra),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
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
          final partes = texto.split('|');

          if (partes.length >= 6) {
            locais.add({
              'id': int.tryParse(partes[0]) ?? 0,
              'nome': partes[1],
              'tipo': partes[2],
              'latitude': double.tryParse(partes[3]) ?? 0,
              'longitude': double.tryParse(partes[4]) ?? 0,
              'raio': double.tryParse(partes[5]) ?? 20,
              'wifiSsid': partes.length > 6 ? partes[6] : '',
            });
          }
        }

        print("Locais encontrados: ${locais.length}");
        return locais;
      }
      return [];
    } catch (e) {
      print("Erro ao listar meus locais: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> obterInfoInfraestrutura() async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespaceInfra}">
  <soap:Body>
    <ns:obterInfoInfraestrutura/>
  </soap:Body>
</soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(Constantes.urlInfra),
            headers: {'Content-Type': 'text/xml'},
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final texto =
            doc.findAllElements('return').firstOrNull?.innerText ?? '';

        return {
          'nome': _extrairValor(texto, 'Infraestrutura:'),
          'capacidade':
              int.tryParse(_extrairValor(texto, 'Capacidade:')) ?? 100,
          'conectados': int.tryParse(_extrairValor(texto, 'Conectados:')) ?? 0,
          'premio': double.tryParse(_extrairValor(texto, 'Prémio:')) ?? 2.0,
        };
      }
      return {};
    } catch (e) {
      return {
        'nome': 'Infraestrutura Central',
        'capacidade': 100,
        'conectados': 0,
        'premio': 2.0
      };
    }
  }

  static String _extrairValor(String texto, String chave) {
    final regex = RegExp('$chave\\s*(.*?)(?:\n|)');
    final match = regex.firstMatch(texto);
    return match?.group(1)?.trim() ?? '';
  }

  static Future<List<String>> receberAnunciosDeOutros({
    required String email,
    required String local,
  }) async {
    try {
      final envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="${Constantes.namespace}">
  <soap:Body>
    <ns:receberAnunciosDeOutros>
      <email>$email</email>
      <local>$local</local>
    </ns:receberAnunciosDeOutros>
  </soap:Body>
</soap:Envelope>''';

      print("=== RECEBER ANUNCIOS DE OUTROS ===");
      print("URL: ${Constantes.urlApi}");
      print("Email: $email");
      print("Local: $local");

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
        return items.map((e) => e.innerText).toList();
      }
      return [];
    } catch (e) {
      print("Erro ao receber anuncios de outros: $e");
      return [];
    }
  }

  static Future<List<AnuncioModel>> listarMeusAnuncios(String email) async {
    try {
      final body = '<email>$email</email>';
      final envelope = _buildEnvelope('listarAnunciosPorUtilizador', body);

      final response = await http
          .post(
            Uri.parse(Constantes.urlApi),
            headers: {'Content-Type': 'text/xml'},
            body: envelope,
          )
          .timeout(const Duration(seconds: Constantes.tempoEspera));

      print("=== LISTAR MEUS ANUNCIOS ===");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final doc = XmlDocument.parse(response.body);
        final items = doc.findAllElements('return');

        List<AnuncioModel> anuncios = [];
        for (var item in items) {
          final texto = item.innerText;

          // IGNORAR mensagens que não são anúncios válidos
          if (texto.contains('Nenhum anuncio encontrado') ||
              texto.contains('Erro:') ||
              texto.trim().isEmpty) {
            print("Ignorando mensagem: $texto");
            continue; // Pula este item
          }

          final anuncio = AnuncioModel.fromSoap(texto);
          anuncios.add(anuncio);
        }

        print("Anuncios encontrados: ${anuncios.length}");
        return anuncios;
      }
      return [];
    } catch (e) {
      print("Erro ao listar meus anuncios: $e");
      return [];
    }
  }
}
