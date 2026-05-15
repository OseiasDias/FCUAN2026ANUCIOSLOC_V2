import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String hint;
  final IconData icone;
  final bool ehSenha;
  final bool senhaVisivel;
  final VoidCallback? alternarVisibilidade;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;

  const CampoTexto({
    super.key,
    required this.controlador,
    required this.rotulo,
    required this.hint,
    required this.icone,
    this.ehSenha = false,
    this.senhaVisivel = false,
    this.alternarVisibilidade,
    this.tipoTeclado = TextInputType.text,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: ehSenha && !senhaVisivel,
      keyboardType: tipoTeclado,
      validator: validador,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: hint,
        prefixIcon: Icon(icone),
        suffixIcon: ehSenha
            ? IconButton(
                icon: Icon(
                    senhaVisivel ? Icons.visibility : Icons.visibility_off),
                onPressed: alternarVisibilidade,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
