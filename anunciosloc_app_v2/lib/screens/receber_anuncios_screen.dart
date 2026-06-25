import 'dart:math'; // ← APENAS UMA VEZ

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  List<Map<String, dynamic>> _locaisDisponiveis = [];
  bool _carregandoLocais = true;
  String _mensagemStatus = '';

  bool _usandoLocalizacaoAutomatica = true;
  Position? _posicaoAtual;
  bool _obtendoLocalizacao = false;

  @override
  void initState() {
    super.initState();
    _carregarLocaisEDetectar();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ==================== CARREGAR LOCAIS E DETECTAR AUTOMATICAMENTE ====================

  // ==================== DETECÇÃO AUTOMÁTICA DE LOCALIZAÇÃO ====================
  Future<void> _carregarLocaisEDetectar() async {
    setState(() => _carregandoLocais = true);

    try {
      final locais = await ApiService.listarLocaisCoordenadas();

      final locaisUnicos = <String, Map<String, dynamic>>{};
      for (var local in locais) {
        final nome = local['nome'] as String;
        if (!locaisUnicos.containsKey(nome)) {
          locaisUnicos[nome] = local;
        }
      }

      final locaisLista = locaisUnicos.values.toList();

      setState(() {
        _locaisDisponiveis = locaisLista;
        _carregandoLocais = false;
        // SÓ definir _localSelecionado se houver locais
        if (locaisLista.isNotEmpty) {
          _localSelecionado = locaisLista[0]['nome'];
        } else {
          _localSelecionado =
              null; // ← IMPORTANTE: definir como null se não houver locais
        }
      });

      print("Locais disponiveis carregados: ${locaisLista.length}");

      if (locaisLista.isNotEmpty) {
        await _detectarLocalizacaoAutomatica();
      } else {
        setState(() {
          _mensagemStatus = 'Nenhum local cadastrado no sistema.';
          _carregandoLocais = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar locais: $e");
      setState(() => _carregandoLocais = false);
    }
  }

  Future<void> _detectarLocalizacaoAutomatica() async {
    setState(() {
      _obtendoLocalizacao = true;
      _mensagemStatus = 'Detectando sua localização...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _obtendoLocalizacao = false;
          _mensagemStatus =
              'Ative o GPS para detectar sua localização automaticamente.\nOu selecione um local manualmente.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _obtendoLocalizacao = false;
            _mensagemStatus =
                'Permissão de localização negada.\nSelecione um local manualmente.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _obtendoLocalizacao = false;
          _mensagemStatus =
              'Permissão de localização bloqueada permanentemente.\nSelecione um local manualmente.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 40),
      );

      setState(() {
        _posicaoAtual = position;
        _obtendoLocalizacao = false;
      });

      print("Localização obtida: ${position.latitude}, ${position.longitude}");

      String? localEncontrado = _encontrarLocalMaisProximo(
        position.latitude,
        position.longitude,
      );

      if (localEncontrado != null) {
        setState(() {
          _localSelecionado = localEncontrado;
          _mensagemStatus = '';
          _usandoLocalizacaoAutomatica = true;
        });

        await _buscarAnuncios();
      } else {
        setState(() {
          _mensagemStatus =
              'Você não está em nenhum local cadastrado.\nSelecione um local manualmente.';
        });
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
      setState(() {
        _obtendoLocalizacao = false;
        _mensagemStatus =
            'Erro ao obter localização.\nSelecione um local manualmente.';
      });
    }
  }

  // ==================== ENCONTRAR LOCAL MAIS PRÓXIMO ====================

  String? _encontrarLocalMaisProximo(double lat, double lng) {
    double distanciaMinima = double.infinity;
    String? localMaisProximo;

    for (var local in _locaisDisponiveis) {
      double latLocal = local['latitude'] ?? 0;
      double lngLocal = local['longitude'] ?? 0;
      double raio = local['raio'] ?? 50.0;

      double distancia = _calcularDistancia(lat, lng, latLocal, lngLocal);

      print(
          "Distância para ${local['nome']}: ${distancia.toStringAsFixed(0)}m (raio: ${raio}m)");

      if (distancia <= raio && distancia < distanciaMinima) {
        distanciaMinima = distancia;
        localMaisProximo = local['nome'];
      }
    }

    if (localMaisProximo != null) {
      print(
          "Local detectado: $localMaisProximo (${distanciaMinima.toStringAsFixed(0)}m)");
    }

    return localMaisProximo;
  }

  // ==================== CALCULAR DISTÂNCIA (HAVERSINE) ====================

  double _calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    const double raioTerra = 6371000; // metros

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return raioTerra * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // ==================== BUSCAR ANÚNCIOS ====================
  Future<void> _buscarAnuncios() async {
    final local = _localSelecionado;

    if (local == null || local.isEmpty) {
      _mostrarMensagem('Selecione um local', isErro: true);
      return;
    }

    setState(() {
      _carregando = true;
      _anuncios = [];
      _mensagemStatus = '';
    });

    final email = await Preferencias.getEmail();

    try {
      final mensagens = await ApiService.receberAnunciosPorLocalizacao(
        email: email,
        latitude: _posicaoAtual!.latitude,
        longitude: _posicaoAtual!.longitude,
      );

      print("Mensagens recebidas: ${mensagens.length}");

      if (mensagens.isEmpty) {
        setState(() {
          _carregando = false;
          _mensagemStatus =
              'Nenhum anuncio encontrado em "$local".\nSeja o primeiro a publicar algo aqui!';
        });
      } else {
        setState(() {
          _carregando = false;
          _anuncios = mensagens.map((msg) {
            // ✅ REMOVER OS PIPES E FORMATAR
            String conteudoFormatado = msg;

            // Substituir | por quebra de linha
            conteudoFormatado = conteudoFormatado.replaceAll('|', '\n');

            // Remover tags XML se existirem
            conteudoFormatado =
                conteudoFormatado.replaceAll(RegExp(r'<[^>]*>'), '');

            // Substituir \n literal por quebra real
            conteudoFormatado = conteudoFormatado.replaceAll('\\n', '\n');

            // Remover espaços extras no início/fim
            conteudoFormatado = conteudoFormatado.trim();

            // Extrair autor se existir no formato "nome|email"
            String autor = _extrairAutor(msg);
            String data = _extrairData(msg);

            return {
              'conteudo': conteudoFormatado,
              'lido': false,
              'data': data.isNotEmpty
                  ? DateTime.tryParse(data) ?? DateTime.now()
                  : DateTime.now(),
              'autor': autor.isNotEmpty ? autor : 'Utilizador',
              'local': local,
            };
          }).toList();
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

// ✅ EXTRAIR AUTOR DA MENSAGEM
  String _extrairAutor(String mensagem) {
    // Tentar extrair email do formato "nome|email|..."
    final regex = RegExp(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
    final match = regex.firstMatch(mensagem);
    if (match != null) {
      return match.group(1) ?? 'Utilizador';
    }

    // Tentar extrair nome antes do primeiro |
    final partes = mensagem.split('|');
    if (partes.isNotEmpty && partes[0].trim().isNotEmpty) {
      return partes[0].trim();
    }

    return 'Utilizador';
  }

// ✅ EXTRAIR DATA DA MENSAGEM
  String _extrairData(String mensagem) {
    // Tentar extrair data no formato "2026-06-24 22:13:24.0"
    final regex = RegExp(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})');
    final match = regex.firstMatch(mensagem);
    if (match != null) {
      return match.group(1) ?? '';
    }
    return '';
  }
//  MÉTODO AUXILIAR PARA EXTRAIR O AUTOR

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
    _mostrarMensagem('Visto');
  }

  Widget _buildAnuncioCard(Map<String, dynamic> anuncio, int index) {
    final isLido = anuncio['lido'] == true;
    final conteudo = anuncio['conteudo'] ?? '';
    final data = anuncio['data'] ?? DateTime.now();
    final autor = anuncio['autor'] ?? 'Utilizador';
    final local = anuncio['local'] ?? _localSelecionado ?? 'Local desconhecido';

    // Cores alternadas para fundo
    final List<Color> cores = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F7FA),
    ];
    final corFundo = cores[index % cores.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        elevation: isLido ? 0 : 2,
        borderRadius: BorderRadius.circular(16),
        color: isLido ? Colors.grey[50] : Colors.white,
        child: InkWell(
          onTap: () => _mostrarDetalhesAnuncio(anuncio, index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isLido ? Colors.grey[50] : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== CABEÇALHO ====================
                Row(
                  children: [
                    // Ícone do autor
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isLido
                            ? Colors.grey[300]
                            : Constantes.corPrincipal.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color:
                            isLido ? Colors.grey[500] : Constantes.corPrincipal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  autor,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isLido
                                        ? Colors.grey[600]
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isLido) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'NOVO',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Local e Data com ícones
                          Wrap(
                            spacing: 12,
                            runSpacing: 2,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 100),
                                    child: Text(
                                      local,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatarData(data),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLido)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================== CONTEÚDO DO ANÚNCIO COM ÍCONES ====================
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: corFundo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título (primeira linha)
                      _buildLinhaComIcone(
                        icone: Icons.label,
                        corIcone: Colors.blue,
                        texto: _extrairTitulo(conteudo),
                        estilo: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Descrição (segunda linha)
                      if (_extrairDescricao(conteudo).isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildLinhaComIcone(
                          icone: Icons.description,
                          corIcone: Colors.green,
                          texto: _extrairDescricao(conteudo),
                          estilo: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],

                      // Autor (terceira linha)
                      if (_extrairAutorDoConteudo(conteudo).isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildLinhaComIcone(
                          icone: Icons.email,
                          corIcone: Colors.orange,
                          texto: _extrairAutorDoConteudo(conteudo),
                          estilo: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      // Data (quarta linha)
                      if (_extrairDataDoConteudo(conteudo).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildLinhaComIcone(
                          icone: Icons.calendar_today,
                          corIcone: Colors.purple,
                          texto: _extrairDataDoConteudo(conteudo),
                          estilo: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ==================== RODAPÉ ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isLido)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lido',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Constantes.corPrincipal.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Constantes.corPrincipal.withAlpha(150),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ver detalhes',
                            style: TextStyle(
                              fontSize: 11,
                              color: Constantes.corPrincipal.withAlpha(150),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ==================== MÉTODOS AUXILIARES ====================

  Widget _buildLinhaComIcone({
    required IconData icone,
    required Color corIcone,
    required String texto,
    required TextStyle estilo,
  }) {
    if (texto.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          size: 16,
          color: corIcone,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: estilo,
            softWrap: true,
          ),
        ),
      ],
    );
  }

// Extrair Título (primeira linha)
  String _extrairTitulo(String conteudo) {
    final linhas =
        conteudo.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (linhas.isNotEmpty) {
      // Tentar encontrar a primeira linha que não parece email ou data
      for (var linha in linhas) {
        final trimmed = linha.trim();
        if (!trimmed.contains('@') &&
            !RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
          return trimmed;
        }
      }
      return linhas.first.trim();
    }
    return conteudo;
  }

// Extrair Descrição (segunda linha)
  String _extrairDescricao(String conteudo) {
    final linhas =
        conteudo.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (var linha in linhas) {
      final trimmed = linha.trim();
      if (!trimmed.contains('@') &&
          !RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
        // Pular a primeira linha (título) e pegar a próxima
        final index = linhas.indexOf(linha);
        if (index + 1 < linhas.length) {
          final next = linhas[index + 1].trim();
          if (!next.contains('@') &&
              !RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(next)) {
            return next;
          }
        }
        return '';
      }
    }
    return '';
  }

// Extrair Autor (email)
  String _extrairAutorDoConteudo(String conteudo) {
    final regex = RegExp(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
    final match = regex.firstMatch(conteudo);
    return match?.group(1) ?? '';
  }

// Extrair Data
  String _extrairDataDoConteudo(String conteudo) {
    final regex = RegExp(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})');
    final match = regex.firstMatch(conteudo);
    return match?.group(1) ?? '';
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes < 5) return 'Agora mesmo';
        return '${diff.inMinutes} min atrás';
      }
      return '${diff.inHours}h atrás';
    } else if (diff.inDays == 1) {
      return 'Ontem às ${_formatarHora(data)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else {
      return '${data.day}/${data.month}/${data.year} ${_formatarHora(data)}';
    }
  }

  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarDetalhesAnuncio(Map<String, dynamic> anuncio, int index) {
    final isLido = anuncio['lido'] == true;
    final conteudo = anuncio['conteudo'] ?? '';
    final autor = anuncio['autor'] ?? 'Utilizador';
    final local = anuncio['local'] ?? _localSelecionado ?? 'Local desconhecido';
    final data = anuncio['data'] ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cabeçalho
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Constantes.corPrincipal,
                          Constantes.corPrincipal.withAlpha(180),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.announcement,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anúncio de outro utilizador',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          autor,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // ✅ CORREÇÃO: Wrap em vez de Row
                        Wrap(
                          spacing: 12,
                          runSpacing: 2,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 120),
                                  child: Text(
                                    local,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatarData(data),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Conteúdo do anúncio
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          conteudo,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.8,
                          ),
                          softWrap: true,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ✅ CORREÇÃO: Row com Expanded
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Visualizações',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.share,
                                    color: Colors.green[700],
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Compartilhamentos',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Interesses',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Compartilhar'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _marcarComoLido(index);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.done, size: 18),
                              label: const Text('Marcar como lido'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Fechar',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            onPressed: _detectarLocalizacaoAutomatica,
            tooltip: 'Detectar localização',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              setState(() {
                _usandoLocalizacaoAutomatica = !_usandoLocalizacaoAutomatica;
                if (_usandoLocalizacaoAutomatica) {
                  _detectarLocalizacaoAutomatica();
                } else {
                  _mensagemStatus = 'Modo manual: selecione um local.';
                }
              });
            },
            tooltip: 'Alternar modo de localização',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constantes.corPrincipal,
                  Constantes.corPrincipal.withAlpha(204),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Anúncios de outros utilizadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_usandoLocalizacaoAutomatica &&
                        _localSelecionado != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Veja anúncios publicados por outros utilizadores neste local',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
                if (_localSelecionado != null &&
                    _usandoLocalizacaoAutomatica) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Local: $_localSelecionado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (!_usandoLocalizacaoAutomatica) ...[
                  _carregandoLocais
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: Container(
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('Selecione um local'),
                                    ),
                                  ),
                                  ..._locaisDisponiveis.map((local) {
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
                                            Expanded(
                                              child: Text(
                                                local['nome'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _localSelecionado = value;
                                    _mensagemStatus = '';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                ],
                if (!_usandoLocalizacaoAutomatica)
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _carregando ? null : _buscarAnuncios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Constantes.corPrincipal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
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
                            : const Text('BUSCAR ANÚNCIOS'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: _obtendoLocalizacao
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _mensagemStatus,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _carregando
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
                                    Navigator.pushNamed(
                                        context, '/postar_anuncio');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Publicar Anúncio'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constantes.corPrincipal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
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
                                      _usandoLocalizacaoAutomatica
                                          ? 'Nenhum anúncio encontrado na sua localização.\nAproxime-se de um local com anúncios.'
                                          : 'Selecione um local para ver os anúncios',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600]),
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
                                      color: isLido
                                          ? Colors.grey[50]
                                          : Colors.white,
                                      child: InkWell(
                                        onTap: () => _mostrarDetalhesAnuncio(
                                            anuncio, index),
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Constantes.corPrincipal
                                                      .withAlpha(25),
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
                                                        Icon(
                                                            Icons
                                                                .person_outline,
                                                            size: 12,
                                                            color: Colors
                                                                .grey[400]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'De outro utilizador',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors
                                                                .grey[400],
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
