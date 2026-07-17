import 'package:flutter/material.dart';
import '../models/anuncio_p2p.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../services/gps_service.dart';
import '../utils/distancia.dart';
import '../services/mula_service.dart';
import '../services/wifi_direct_service.dart';

class TesteMulaScreen extends StatefulWidget {
  const TesteMulaScreen({super.key});

  @override
  State<TesteMulaScreen> createState() => _TesteMulaScreenState();
}

class _TesteMulaScreenState extends State<TesteMulaScreen> {
  // ==================== ESTADOS ====================
  List<AnuncioP2P> _anunciosEmCache = [];
  bool _mulaAtiva = false;
  String _log = 'Aguardando...';
  bool _carregando = false;
  List<AnuncioP2P> _cacheMula = [];

  // GPS
  double? _minhaLatitude;
  double? _minhaLongitude;
  bool _dentroZona = false;
  String _estadoGps = 'GPS desligado';

  @override
  void initState() {
    super.initState();

    // Inicia o servidor Socket
    WifiDirectService().iniciarServidor();

    // Carrega GPS, cache e anúncios
    _iniciarMula();
  }

  Future<void> _restaurarEstado() async {
    final estado = await Preferencias.getEstadoMula();

    setState(() {
      _mulaAtiva = estado;
    });

    await _iniciarMula();
  }

  // ==================== INICIALIZAR MULA ====================

  Future<void> _iniciarMula() async {
    await _obterLocalizacao();

    // Carregar anúncios do cache offline
    final anunciosCache = await MulaService.recuperarAnuncios();
    setState(() {
      _cacheMula = anunciosCache;
      _anunciosEmCache = List.from(anunciosCache);
      if (_cacheMula.isNotEmpty) {
        _log = '${_cacheMula.length} anúncios carregados do cache offline';
      }
    });

    _verificarZona();
  }

  // ==================== OBTER LOCALIZAÇÃO ====================

  Future<void> _obterLocalizacao() async {
    final pos = await GpsService.obterLocalizacaoAtual();

    if (pos == null) {
      setState(() {
        _estadoGps = 'Sem permissão GPS';
        _log = '❌ Ative o GPS e dê permissão à aplicação';
      });
      return;
    }

    setState(() {
      _minhaLatitude = pos.latitude;
      _minhaLongitude = pos.longitude;
      _estadoGps = 'GPS ativo';
      _log =
          '📍 GPS: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    });

    print('=========================================');
    print('📍 GPS MULA ATUAL');
    print('Latitude: ${pos.latitude}');
    print('Longitude: ${pos.longitude}');
    print('=========================================');
  }

  // ==================== VERIFICAR ZONA (GEOFENCING) ====================

  Future<void> _verificarZona() async {
    if (_minhaLatitude == null || _minhaLongitude == null) {
      return;
    }

    try {
      final locais = await ApiService.listarLocaisCoordenadas();

      for (var local in locais) {
        if (local['tipo'] == 'GPS') {
          final distancia = Distancia.calcular(
            _minhaLatitude!,
            _minhaLongitude!,
            local['latitude'],
            local['longitude'],
          );

          final raio = local['raio'] ?? 50.0;

          if (distancia <= raio) {
            setState(() {
              _dentroZona = true;
              _log =
                  '📍 Dentro da zona: ${local['nome']} (${distancia.toStringAsFixed(0)}m)';
            });

            // Buscar anúncios automaticamente quando entra numa zona
            await _buscarAnunciosDoServidor();
            return;
          }
        }
      }

      setState(() {
        _dentroZona = false;
        _log = '📍 Fora das zonas disponíveis';
      });
    } catch (e) {
      setState(() {
        _log = '❌ Erro ao verificar zonas: $e';
      });
    }
  }

  // ==================== BUSCAR ANÚNCIOS DO SERVIDOR ====================

  Future<void> _buscarAnunciosDoServidor() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _log = '🔄 Buscando anúncios do servidor...';
    });

    try {
      final email = await Preferencias.getEmail();

      // Verificar GPS novamente
      final pos = await GpsService.obterLocalizacaoAtual();
      if (pos == null) {
        setState(() {
          _log = '❌ GPS indisponível para buscar anúncios';
          _carregando = false;
        });
        return;
      }

      _minhaLatitude = pos.latitude;
      _minhaLongitude = pos.longitude;

      print('=========================================');
      print('📡 ENVIANDO PARA SOAP');
      print('Latitude: ${pos.latitude}');
      print('Longitude: ${pos.longitude}');
      print('=========================================');

      final mensagens = await ApiService.receberAnunciosPorLocalizacao(
        email: email,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (!mounted) return;

      if (mensagens.isEmpty) {
        setState(() {
          _log = '📭 Nenhum anúncio encontrado nesta localização';
          _carregando = false;
        });
        return;
      }

      int novosAnuncios = 0;
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

        // Verificar se já existe
        final existe = _cacheMula.any((a) => a.id == anuncioP2P.id);
        if (!existe) {
          _cacheMula.add(anuncioP2P);
          // Guardar no cache offline
          await MulaService.armazenarAnuncio(anuncioP2P);
          novosAnuncios++;
        }
      }

      setState(() {
        _anunciosEmCache = List.from(_cacheMula);
        if (novosAnuncios > 0) {
          _log =
              '✅ ${novosAnuncios} novos anúncios adicionados (total: ${_cacheMula.length})';
        } else {
          _log = '📌 ${_cacheMula.length} anúncios em cache (sem novidades)';
        }
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

  Future<void> _ativarMula(bool valor) async {
    await Preferencias.salvarEstadoMula(valor);

    setState(() {
      _mulaAtiva = valor;

      _log = valor ? ' MULA ATIVADA' : ' MULA DESATIVADA';
    });
  }

  void _carregarAnunciosDoSistema() {
    if (!_mulaAtiva) {
      setState(() {
        _log = '⚠️ Ative a MULA primeiro!';
      });
      return;
    }
    _buscarAnunciosDoServidor();
  }

  void _armazenarComoMula() {
    if (_cacheMula.isEmpty) {
      setState(() {
        _log = '⚠️ Nenhum anúncio para armazenar';
      });
      return;
    }

    if (!_mulaAtiva) {
      setState(() {
        _log = ' Ative a MULA primeiro!';
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
      _log =
          '✅ Anúncio armazenado como MULA! Saltos: ${anuncioComSalto.saltos}';
    });
  }

  Future<void> _entregarAnuncio() async {
    if (_cacheMula.isEmpty) {
      setState(() {
        _log = "Nenhum anúncio";
      });
      return;
    }

    final anuncio = _cacheMula.last;

    final enviado = await WifiDirectService.enviarAnuncio(
      anuncio,
      "192.168.49.1",
    );

    if (enviado) {
      await MulaService.removerAnuncio(anuncio.id);

      setState(() {
        _cacheMula.removeLast();
        _anunciosEmCache = List.from(_cacheMula);
        _log = " Anúncio entregue com sucesso";
      });
    } else {
      setState(() {
        _log = " Falha no envio";
      });
    }
  }

  void _limparCache() async {
    await MulaService.limparCache();
    setState(() {
      _cacheMula.clear();
      _anunciosEmCache = [];
      _log = '🧹 Cache limpo';
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
            // Status GPS e Zona
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.gps_fixed,
                  color: _dentroZona ? Colors.green : Colors.red,
                ),
                title: Text(_estadoGps),
                subtitle: Text(
                  _dentroZona
                      ? '✅ Dentro de uma zona ativa'
                      : '❌ Fora das zonas',
                ),
                trailing: _dentroZona
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              ),
            ),

            // Switch MULA
            Card(
              child: SwitchListTile(
                title: const Text('Ativar MULA'),
                subtitle:
                    Text(_mulaAtiva ? '🟢 MULA ATIVA' : '⚪ MULA DESATIVADA'),
                value: _mulaAtiva,
                onChanged: _ativarMula,
                activeColor: Colors.orange,
              ),
            ),

            const SizedBox(height: 8),

            // Contador de cache
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
                  Text('📦 Anúncios em cache: ${_cacheMula.length}'),
                  const Spacer(),
                  if (_carregando)
                    const CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Botões de ação
            // Botões de ação
            Row(
              children: [
                // CARREGAR DO SERVIDOR
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

                // GUARDAR COMO MULA
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

                // ENTREGAR
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

            // Botões secundários
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _obterLocalizacao,
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('GPS'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _limparCache,
                    icon: const Icon(Icons.delete),
                    label: const Text('Limpar'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Log
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
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Lista de anúncios
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _anunciosEmCache.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Nenhum anúncio em cache'),
                            Text(
                              'Clique em "Carregar" para buscar',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _anunciosEmCache.length,
                        itemBuilder: (context, index) {
                          final a = _anunciosEmCache[index];
                          return ListTile(
                            onTap: () => _mostrarDetalhesAnuncio(a),
                            leading: CircleAvatar(
                              backgroundColor:
                                  a.saltos > 0 ? Colors.orange : Colors.blue,
                              child: Text('${a.saltos}'),
                            ),
                            title: Text(
                              a.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Saltos: ${a.saltos} | ${a.autor} | ${a.local}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
