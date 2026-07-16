import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/anuncio_p2p.dart';

class P2PServerService {
  HttpServer? _server;

  final List<AnuncioP2P> _anuncios = [];

  Future<void> iniciarServidor() async {
    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        8080,
      );

      print("Servidor P2P iniciado porta 8080");

      _server!.listen((HttpRequest request) {
        _processarPedido(request);
      });
    } catch (e) {
      print("Erro servidor P2P: $e");
    }
  }

  Future<void> _processarPedido(HttpRequest request) async {
    // Receber anúncio

    if (request.method == "POST" && request.uri.path == "/anuncio") {
      final body = await utf8.decoder.bind(request).join();

      final json = jsonDecode(body);

      final anuncio = AnuncioP2P.fromJson(json);

      _anuncios.add(anuncio);

      request.response.statusCode = HttpStatus.ok;

      request.response.write(jsonEncode({"status": "recebido"}));

      await request.response.close();

      print("Novo anuncio recebido ${anuncio.titulo}");

      return;
    }

    // Entregar anúncios

    if (request.method == "GET" && request.uri.path == "/anuncios") {
      request.response.headers.contentType = ContentType.json;

      request.response
          .write(jsonEncode(_anuncios.map((e) => e.toJson()).toList()));

      await request.response.close();

      return;
    }

    request.response.statusCode = HttpStatus.notFound;

    await request.response.close();
  }

  List<AnuncioP2P> get anuncios => _anuncios;

  Future<void> pararServidor() async {
    await _server?.close();
  }
}
