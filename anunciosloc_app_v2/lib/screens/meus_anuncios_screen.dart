import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';

class MeusAnunciosScreen extends StatefulWidget {
  const MeusAnunciosScreen({super.key});

  @override
  State<MeusAnunciosScreen> createState() => _MeusAnunciosScreenState();
}

class _MeusAnunciosScreenState extends State<MeusAnunciosScreen> {
  List<String> anuncios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    String email = await Preferencias.getEmail();
    anuncios = await ApiService.listarMeusAnuncios(email);
    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Anúncios")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: anuncios.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign),
                    title: Text(anuncios[index]),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'pagar',
                          child: Text('Pagar / Boost'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'eliminar') {
                          // depois ligamos ao backend
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
