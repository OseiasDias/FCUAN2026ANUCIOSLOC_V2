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
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _localSelecionado;
  List<Map<String, dynamic>> _locaisDisponiveis = [];
  bool _carregandoLocais = true;
  bool _carregando = false;
  List<Map<String, String>> _restricoes = [];

  int _diasValidade = 30;
  double _custoAnuncio = 5.0;

  final _chaveController = TextEditingController();
  final _valorController = TextEditingController();
  String _tipoRestricao = 'WHITELIST';

  @override
  void initState() {
    super.initState();
    _carregarLocaisDisponiveis();
    _carregarCusto();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _chaveController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _carregarCusto() async {
    try {
      final infra = await ApiService.obterInfoInfraestrutura();
      setState(() {
        _custoAnuncio = infra['custoAnuncio'] ?? 5.0;
      });
    } catch (e) {
      print("Erro ao carregar custo: $e");
    }
  }

  Future<void> _carregarLocaisDisponiveis() async {
    setState(() => _carregandoLocais = true);

    try {
      final locais = await ApiService.listarLocaisCoordenadas();

      setState(() {
        _locaisDisponiveis = locais;
        _carregandoLocais = false;
        if (_locaisDisponiveis.isNotEmpty) {
          _localSelecionado = _locaisDisponiveis[0]['nome'];
        }
      });

      print("Locais disponiveis carregados: ${locais.length}");
    } catch (e) {
      print("Erro ao carregar locais: $e");
      setState(() => _carregandoLocais = false);
    }
  }

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
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
    // Validar formulario
    if (!_formChave.currentState!.validate()) {
      return;
    }

    if (_localSelecionado == null) {
      _mostrarMensagem('Selecione um local', isErro: true);
      return;
    }

    // Validar titulo
    if (_tituloController.text.trim().isEmpty) {
      _mostrarMensagem('Digite o titulo do anuncio', isErro: true);
      return;
    }

    if (_tituloController.text.length > 150) {
      _mostrarMensagem('O titulo excede 150 caracteres', isErro: true);
      return;
    }

    // Validar descricao
    if (_descricaoController.text.trim().isEmpty) {
      _mostrarMensagem('Digite a descricao do anuncio', isErro: true);
      return;
    }

    if (_descricaoController.text.length > 1000) {
      _mostrarMensagem('A descricao excede 1000 caracteres', isErro: true);
      return;
    }

    // Validar dias de validade
    if (_diasValidade < 1 || _diasValidade > 365) {
      _mostrarMensagem('Dias de validade invalido (1 a 365)', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    try {
      final email = await Preferencias.getEmail();

      if (email.isEmpty) {
        _mostrarMensagem('Utilizador nao autenticado', isErro: true);
        setState(() => _carregando = false);
        return;
      }

      print("=== PUBLICANDO ANUNCIO ===");
      print("Email: $email");
      print("Titulo: ${_tituloController.text}");
      print("Descricao: ${_descricaoController.text}");
      print("Local: $_localSelecionado");
      print("Dias validade: $_diasValidade");

      // 1. Verificar saldo ANTES de publicar
      final saldoAtual = await ApiService.consultarSaldo(email);
      print("Saldo atual: $saldoAtual");

      if (saldoAtual < 5) {
        setState(() => _carregando = false);
        _mostrarMensagem(
            '💰 Saldo insuficiente! Você tem $saldoAtual pontos. Necessário 5 pontos para publicar.',
            isErro: true);
        return;
      }

      // 2. Publicar anuncio
      final resultado = await ApiService.publicarAnuncioCompleto(
        email: email,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        local: _localSelecionado!,
        diasValidade: _diasValidade,
      );

      print("Resultado: $resultado");

      // 3. Verificar se foi sucesso
      if (resultado['sucesso'] == true && mounted) {
        final anuncioId = resultado['id'];

        // Adicionar restricoes se existirem
        if (_restricoes.isNotEmpty &&
            anuncioId != null &&
            anuncioId.isNotEmpty) {
          print("Adicionando ${_restricoes.length} restricoes...");
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
        _mostrarMensagem('✅ Anuncio publicado com sucesso!');
        _tituloController.clear();
        _descricaoController.clear();
        setState(() => _restricoes.clear());

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        setState(() => _carregando = false);
        final mensagem = resultado['mensagem'] ?? 'Erro ao publicar anuncio';

        // Mensagens especificas para cada tipo de erro
        if (mensagem.contains('Saldo insuficiente')) {
          _mostrarMensagem(' Saldo insuficiente! Recarregue seus pontos.',
              isErro: true);
        } else if (mensagem.contains('Local nao encontrado')) {
          _mostrarMensagem(
              '📍 Local nao encontrado. Selecione um local valido.',
              isErro: true);
        } else if (mensagem.contains('Titulo') || mensagem.contains('titulo')) {
          _mostrarMensagem(' ${mensagem}', isErro: true);
        } else if (mensagem.contains('Descricao') ||
            mensagem.contains('descricao')) {
          _mostrarMensagem(' ${mensagem}', isErro: true);
        } else {
          _mostrarMensagem(mensagem, isErro: true);
        }
      }
    } catch (e) {
      print("Erro ao publicar: $e");
      setState(() => _carregando = false);
      _mostrarMensagem('Erro: $e', isErro: true);
    }
  }

  void _mostrarDialogAdicionarRestricao() {
    _chaveController.clear();
    _valorController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Politica de Audiencia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tipo de politica:'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'WHITELIST',
                    label: Text('WHITELIST (Apenas)'),
                  ),
                  ButtonSegment(
                    value: 'BLACKLIST',
                    label: Text('BLACKLIST (Exceto)'),
                  ),
                ],
                selected: {_tipoRestricao},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _tipoRestricao = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (_tipoRestricao == 'WHITELIST')
                const Text(
                  'Apenas utilizadores com esta caracteristica veem o anuncio',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                )
              else
                const Text(
                  'Utilizadores com esta caracteristica NAO veem o anuncio',
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
          ),
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
        title: const Text('Publicar Anuncio'),
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
              // Titulo
              CampoTexto(
                controlador: _tituloController,
                rotulo: 'Titulo',
                hint: 'Digite o titulo do anuncio (max 150 caracteres)',
                icone: Icons.title,
                validador: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite o titulo do anuncio';
                  }
                  if (valor.length > 150) {
                    return 'Titulo excede 150 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Contador de titulo
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_tituloController.text.length}/150 caracteres',
                  style: TextStyle(
                    fontSize: 12,
                    color: _tituloController.text.length > 150
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Descricao
              CampoTexto(
                controlador: _descricaoController,
                rotulo: 'Descricao',
                hint: 'Digite a descricao do anuncio...',
                icone: Icons.description,
                validador: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite a descricao do anuncio';
                  }
                  if (valor.length > 1000) {
                    return 'Descricao excede 1000 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Contador de caracteres da descricao
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_descricaoController.text.length}/1000 caracteres',
                  style: TextStyle(
                    fontSize: 12,
                    color: _descricaoController.text.length > 1000
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dias de validade
              const Text(
                'Validade do anuncio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _diasValidade,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 dias')),
                      DropdownMenuItem(value: 15, child: Text('15 dias')),
                      DropdownMenuItem(value: 30, child: Text('30 dias')),
                      DropdownMenuItem(value: 60, child: Text('60 dias')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _diasValidade = value ?? 30;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Select de Local
              const Text(
                'Local',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _carregandoLocais
                  ? const Center(child: CircularProgressIndicator())
                  : _locaisDisponiveis.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(height: 8),
                              Text(
                                'Nenhum local disponivel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Cadastre um local na tela de locais',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _localSelecionado,
                              items: _locaisDisponiveis.map((local) {
                                final isGPS = local['tipo'] == 'GPS';
                                return DropdownMenuItem<String>(
                                  value: local['nome'],
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isGPS
                                              ? Colors.blue.shade50
                                              : Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isGPS ? Icons.gps_fixed : Icons.wifi,
                                          size: 16,
                                          color: isGPS
                                              ? Colors.blue
                                              : Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              local['nome'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              isGPS
                                                  ? 'GPS - ${local['raio']?.toStringAsFixed(0)}m'
                                                  : 'WiFi - ${local['wifiSsid'] ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _localSelecionado = value;
                                });
                              },
                            ),
                          ),
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
                          const Row(
                            children: [
                              Icon(Icons.filter_alt, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Politicas de Audiencia',
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
                            'Nenhuma politica definida\nTodos os utilizadores no local veem o anuncio',
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
                                  ? 'Apenas utilizadores com esta caracteristica'
                                  : 'Utilizadores com esta caracteristica NAO veem',
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

              const SizedBox(height: 16),

              // Informacoes
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Custa $_custoAnuncio pontos por anuncio.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'O anuncio fica ativo por $_diasValidade dias.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (_localSelecionado != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Local selecionado: $_localSelecionado',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              BotaoCustomizado(
                texto: 'PUBLICAR ($_custoAnuncio PONTOS)',
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
