import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';
import '../widgets/botao_customizado.dart';
import '../widgets/campo_texto.dart';
import '../widgets/loading_widget.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formChave = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _senhaVisivel = false;

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Constantes.corErro : Constantes.corSucesso,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fazerLogin() async {
    if (!_formChave.currentState!.validate()) return;

    setState(() => _carregando = true);

    final resultado = await ApiService.login(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (mounted) {
      setState(() => _carregando = false);

      if (resultado['sucesso'] == true) {
        await Preferencias.salvarUsuario(
          email: resultado['email'],
          ticketId: resultado['ticketId'],
          nome: _emailController.text.trim().split('@').first,
        );

        _mostrarMensagem(Constantes.sucessoLogin);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _mostrarMensagem(
          resultado['mensagem'] ?? Constantes.erroCredenciais,
          isErro: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Constantes.corPrincipal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 60,
                  color: Constantes.corPrincipal,
                ),
              ),
              const SizedBox(height: 24),
              // Título
              const Text(
                Constantes.nomeApp,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                Constantes.descricaoApp,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Formulário
              Form(
                key: _formChave,
                child: Column(
                  children: [
                    CampoTexto(
                      controlador: _emailController,
                      rotulo: 'E-mail',
                      hint: 'seu@email.com',
                      icone: Icons.email,
                      tipoTeclado: TextInputType.emailAddress,
                      validador: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Digite seu e-mail';
                        }
                        if (!valor.contains('@')) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controlador: _senhaController,
                      rotulo: 'Senha',
                      hint: '********',
                      icone: Icons.lock,
                      ehSenha: true,
                      senhaVisivel: _senhaVisivel,
                      alternarVisibilidade: () {
                        setState(() => _senhaVisivel = !_senhaVisivel);
                      },
                      validador: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Digite sua senha';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Botão login
              if (_carregando)
                const LoadingWidget()
              else
                BotaoCustomizado(
                  texto: 'ENTRAR',
                  aoClicar: _fazerLogin,
                ),
              const SizedBox(height: 16),
              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem conta?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CadastroScreen()),
                      );
                    },
                    child: const Text(
                      'Criar Conta',
                      style: TextStyle(
                        color: Constantes.corPrincipal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
