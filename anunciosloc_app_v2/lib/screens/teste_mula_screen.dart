import 'package:flutter/material.dart';
import '../models/anuncio_p2p.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';

class TesteMulaScreen extends StatefulWidget {
  const TesteMulaScreen({super.key});

  @override
  State<TesteMulaScreen> createState() => _TesteMulaScreenState();
}

class _TesteMulaScreenState extends State<TesteMulaScreen> {
  List<AnuncioP2P> _anunciosEmCache = [];
  bool _mulaAtiva = false;
  String _log = 'Aguardando...';
  bool _carregando = false;
  List<AnuncioP2P> _cacheMula = [];

  // ==================== BUSCAR ANÚNCIOS DO SERVIDOR ====================

  Future<void> _buscarAnunciosDoServidor() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _log = 'Buscando anúncios do servidor...';
    });

    try {
      final email = await Preferencias.getEmail();

      // ✅ USAR O MESMO MÉTODO DO receber_anuncios_screen
      final mensagens = await ApiService.receberAnunciosPorLocalizacao(
        email: email,
        latitude: 0,
        longitude: 0,
      );

      if (!mounted) return;

      if (mensagens.isEmpty) {
        setState(() {
          _log = 'Nenhum anúncio encontrado no servidor';
          _carregando = false;
        });
        return;
      }

      for (var mensagem in mensagens) {
        final dados = _extrairDadosAnuncio(mensagem);

        final anuncioP2P = AnuncioP2P(
          id: 'anuncio-${DateTime.now().millisecondsSinceEpoch}-${_cacheMula.length}',
          titulo: dados['titulo'] ?? 'Anúncio',
          descricao: dados['descricao'] ?? mensagem,
          autor: dados['autor'] ?? 'Utilizador',
          local: dados['local'] ?? 'Local desconhecido',
          dataCriacao: dados['data'] ?? DateTime.now(),
          dispositivoOrigem: 'Servidor Central',
          saltos: 0,
        );

        _cacheMula.add(anuncioP2P);
      }

      setState(() {
        _anunciosEmCache = List.from(_cacheMula);
        _log = '✅ ${_cacheMula.length} anúncios carregados do servidor';
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _log = '❌ Erro ao buscar anúncios: $e';
          _carregando = false;
        });
      }
    }
  }

  // ==================== EXTRAIR DADOS DO ANÚNCIO ====================

  Map<String, dynamic> _extrairDadosAnuncio(String mensagem) {
    final dados = <String, dynamic>{};

    final emailRegex =
        RegExp(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
    final emailMatch = emailRegex.firstMatch(mensagem);
    if (emailMatch != null) {
      dados['autor'] = emailMatch.group(1);
    }

    final locais = [
      'Belas Shopping',
      'Talatona',
      'Kilamba',
      'Benfica',
      'zango',
      'Vida pacífica'
    ];
    for (var local in locais) {
      if (mensagem.contains(local)) {
        dados['local'] = local;
        break;
      }
    }

    final dataRegex = RegExp(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})');
    final dataMatch = dataRegex.firstMatch(mensagem);
    if (dataMatch != null) {
      try {
        dados['data'] = DateTime.parse(dataMatch.group(1)!);
      } catch (e) {
        dados['data'] = DateTime.now();
      }
    } else {
      dados['data'] = DateTime.now();
    }

    final linhas =
        mensagem.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (linhas.isNotEmpty) {
      String primeiraLinha = linhas.first.trim();
      primeiraLinha = primeiraLinha.replaceAll(emailRegex, '').trim();
      for (var local in locais) {
        primeiraLinha = primeiraLinha.replaceAll(local, '').trim();
      }
      primeiraLinha = primeiraLinha.replaceAll(dataRegex, '').trim();

      if (primeiraLinha.isNotEmpty) {
        dados['titulo'] = primeiraLinha;
      } else if (linhas.length > 1) {
        dados['titulo'] = linhas[1].trim();
      } else {
        dados['titulo'] =
            mensagem.substring(0, mensagem.length > 30 ? 30 : mensagem.length);
      }
    } else {
      dados['titulo'] =
          mensagem.substring(0, mensagem.length > 30 ? 30 : mensagem.length);
    }

    dados['descricao'] = mensagem;
    return dados;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  // ==================== MÉTODOS DA MULA ====================

  void _ativarMula(bool valor) {
    setState(() {
      _mulaAtiva = valor;
      _log = 'MULA ${valor ? "ATIVADA" : "DESATIVADA"}';
    });
  }

  void _carregarAnunciosDoSistema() {
    if (!_mulaAtiva) {
      setState(() {
        _log = 'Ative a MULA primeiro!';
      });
      return;
    }
    _buscarAnunciosDoServidor();
  }

  void _armazenarComoMula() {
    if (_cacheMula.isEmpty) {
      setState(() {
        _log = 'Nenhum anúncio para armazenar';
      });
      return;
    }

    if (!_mulaAtiva) {
      setState(() {
        _log = 'Ative a MULA primeiro!';
      });
      return;
    }

    final ultimo = _cacheMula.last;
    final anuncioComSalto = AnuncioP2P(
      id: ultimo.id,
      titulo: ultimo.titulo,
      descricao: ultimo.descricao,
      autor: ultimo.autor,
      local: ultimo.local,
      dataCriacao: ultimo.dataCriacao,
      dispositivoOrigem: ultimo.dispositivoOrigem,
      saltos: ultimo.saltos + 1,
    );

    setState(() {
      _cacheMula.removeLast();
      _cacheMula.add(anuncioComSalto);
      _anunciosEmCache = List.from(_cacheMula);
      _log = 'Anúncio armazenado como MULA! Saltos: ${anuncioComSalto.saltos}';
    });
  }

  void _entregarAnuncio() {
    if (_cacheMula.isEmpty) {
      setState(() {
        _log = 'Nenhum anúncio em cache';
      });
      return;
    }

    final entregue = _cacheMula.last;

    setState(() {
      _cacheMula.removeLast();
      _anunciosEmCache = List.from(_cacheMula);
      _log = 'Anúncio entregue: ${entregue.titulo} (${entregue.saltos} saltos)';
    });
  }

  void _limparCache() {
    setState(() {
      _cacheMula.clear();
      _anunciosEmCache = [];
      _log = 'Cache limpo';
    });
  }

  void _mostrarDetalhesAnuncio(AnuncioP2P anuncio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(anuncio.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${anuncio.descricao}'),
            const SizedBox(height: 8),
            Text('Autor: ${anuncio.autor}'),
            Text('Local: ${anuncio.local}'),
            Text('Data: ${_formatarData(anuncio.dataCriacao)}'),
            Text('Saltos: ${anuncio.saltos}'),
            Text('Origem: ${anuncio.dispositivoOrigem}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _armazenarComoMula();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar como MULA'),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste MULA'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAnunciosDoSistema,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Ativar MULA'),
                subtitle: Text(_mulaAtiva ? 'MULA ATIVA' : 'MULA DESATIVADA'),
                value: _mulaAtiva,
                onChanged: _ativarMula,
                activeColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cacheMula.isNotEmpty
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('Anúncios em cache: ${_cacheMula.length}'),
                  const Spacer(),
                  if (_carregando)
                    const CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _carregarAnunciosDoSistema,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Carregar'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cacheMula.isEmpty || !_mulaAtiva
                        ? null
                        : _armazenarComoMula,
                    icon: const Icon(Icons.save),
                    label: const Text('MULA'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cacheMula.isEmpty ? null : _entregarAnuncio,
                    icon: const Icon(Icons.send),
                    label: const Text('Entregar'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _limparCache,
                icon: const Icon(Icons.delete),
                label: const Text('Limpar Cache'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _log,
                style: const TextStyle(
                    color: Colors.green, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _anunciosEmCache.isEmpty
                    ? const Center(child: Text('Nenhum anúncio em cache'))
                    : ListView.builder(
                        itemCount: _anunciosEmCache.length,
                        itemBuilder: (context, index) {
                          final a = _anunciosEmCache[index];
                          return ListTile(
                            onTap: () => _mostrarDetalhesAnuncio(a),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text('${a.saltos}'),
                            ),
                            title: Text(a.titulo),
                            subtitle: Text(
                                'Saltos: ${a.saltos} | Autor: ${a.autor} | Local: ${a.local}'),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
