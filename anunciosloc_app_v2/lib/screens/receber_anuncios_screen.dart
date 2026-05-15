import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../widgets/botao_customizado.dart';
import '../widgets/campo_texto.dart';

class ReceberAnunciosScreen extends StatefulWidget {
  const ReceberAnunciosScreen({super.key});

  @override
  State<ReceberAnunciosScreen> createState() => _ReceberAnunciosScreenState();
}

class _ReceberAnunciosScreenState extends State<ReceberAnunciosScreen> {
  final _localController = TextEditingController();
  List<String> _anuncios = [];
  bool _carregando = false;

  Future<void> _buscar() async {
    if (_localController.text.isEmpty) return;

    setState(() {
      _carregando = true;
      _anuncios = [];
    });

    final email = await Preferencias.getEmail();
    final mensagens = await ApiService.receberAnuncios(
      email: email,
      local: _localController.text,
    );

    setState(() {
      _carregando = false;
      _anuncios = mensagens;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receber Anúncios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CampoTexto(
                    controlador: _localController,
                    rotulo: 'Local',
                    hint: 'Digite o local',
                    icone: Icons.search,
                  ),
                ),
                const SizedBox(width: 8),
                BotaoCustomizado(
                  texto: 'Buscar',
                  aoClicar: _buscar,
                  estaCarregando: _carregando,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _anuncios.isEmpty
                      ? const Center(child: Text('Nenhum anúncio encontrado'))
                      : ListView.builder(
                          itemCount: _anuncios.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.announcement,
                                    color: Colors.blue),
                                title: Text(_anuncios[index]),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
