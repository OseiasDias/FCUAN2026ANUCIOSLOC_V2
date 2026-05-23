import 'package:shared_preferences/shared_preferences.dart';
import 'constantes.dart';

class Preferencias {
  static const String _chaveAccessToken = 'access_token';
  static const String _chaveRefreshToken = 'refresh_token';

  static Future<void> salvarUsuario({
    required String email,
    required String ticketId,
    required String nome,
    String? accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(Constantes.chaveEmail, email);
    await prefs.setString(Constantes.chaveTicket, ticketId);
    await prefs.setString(Constantes.chaveNome, nome);
    await prefs.setBool(Constantes.chaveLogado, true);

    if (accessToken != null) {
      await prefs.setString(_chaveAccessToken, accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString(_chaveRefreshToken, refreshToken);
    }
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.chaveEmail) ?? '';
  }

  static Future<String> getTicketId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.chaveTicket) ?? '';
  }

  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveAccessToken) ?? '';
  }

  static Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveRefreshToken) ?? '';
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
