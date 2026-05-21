import 'package:flutter/material.dart';
import '../utils/constantes.dart';

class BotaoCustomizado extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;
  final bool estaCarregando;
  final Color corFundo;
  final Color corTexto;
  final double borderRadius;
  final double altura;
  final IconData? icone;

  const BotaoCustomizado({
    super.key,
    required this.texto,
    required this.aoClicar,
    this.estaCarregando = false,
    this.corFundo = Constantes.corPrincipal,
    this.corTexto = Colors.white,
    this.borderRadius = 12,
    this.altura = 48,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: estaCarregando ? null : aoClicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: corFundo,
          foregroundColor: corTexto,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
