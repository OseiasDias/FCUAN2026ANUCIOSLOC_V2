import 'package:flutter/material.dart';

import 'services/notification_service.dart';
import 'services/p2p_server_service.dart';
import 'screens/splash_screen.dart';

final P2PServerService p2pServer = P2PServerService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  await p2pServer.iniciarServidor();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnunciosLoc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
