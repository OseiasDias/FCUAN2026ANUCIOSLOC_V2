import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/anuncio_p2p.dart';
import '../models/entrega_model.dart';

class MulaService {
  static const String _cacheKey = "mula_cache";

  static const String _entregaKey = "mula_mensagens_cache";

  // =====================================================
  // NOVO SISTEMA MULA - ANUNCIOS P2P
  // =====================================================

  static Future<void> armazenarAnuncio(AnuncioP2P anuncio) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_cacheKey);

    List lista = [];

    if (dados != null) {
      lista = json.decode(dados);
    }

    final existe = lista.any((a) => a['id'] == anuncio.id);

    if (!existe) {
      lista.add(anuncio.toMap());
    }

    await prefs.setString(_cacheKey, json.encode(lista));
  }

  static Future<void> salvarAnuncios(List<AnuncioP2P> anuncios) async {
    for (var anuncio in anuncios) {
      await armazenarAnuncio(anuncio);
    }
  }

  static Future<List<AnuncioP2P>> recuperarAnuncios() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_cacheKey);

    if (dados == null) {
      return [];
    }

    List lista = json.decode(dados);

    return lista.map((e) => AnuncioP2P.fromMap(e)).toList();
  }

  // =====================================================
  // SISTEMA ANTIGO ENTREGA
  // =====================================================

  static Future<List<EntregaModel>> recuperarEntregasOffline() async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(_entregaKey);

    if (cached == null) {
      return [];
    }

    final List lista = json.decode(cached);

    return lista.map((e) => EntregaModel.fromMap(e)).toList();
  }

  static Future<void> armazenarParaEntregaOffline(EntregaModel entrega) async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(_entregaKey);

    List lista = [];

    if (cached != null) {
      lista = json.decode(cached);
    }

    lista.add(entrega.toMap());

    await prefs.setString(_entregaKey, json.encode(lista));
  }

  // =====================================================

  static Future<void> limparCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_cacheKey);
  }

  static Future<void> removerAnuncio(String id) async {
    final anuncios = await recuperarAnuncios();

    anuncios.removeWhere((a) => a.id == id);

    await salvarAnuncios(anuncios);
  }
}
