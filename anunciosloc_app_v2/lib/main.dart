import 'package:flutter/material.dart';
import 'theme/tema_app.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AnunciosLocApp());
}

class AnunciosLocApp extends StatelessWidget {
  const AnunciosLocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnunciosLoc',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      home: const SplashScreen(),
    );
  }
}
