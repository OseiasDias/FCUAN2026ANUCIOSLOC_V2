import 'dart:async';

class WifiDirectDevice {
  final String name;
  final String address;
  final int signalStrength;

  WifiDirectDevice({
    required this.name,
    required this.address,
    required this.signalStrength,
  });
}

class WifiDirectService {
  static bool _inicializado = false;

  static Future<bool> inicializar() async {
    _inicializado = true;
    return true;
  }

  static Future<List<WifiDirectDevice>> descobrirDispositivos() async {
    // Simulacao de dispositivos encontrados
    await Future.delayed(const Duration(seconds: 2));
    return [
      WifiDirectDevice(
          name: 'Dispositivo 1',
          address: '00:11:22:33:44:55',
          signalStrength: 80),
      WifiDirectDevice(
          name: 'Dispositivo 2',
          address: 'AA:BB:CC:DD:EE:FF',
          signalStrength: 60),
    ];
  }

  static Future<bool> conectar(String deviceAddress) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  static Future<bool> enviarMensagem(
      String mensagem, String dispositivoId) async {
    print('Enviando mensagem via WiFi Direct: $mensagem');
    return true;
  }

  static Future<String?> receberMensagem() async {
    return null;
  }

  static Future<void> desconectar() async {
    _inicializado = false;
  }
}
