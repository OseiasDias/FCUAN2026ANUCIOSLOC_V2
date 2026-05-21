import 'package:flutter/material.dart';
import '../utils/constantes.dart';
import '../services/mula_service.dart';
import '../models/entrega_model.dart';

class EntregaScreen extends StatefulWidget {
  const EntregaScreen({super.key});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  TipoEntrega _tipoSelecionado = TipoEntrega.centralizada;
  List<EntregaModel> _entregasOffline = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregasOffline();
  }

  Future<void> _carregarEntregasOffline() async {
    final entregas = await MulaService.recuperarEntregasOffline();
    setState(() {
      _entregasOffline = entregas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Entrega'),
        backgroundColor: Constantes.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha o método de entrega:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Opcao Centralizada
            _buildOptionCard(
              title: 'Entrega Centralizada',
              description: 'Os anúncios são entregues via servidor central.\n'
                  'Requer conexão com a internet.\n'
                  'Garantia de entrega imediata.',
              icon: Icons.cloud,
              color: Colors.blue,
              tipo: TipoEntrega.centralizada,
            ),

            const SizedBox(height: 12),

            // Opcao WiFi Direct
            _buildOptionCard(
              title: 'WiFi Direct - P2P',
              description: 'Entrega peer-to-peer sem internet.\n'
                  'Conecte-se diretamente a outros dispositivos.\n'
                  'Ideal para áreas sem cobertura.',
              icon: Icons.wifi,
              color: Colors.green,
              tipo: TipoEntrega.wifiDirect,
            ),

            const SizedBox(height: 12),

            // Opcao MULA
            _buildOptionCard(
              title: 'MULA - Store and Forward',
              description: 'Entrega offline com cache local.\n'
                  'Armazena mensagens e entrega quando houver conexão.\n'
                  'Usa QR Code para transferência segura.',
              icon: Icons.qr_code,
              color: Colors.orange,
              tipo: TipoEntrega.mula,
            ),

            const SizedBox(height: 24),

            // Botoes de acao (apenas para MULA)
            if (_tipoSelecionado == TipoEntrega.mula) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Opções MULA:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Mensagens em cache: ${_entregasOffline.length}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      icon: const Icon(Icons.storage),
                      label: Text('Cache: ${_entregasOffline.length}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await MulaService.limparCache();
                        await _carregarEntregasOffline();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cache MULA limpo!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Limpar Cache'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Botao confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmarEntrega,
                icon: Icon(_tipoSelecionado.icon),
                label: Text('Usar ${_tipoSelecionado.displayName}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipoSelecionado.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required TipoEntrega tipo,
  }) {
    final isSelected = _tipoSelecionado == tipo;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _tipoSelecionado = tipo;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEntrega() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modo ${_tipoSelecionado.displayName} ativado'),
        backgroundColor: _tipoSelecionado.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
