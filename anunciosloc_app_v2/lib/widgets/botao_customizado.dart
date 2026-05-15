import 'package:flutter/material.dart';
import '../utils/constantes.dart';

class BotaoCustomizado extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;
  final bool estaCarregando;
  final Color? cor;

  const BotaoCustomizado({
    super.key,
    required this.texto,
    required this.aoClicar,
    this.estaCarregando = false,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: estaCarregando ? null : aoClicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor ?? Constantes.corPrincipal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: estaCarregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                texto,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
