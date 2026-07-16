import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ==========================================================
// CALLBACK BACKGROUND (TEM QUE SER GLOBAL)
// ==========================================================

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  // Executado quando a notificação é clicada em background
  // Não usar contexto de UI aqui
}

// ==========================================================
// SERVICE
// ==========================================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'anuncios_loc_channel';
  static const String channelName = 'Anúncios Locais';
  static const String channelDesc = 'Notificações de anúncios próximos';

  static const int notificationNovoAnuncio = 1001;
  static const int notificationSaldo = 1002;
  static const int notificationLocal = 1003;

  // ==========================================================
  // INICIALIZAÇÃO
  // ==========================================================

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timeZoneName),
      );
    } catch (_) {
      tz.setLocalLocation(
        tz.getLocation('UTC'),
      );
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,

      // Clique normal
      onDidReceiveNotificationResponse: _onNotificationTap,

      // Clique em background
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    await _createNotificationChannel();
  }

  // ==========================================================
  // CHANNEL ANDROID
  // ==========================================================

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ==========================================================
  // CLICK FOREGROUND
  // ==========================================================

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    print(
      "Notificação aberta: $payload",
    );
  }

  // ==========================================================
  // NOVO ANÚNCIO
  // ==========================================================

  Future<void> showAnuncioNotification({
    required String titulo,
    required String descricao,
    required String local,
    String? payload,
  }) async {
    final corpo = '$descricao\nLocal: $local';

    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        corpo,
      ),
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      notificationNovoAnuncio,
      titulo,
      corpo,
      NotificationDetails(
        android: android,
        iOS: ios,
      ),
      payload: payload ?? 'anuncio',
    );
  }

  // ==========================================================
  // SALDO
  // ==========================================================

  Future<void> showSaldoNotification(int saldo) async {
    await _plugin.show(
      notificationSaldo,
      'Saldo Atualizado',
      'Seu saldo agora é de $saldo pontos',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'saldo',
    );
  }

  // ==========================================================
  // LOCAL PRÓXIMO
  // ==========================================================

  Future<void> showLocalProximoNotification({
    required String local,
    required int distancia,
    required int anuncios,
  }) async {
    final corpo = 'Você está a ${distancia}m de $local '
        'com $anuncios anúncios disponíveis!';

    await _plugin.show(
      notificationLocal,
      'Local próximo: $local',
      corpo,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            corpo,
          ),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'local_$local',
    );
  }

  // ==========================================================
  // MÚLTIPLOS ANÚNCIOS
  // ==========================================================

  Future<void> showMultiplosAnunciosNotification({
    required String local,
    required int quantidade,
    required List<String> titulos,
  }) async {
    final corpo = titulos.take(3).map((e) => '• $e').join('\n');

    final completo = '$corpo'
        '${quantidade > 3 ? '\n\n+ ${quantidade - 3} anúncios' : ''}';

    await _plugin.show(
      notificationNovoAnuncio + quantidade,
      '$quantidade novos anúncios em $local',
      completo,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            completo,
          ),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'anuncios_$local',
    );
  }

  // ==========================================================
  // UTILITÁRIOS
  // ==========================================================

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    return true;
  }
}
