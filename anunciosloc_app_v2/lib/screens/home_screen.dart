import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';
import 'postar_anuncio_screen.dart';
import 'receber_anuncios_screen.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email = '';
  int _saldo = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    _email = await Preferencias.getEmail();
    _saldo = await ApiService.consultarSaldo(_email);
    setState(() => _carregando = false);
  }

  Future<void> _sair() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar saída'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Fechar o diálogo
                Navigator.of(context).pop();

                // Mostrar loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Limpar preferências
                await Preferencias.sair();

                // Navegar para o login
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sair', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constantes.nomeApp),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Constantes.corPrincipal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Constantes.corPrincipal,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Saldo: $_saldo pontos',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Constantes.corPrincipal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _botaoMenu(
                          icone: Icons.edit,
                          titulo: 'Publicar',
                          subtitulo: 'Criar anúncio',
                          cor: Colors.blue,
                          aoClicar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PostarAnuncioScreen(),
                              ),
                            ).then((_) => _carregarDados());
                          },
                        ),
                        _botaoMenu(
                          icone: Icons.download,
                          titulo: 'Receber',
                          subtitulo: 'Ver anúncios',
                          cor: Colors.green,
                          aoClicar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReceberAnunciosScreen(),
                              ),
                            );
                          },
                        ),
                        _botaoMenu(
                          icone: Icons.person,
                          titulo: 'Perfil',
                          subtitulo: 'Meus dados',
                          cor: Colors.orange,
                          aoClicar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PerfilScreen(),
                              ),
                            ).then((_) => _carregarDados());
                          },
                        ),
                        _botaoMenu(
                          icone: Icons.location_on,
                          titulo: 'Locais',
                          subtitulo: 'Infraestruturas',
                          cor: Colors.purple,
                          aoClicar: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _botaoMenu({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required VoidCallback aoClicar,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 48, color: cor),
              const SizedBox(height: 12),
              Text(
                titulo,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
