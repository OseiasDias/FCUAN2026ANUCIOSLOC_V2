import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';
import 'postar_anuncio_screen.dart';
import 'receber_anuncios_screen.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';
import 'meus_anuncios_screen.dart';
import 'locais_screen.dart';
import 'entrega_screen.dart';
import 'wifi_direct_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email = '';
  String _nome = '';
  int _saldo = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    _email = await Preferencias.getEmail();
    _nome = await Preferencias.getNome();
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
                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                await Preferencias.sair();

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 4,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Sair',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
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
        title: Text(
          Constantes.nomeApp,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.black45,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _sair,
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD DO PERFIL - Com sombra mais visível
                  Card(
                    elevation: 5,
                    shadowColor: Constantes.corPrincipal.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Constantes.corPrincipal
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Constantes.corPrincipal
                                      .withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Constantes.corPrincipal,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nome.isNotEmpty ? _nome : "Sem nome",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Constantes.corPrincipal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Saldo: $_saldo pontos',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Constantes.corPrincipal,
                                      fontWeight: FontWeight.bold,
                                    ),
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

                  // TÍTULO DO MENU
                  const Text(
                    'Menu Principal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GRID DE BOTÕES - Corrigido overflow com shrinkWrap
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                builder: (_) => const PostarAnuncioScreen()),
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
                                builder: (_) => const ReceberAnunciosScreen()),
                          );
                        },
                      ),
                      _botaoMenu(
                        icone: Icons.list_alt,
                        titulo: 'Meus Anúncios',
                        subtitulo: 'Gerir publicados',
                        cor: Colors.red,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MeusAnunciosScreen()),
                          );
                        },
                      ),
                      _botaoMenu(
                        icone: Icons.person_outline,
                        titulo: 'Perfil',
                        subtitulo: 'Meus dados',
                        cor: Colors.orange,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PerfilScreen()),
                          ).then((_) => _carregarDados());
                        },
                      ),
                      _botaoMenu(
                        icone: Icons.map,
                        titulo: 'Mapa',
                        subtitulo: 'Ver locais',
                        cor: Colors.purple,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LocaisScreen()),
                          );
                        },
                      ),
                      // No grid de botões, adicionar:
                      _botaoMenu(
                        icone: Icons.wifi,
                        titulo: 'WiFi Direct',
                        subtitulo: 'Anúncios P2P',
                        cor: Colors.deepPurple,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WifiDirectScreen()),
                          );
                        },
                      ),
                      _botaoMenu(
                        icone: Icons.local_shipping,
                        titulo: 'Entrega',
                        subtitulo: 'Opções avançadas',
                        cor: Colors.teal,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EntregaScreen()),
                          );
                        },
                      ),
                    ],
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
      elevation: 6,
      shadowColor: cor.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                cor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, size: 32, color: cor),
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
