import 'package:flutter/material.dart';

import '../utils/preferencias.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _verificarLogin();
  }

  Future<void> _verificarLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final logado = await Preferencias.estaLogado();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => logado ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
