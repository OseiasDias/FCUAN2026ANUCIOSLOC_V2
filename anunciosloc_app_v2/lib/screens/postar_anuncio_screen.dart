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

  List<Map<String, String>> _restricoes = [];
  final _chaveController = TextEditingController();
  final _valorController = TextEditingController();
  String _tipoRestricao = 'WHITELIST';

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
      ),
    );
  }

  void _adicionarRestricao() {
    if (_chaveController.text.isEmpty || _valorController.text.isEmpty) {
      _mostrarMensagem('Preencha a chave e o valor', isErro: true);
      return;
    }

    setState(() {
      _restricoes.add({
        'tipo': _tipoRestricao,
        'chave': _chaveController.text.trim(),
        'valor': _valorController.text.trim(),
      });
      _chaveController.clear();
      _valorController.clear();
    });
  }

  void _removerRestricao(int index) {
    setState(() {
      _restricoes.removeAt(index);
    });
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

    if (sucesso && mounted) {
      if (_restricoes.isNotEmpty) {
        final anuncioId = await ApiService.obterUltimoAnuncioId(email);

        for (var restricao in _restricoes) {
          await ApiService.adicionarRestricao(
            anuncioId: anuncioId,
            tipo: restricao['tipo']!,
            chave: restricao['chave']!,
            valor: restricao['valor']!,
          );
        }
      }

      setState(() => _carregando = false);
      _mostrarMensagem('Anúncio publicado com sucesso!');
      _conteudoController.clear();
      _localController.clear();
      setState(() => _restricoes.clear());
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _carregando = false);
      _mostrarMensagem('Erro ao publicar anúncio', isErro: true);
    }
  }

  void _mostrarDialogAdicionarRestricao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Política de Audiência'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tipo de política:'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'WHITELIST', label: Text('WHITELIST (Apenas)')),
                    ButtonSegment(
                        value: 'BLACKLIST', label: Text('BLACKLIST (Exceto)')),
                  ],
                  selected: {_tipoRestricao},
                  onSelectionChanged: (Set<String> selection) {
                    setStateDialog(() {
                      _tipoRestricao = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (_tipoRestricao == 'WHITELIST')
                  const Text(
                    'Apenas utilizadores com esta característica verão o anúncio',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  )
                else
                  const Text(
                    'Utilizadores com esta característica NÃO verão o anúncio',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _chaveController,
                  decoration: const InputDecoration(
                    labelText: 'Chave',
                    hintText: 'Ex: profissao, clube, idade, cidade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ex: estudante, Real Madrid, 25, Luanda',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _adicionarRestricao();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Anúncio'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formChave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                hint: 'Ex: Largo da Independencia, Belas Shopping...',
                icone: Icons.location_on,
                validador: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Digite o local do anúncio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Secao de politicas
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.filter_alt, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Políticas de Audiência',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _mostrarDialogAdicionarRestricao,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ),
                    if (_restricoes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'Nenhuma política definida\nTodos os utilizadores no local verão o anúncio',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _restricoes.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final r = _restricoes[index];
                          final isWhitelist = r['tipo'] == 'WHITELIST';
                          return ListTile(
                            leading: Icon(
                              isWhitelist ? Icons.check_circle : Icons.block,
                              color: isWhitelist ? Colors.green : Colors.red,
                            ),
                            title: Text('${r['chave']} = ${r['valor']}'),
                            subtitle: Text(
                              isWhitelist
                                  ? 'Apenas utilizadores com esta característica'
                                  : 'Utilizadores com esta característica NÃO veem',
                              style: TextStyle(
                                fontSize: 12,
                                color: isWhitelist
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _removerRestricao(index),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Custa 5 pontos por anúncio. O anúncio fica ativo por 30 dias.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              BotaoCustomizado(
                texto: 'PUBLICAR (5 PONTOS)',
                aoClicar: _publicar,
                estaCarregando: _carregando,
                corFundo: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
