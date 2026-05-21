import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/localizacao_model.dart';

class LocalizacaoService {
  static Future<bool> verificarPermissoes() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<LocalizacaoModel> obterLocalizacaoAtual() async {
    final posicao = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final localizacao = LocalizacaoModel(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      endereco: '',
      timestamp: DateTime.now(),
    );

    return localizacao;
  }

  static Future<double> calcularDistancia(LatLng ponto1, LatLng ponto2) async {
    return Geolocator.distanceBetween(
      ponto1.latitude,
      ponto1.longitude,
      ponto2.latitude,
      ponto2.longitude,
    );
  }

  static Future<bool> estaDentroRaio(
      LatLng centro, double raioMetros, LatLng ponto) async {
    final distancia = await calcularDistancia(centro, ponto);
    return distancia <= raioMetros;
  }
}
