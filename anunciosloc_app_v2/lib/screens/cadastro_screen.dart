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
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String msg, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isErro ? Constantes.corErro : Constantes.corSucesso,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _cadastrar() async {
    // Validar formulario
    if (!_formChave.currentState!.validate()) {
      return;
    }

    // Validar senhas
    if (_senhaController.text != _confirmarSenhaController.text) {
      _mostrarMensagem('As senhas nao coincidem!', isErro: true);
      return;
    }

    // Validar senha (minimo 4 caracteres)
    if (_senhaController.text.length < 4) {
      _mostrarMensagem('A senha deve ter pelo menos 4 caracteres!',
          isErro: true);
      return;
    }

    // Validar termos
    if (!_aceitouTermos) {
      _mostrarMensagem('Voce deve aceitar os termos de uso!', isErro: true);
      return;
    }

    setState(() => _carregando = true);

    try {
      final email = _emailController.text.trim();
      final senha = _senhaController.text;
      final nome = _nomeController.text.trim();

      print("=== TENTANDO CADASTRAR ===");
      print("Email: $email");
      print("Nome: $nome");

      final resultado = await ApiService.cadastrarUsuario(
        email: email,
        senha: senha,
        nome: nome,
      );

      print("Resultado cadastro: $resultado");

      if (mounted) {
        if (resultado['sucesso'] == true) {
          _mostrarMensagem(Constantes.sucessoCadastro);

          // Login automatico
          final loginResultado = await ApiService.login(
            email: email,
            senha: senha,
          );

          print("Resultado login: $loginResultado");

          if (loginResultado['sucesso'] == true && mounted) {
            // Salvar dados do usuario
            await Preferencias.salvarUsuario(
              email: email,
              ticketId: loginResultado['ticketId'] ?? '',
              nome: nome,
              accessToken: loginResultado['accessToken'],
              refreshToken: loginResultado['refreshToken'],
            );

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else if (mounted) {
            // Se login falhar, vai para tela de login
            _mostrarMensagem(
              'Conta criada! Faca login para continuar.',
              isErro: false,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        } else {
          // Erro no cadastro
          final mensagemErro = resultado['mensagem'] ?? 'Erro ao criar conta';
          _mostrarMensagem(mensagemErro, isErro: true);
          setState(() => _carregando = false);
        }
      }
    } catch (e) {
      print("=== ERRO NO CADASTRO ===");
      print(e);
      if (mounted) {
        setState(() => _carregando = false);
        _mostrarMensagem('Erro inesperado: $e', isErro: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com gradiente
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Constantes.corPrincipal,
                      Constantes.corPrincipal.withAlpha(179),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha os dados para comecar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(230),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formChave,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome completo
                      CampoTexto(
                        controlador: _nomeController,
                        rotulo: 'Nome completo',
                        hint: 'Digite seu nome completo',
                        icone: Icons.person_outline,
                        validador: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Digite seu nome';
                          }
                          if (valor.length < 3) {
                            return 'Nome deve ter pelo menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CampoTexto(
                        controlador: _emailController,
                        rotulo: 'E-mail',
                        hint: 'seu@email.com',
                        icone: Icons.email_outlined,
                        tipoTeclado: TextInputType.emailAddress,
                        validador: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Digite seu e-mail';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(valor)) {
                            return 'E-mail invalido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      CampoTexto(
                        controlador: _senhaController,
                        rotulo: 'Senha',
                        hint: 'Minimo 4 caracteres',
                        icone: Icons.lock_outline,
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

                      // Confirmar senha
                      CampoTexto(
                        controlador: _confirmarSenhaController,
                        rotulo: 'Confirmar senha',
                        hint: 'Digite a senha novamente',
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
                          if (valor != _senhaController.text) {
                            return 'As senhas nao coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Termos de uso
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _aceitouTermos,
                            onChanged: (value) {
                              setState(() => _aceitouTermos = value ?? false);
                            },
                            activeColor: Constantes.corPrincipal,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                    () => _aceitouTermos = !_aceitouTermos);
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Li e aceito os '),
                                    TextSpan(
                                      text: 'Termos de Uso',
                                      style: TextStyle(
                                        color: Constantes.corPrincipal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' e a '),
                                    TextSpan(
                                      text: 'Politica de Privacidade',
                                      style: TextStyle(
                                        color: Constantes.corPrincipal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Botao cadastrar
                      if (_carregando)
                        const LoadingWidget()
                      else
                        BotaoCustomizado(
                          texto: 'CRIAR MINHA CONTA',
                          aoClicar: _cadastrar,
                          corFundo: Constantes.corPrincipal,
                        ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Link para login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ja tem conta?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
