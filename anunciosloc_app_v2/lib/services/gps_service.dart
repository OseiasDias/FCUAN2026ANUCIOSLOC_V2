import 'package:geolocator/geolocator.dart';

class GpsService {
  static Future<bool> verificarPermissao() async {
    // Verificar se GPS está ligado
    bool ativo = await Geolocator.isLocationServiceEnabled();

    if (!ativo) {
      print("GPS desligado no dispositivo");
      return false;
    }

    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      print("Permissão GPS negada");
      return false;
    }

    if (permissao == LocationPermission.deniedForever) {
      print("Permissão GPS bloqueada permanentemente");
      return false;
    }

    return true;
  }

  static Future<Position?> obterLocalizacaoAtual() async {
    final permitido = await verificarPermissao();

    if (!permitido) {
      return null;
    }

    try {
      Position posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print("GPS encontrado: ${posicao.latitude}, ${posicao.longitude}");

      return posicao;
    } catch (e) {
      print("Erro ao obter GPS: $e");

      return null;
    }
  }

  static Stream<Position> acompanharMovimento() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    );
  }
}
