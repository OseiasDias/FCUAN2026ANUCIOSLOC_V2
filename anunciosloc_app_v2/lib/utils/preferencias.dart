import 'package:shared_preferences/shared_preferences.dart';
import 'constantes.dart';

class Preferencias {
  static Future<void> salvarUsuario({
    required String email,
    required String ticketId,
    required String nome,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constantes.chaveEmail, email);
    await prefs.setString(Constantes.chaveTicket, ticketId);
    await prefs.setString(Constantes.chaveNome, nome);
    await prefs.setBool(Constantes.chaveLogado, true);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.chaveEmail) ?? '';
  }

  static Future<String> getTicketId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.chaveTicket) ?? '';
  }

  static Future<String> getNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.chaveNome) ?? '';
  }

  static Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constantes.chaveLogado) ?? false;
  }

  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
