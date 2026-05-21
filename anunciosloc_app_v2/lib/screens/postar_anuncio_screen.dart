import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../widgets/botao_customizado.dart';
import '../widgets/campo_texto.dart';

class PostarAnuncioScreen extends StatefulWidget {
  const PostarAnuncioScreen({super.key});

  @override
  State<PostarAnuncioScreen> createState() => _PostarAnuncioScreenState();
}

class _PostarAnuncioScreenState extends State<PostarAnuncioScreen> {
  final _formChave = GlobalKey<FormState>();
  final _conteudoController = TextEditingController();
  final _localController = TextEditingController();
  bool _carregando = false;

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _publicar() async {
    if (!_formChave.currentState!.validate()) return;

    setState(() => _carregando = true);

    final email = await Preferencias.getEmail();
    final sucesso = await ApiService.publicarAnuncio(
      email: email,
      conteudo: _conteudoController.text,
      local: _localController.text,
    );

    if (mounted) {
      setState(() => _carregando = false);
      if (sucesso) {
        _mostrarMensagem('✅ Anúncio publicado com sucesso!');
        _conteudoController.clear();
        _localController.clear();
        Navigator.pop(context);
      } else {
        _mostrarMensagem('❌ Erro ao publicar anúncio', isErro: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Anúncio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formChave,
          child: Column(
            children: [
              CampoTexto(
                controlador: _conteudoController,
                rotulo: 'Conteúdo',
                hint: 'Digite o seu anúncio...',
                icone: Icons.announcement,
                validador: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Digite o conteúdo do anúncio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _localController,
                rotulo: 'Local',
                hint: 'Ex: Belas Shopping, Talatona...',
                icone: Icons.location_on,
                validador: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Digite o local do anúncio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              BotaoCustomizado(
                texto: 'PUBLICAR',
                aoClicar: _publicar,
                estaCarregando: _carregando,
                corFundo: Colors.green, // Adicionar esta linha
              ),
            ],
          ),
        ),
      ),
    );
  }
}
