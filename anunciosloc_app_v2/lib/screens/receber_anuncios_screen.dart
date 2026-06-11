import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';

class ReceberAnunciosScreen extends StatefulWidget {
  const ReceberAnunciosScreen({super.key});

  @override
  State<ReceberAnunciosScreen> createState() => _ReceberAnunciosScreenState();
}

class _ReceberAnunciosScreenState extends State<ReceberAnunciosScreen> {
  List<Map<String, dynamic>> _anuncios = [];
  bool _carregando = false;
  String? _localSelecionado;
  List<Map<String, dynamic>> _meusLocais = [];
  bool _carregandoLocais = true;
  final TextEditingController _localController = TextEditingController();
  String _mensagemStatus = '';

  @override
  void initState() {
    super.initState();
    _carregarMeusLocais();
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  Future<void> _carregarMeusLocais() async {
    setState(() => _carregandoLocais = true);

    try {
      final email = await Preferencias.getEmail();
      final locais = await ApiService.listarMeusLocais(email);

      setState(() {
        _meusLocais = locais;
        _carregandoLocais = false;
      });
    } catch (e) {
      print("Erro ao carregar locais: $e");
      setState(() => _carregandoLocais = false);
    }
  }

  Future<void> _buscarAnuncios() async {
    final local = _localSelecionado ?? _localController.text.trim();

    if (local.isEmpty) {
      _mostrarMensagem('Selecione ou digite um local', isErro: true);
      return;
    }

    setState(() {
      _carregando = true;
      _anuncios = [];
      _mensagemStatus = '';
    });

    final email = await Preferencias.getEmail();

    try {
      final mensagens = await ApiService.receberAnunciosDeOutros(
        email: email,
        local: local,
      );

      print("Mensagens recebidas: ${mensagens.length}");

      if (mensagens.isEmpty) {
        setState(() {
          _carregando = false;
          _mensagemStatus =
              'Nenhum anúncio encontrado neste local.\nSeja o primeiro a publicar algo aqui!';
        });
      } else {
        setState(() {
          _carregando = false;
          _anuncios = mensagens
              .map((msg) => {
                    'conteudo': msg,
                    'lido': false,
                    'data': DateTime.now(),
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Erro na busca: $e");
      setState(() {
        _carregando = false;
        _mensagemStatus =
            'Erro ao conectar ao servidor.\nVerifique sua conexão.';
      });
    }
  }

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _marcarComoLido(int index) {
    setState(() {
      _anuncios[index]['lido'] = true;
    });
    _mostrarMensagem('Marcado como lido');
  }

  void _mostrarDetalhesAnuncio(Map<String, dynamic> anuncio, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Constantes.corPrincipal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.announcement,
                      color: Constantes.corPrincipal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anúncio de outro utilizador',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Recebido agora',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              anuncio['conteudo'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _marcarComoLido(index);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Marcar como lido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anúncios de Outros'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarAnuncios,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constantes.corPrincipal,
                  Constantes.corPrincipal.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anúncios de outros utilizadores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Veja anúncios publicados por outros utilizadores neste local',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                // Select de local
                _carregandoLocais
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Selecione um local'),
                            ),
                            value: _localSelecionado,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Selecione um local'),
                                ),
                              ),
                              ..._meusLocais.map((local) {
                                return DropdownMenuItem<String>(
                                  value: local['nome'],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          local['tipo'] == 'GPS'
                                              ? Icons.gps_fixed
                                              : Icons.wifi,
                                          size: 18,
                                          color: local['tipo'] == 'GPS'
                                              ? Colors.blue
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(local['nome']),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _localSelecionado = value;
                                _localController.clear();
                                _mensagemStatus = '';
                              });
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _localController,
                          decoration: const InputDecoration(
                            hintText: 'Ou digite outro local',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                          onSubmitted: (_) => _buscarAnuncios(),
                          onChanged: (_) {
                            if (_localSelecionado != null) {
                              setState(() => _localSelecionado = null);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _buscarAnuncios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Constantes.corPrincipal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de anuncios ou mensagem de vazio
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _mensagemStatus.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _mensagemStatus,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/postar_anuncio');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Publicar Anúncio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constantes.corPrincipal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _anuncios.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Selecione um local para ver os anúncios',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _anuncios.length,
                            itemBuilder: (context, index) {
                              final anuncio = _anuncios[index];
                              final isLido = anuncio['lido'] == true;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  elevation: isLido ? 0 : 2,
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      isLido ? Colors.grey[50] : Colors.white,
                                  child: InkWell(
                                    onTap: () =>
                                        _mostrarDetalhesAnuncio(anuncio, index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isLido)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                  top: 8, right: 12),
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Constantes.corPrincipal
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.announcement,
                                              color: isLido
                                                  ? Colors.grey
                                                  : Constantes.corPrincipal,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  anuncio['conteudo'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: isLido
                                                        ? FontWeight.normal
                                                        : FontWeight.w500,
                                                    color: isLido
                                                        ? Colors.grey[600]
                                                        : Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.person_outline,
                                                        size: 12,
                                                        color:
                                                            Colors.grey[400]),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'De outro utilizador',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
