import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/preferencias.dart';
import '../utils/constantes.dart';
import '../widgets/botao_customizado.dart';
import '../widgets/campo_texto.dart';
import '../widgets/loading_widget.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formChave = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _nomeController = TextEditingController();
  bool _carregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Constantes.corErro : Constantes.corSucesso,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cadastrar() async {
    if (!_formChave.currentState!.validate()) return;

    if (_senhaController.text != _confirmarSenhaController.text) {
      _mostrarMensagem('As senhas não coincidem!', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    final resultado = await ApiService.cadastrarUsuario(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      nome: _nomeController.text.trim(),
    );

    if (mounted) {
      setState(() => _carregando = false);

      if (resultado['sucesso'] == true) {
        _mostrarMensagem(Constantes.sucessoCadastro);

        final loginResultado = await ApiService.login(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );

        if (loginResultado['sucesso'] == true && mounted) {
          await Preferencias.salvarUsuario(
            email: _emailController.text.trim(),
            ticketId: loginResultado['ticketId'],
            nome: _nomeController.text.trim(),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        _mostrarMensagem(
          resultado['mensagem'] ?? 'Erro ao cadastrar',
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
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Constantes.corPrincipal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 50,
                  color: Constantes.corPrincipal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Criar Conta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Registe-se para começar',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formChave,
                child: Column(
                  children: [
                    CampoTexto(
                      controlador: _nomeController,
                      rotulo: 'Nome completo',
                      hint: 'Digite seu nome',
                      icone: Icons.person,
                      validador: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Digite seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                        if (valor.length < 4) {
                          return 'Senha deve ter pelo menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controlador: _confirmarSenhaController,
                      rotulo: 'Confirmar senha',
                      hint: '********',
                      icone: Icons.lock_outline,
                      ehSenha: true,
                      senhaVisivel: _confirmarSenhaVisivel,
                      alternarVisibilidade: () {
                        setState(() =>
                            _confirmarSenhaVisivel = !_confirmarSenhaVisivel);
                      },
                      validador: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Confirme sua senha';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_carregando)
                const LoadingWidget()
              else
                BotaoCustomizado(
                  texto: 'CRIAR CONTA',
                  aoClicar: _cadastrar,
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem conta?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Fazer Login',
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
