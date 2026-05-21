import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entrega_model.dart';

class MulaService {
  static const String _cacheKey = 'mula_mensagens_cache';
  static const String _qrKey = 'mula_qr_data';

  static Future<void> armazenarParaEntregaOffline(EntregaModel entrega) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cached = prefs.getString(_cacheKey);
    List<Map<String, dynamic>> entregas = [];

    if (cached != null) {
      entregas = List<Map<String, dynamic>>.from(json.decode(cached));
    }

    entregas.add(entrega.toMap());
    await prefs.setString(_cacheKey, json.encode(entregas));
  }

  static Future<List<EntregaModel>> recuperarEntregasOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cached = prefs.getString(_cacheKey);

    if (cached == null) return [];

    final List<Map<String, dynamic>> entregasMap =
        List<Map<String, dynamic>>.from(json.decode(cached));
    return entregasMap.map((e) => EntregaModel.fromMap(e)).toList();
  }

  static Future<void> removerEntregaOffline(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cached = prefs.getString(_cacheKey);

    if (cached != null) {
      List<Map<String, dynamic>> entregas =
          List<Map<String, dynamic>>.from(json.decode(cached));
      entregas.removeWhere((e) => e['id'] == id);
      await prefs.setString(_cacheKey, json.encode(entregas));
    }
  }

  static Future<String> gerarQrCode(String dados) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_qrKey, dados);
    return dados;
  }

  static Future<String?> lerQrCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_qrKey);
  }

  static Future<void> limparCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_qrKey);
  }
}
